// --------------------------------------------------------------------------
//
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECOptionsMenu.h"
#import "NSMenu+ECLogging.h"

// --------------------------------------------------------------------------
// Private Methods
// --------------------------------------------------------------------------

@interface ECOptionsMenu()

@property (strong, nonatomic) NSDictionary* options;

@end


@implementation ECOptionsMenu


#pragma mark - Lifecycle

/**
	Set up after creation from a nib.
	Only the top menu wants to be set up - if we're a submenu, don't bother.
 */

- (void)awakeFromNib
{
	[super awakeFromNib];
	if (![self.supermenu isKindOfClass:[self class]])
	{
		[self setupAsRootMenu];
	}
}

// --------------------------------------------------------------------------
//! Clean up.
// --------------------------------------------------------------------------

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}


// --------------------------------------------------------------------------
//! Create the menu items.
// --------------------------------------------------------------------------

- (void)setupAsRootMenu
{
	ECLogManager* logManager = [ECLogManager sharedInstance];
	if (logManager.showMenu)
	{
		self.options = [logManager optionsSettings];
		[self removeAllItemsEC];
		[self buildMenuWithOptions:self.options];
	}
}

// --------------------------------------------------------------------------
//! Build the channels menu.
//! We make some global items, then a submenu for each registered channel.
// --------------------------------------------------------------------------

- (void)buildMenuWithOptions:(NSDictionary*)options
{
	for (NSString* option in options)
	{
		NSDictionary* optionData = options[option];
		NSString* title = optionData[@"title"];
		if (!title)
			title = option;

		NSMenuItem* item = [self addItemWithTitle:title action:@selector(optionSelected:) keyEquivalent:@""];
		item.target = self;
		item.representedObject = option;

		NSDictionary* suboptions = optionData[@"suboptions"];
		if (suboptions)
		{
			item.action = nil;
			ECOptionsMenu* submenu = [[ECOptionsMenu alloc] initWithTitle:option];
			[submenu buildMenuWithOptions:suboptions];
			item.submenu = submenu;
		}
	}
}

#pragma mark - Actions

// --------------------------------------------------------------------------
//! Respond to an option menu item being selected.
// --------------------------------------------------------------------------

- (IBAction)optionSelected:(NSMenuItem*)item
{
	NSString* option = item.representedObject;
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:![defaults boolForKey:option] forKey:option];
}

// --------------------------------------------------------------------------
//! Update the state of the menu items to reflect the current state of the
//! channels/handlers that they represent.
// --------------------------------------------------------------------------

- (BOOL)validateMenuItem:(NSMenuItem*)item
{
	BOOL enabled = YES;
    if (item.action == @selector(optionSelected:))
    {
		NSString* option = item.representedObject;
		NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		item.state = [defaults boolForKey:option] ? NSOnState : NSOffState;
    }

	return enabled;
}

// 		if (strncmp([value objCType], @encode(BOOL), sizeof(@encode(BOOL))) == 0) {

@end
