// --------------------------------------------------------------------------
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECOptionsMenu.h"
#import "ECLogManager.h"

// --------------------------------------------------------------------------
// Private Methods
// --------------------------------------------------------------------------

@interface ECOptionsMenu ()

@property (strong, nonatomic) NSDictionary* options;

@end


@implementation ECOptionsMenu


#pragma mark - Lifecycle

- (void)awakeFromNib {
	[super awakeFromNib];
	[self setupAsRootMenu];
}

// --------------------------------------------------------------------------
//! Create the menu items.
// --------------------------------------------------------------------------

- (void)setupAsRootMenu {
	ECLogManager* logManager = [ECLogManager sharedInstance];
	if (logManager.showMenu)
	{
		self.options = [logManager options];
		[self removeAllItems];
		[self buildMenuWithOptions:self.options action:@selector(optionSelected:)];
	}
}

// --------------------------------------------------------------------------
//! Build the channels menu.
//! We make some global items, then a submenu for each registered channel.
// --------------------------------------------------------------------------

- (void)buildMenuWithOptions:(NSDictionary*)options action:(SEL)action {
	NSMutableArray* items = [NSMutableArray new];
	for (NSString* option in options)
	{
		NSDictionary* optionData = options[option];
		NSString* title = optionData[@"title"];
		if (!title)
			title = option;

		NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:@""];
		item.target = self;
		NSObject *value = optionData[@"value"];
		item.representedObject = (value ? value : option);
		[items addObject:item];

		NSDictionary* suboptions = optionData[@"suboptions"];
		if (suboptions)
		{
			item.action = nil;
			ECOptionsMenu* submenu = [[ECOptionsMenu alloc] initWithTitle:option];
			[submenu buildMenuWithOptions:suboptions action:action];
			item.submenu = submenu;
		}

		NSDictionary* values = optionData[@"values"];
		if (values)
		{
			item.action = nil;
			ECOptionsMenu* submenu = [[ECOptionsMenu alloc] initWithTitle:option];
			[submenu buildMenuWithOptions:values action:@selector(valueSelected:)];
			item.submenu = submenu;
		}

	}

	NSArray* sorted = [items sortedArrayUsingComparator:^NSComparisonResult(NSMenuItem*  _Nonnull item1, NSMenuItem*  _Nonnull item2) {
		return [item1.title compare:item2.title];
	}];

	for (NSMenuItem* item in sorted) {
		[self addItem:item];
	}
}

#pragma mark - Actions

// --------------------------------------------------------------------------
//! Respond to an option menu item being selected.
// --------------------------------------------------------------------------

- (IBAction)optionSelected:(NSMenuItem*)item {
	NSString* option = item.representedObject;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:![defaults boolForKey:option] forKey:option];
}

- (IBAction)valueSelected:(NSMenuItem*)item {
	NSString* value = item.representedObject;
	NSString* option = item.parentItem.representedObject;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:value forKey:option];
	
}

// --------------------------------------------------------------------------
//! Update the state of the menu items to reflect the current state of the
//! channels/handlers that they represent.
// --------------------------------------------------------------------------

- (BOOL)validateMenuItem:(NSMenuItem*)item {
	BOOL enabled = YES;
	if (item.action == @selector(optionSelected:)) {
		NSString* option = item.representedObject;
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		item.state = [defaults boolForKey:option] ? NSOnState : NSOffState;
	} else if (item.action == @selector(valueSelected:)) {
		NSString* value = item.representedObject;
		NSString* option = item.parentItem.representedObject;
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		item.state = [[defaults valueForKey:option] isEqual:value];
	}

	return enabled;
}

@end
