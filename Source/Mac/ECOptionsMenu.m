// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECOptionsMenu.h"
#import "NSMenu+ECLogging.h"

#import "ECLogManager.h"
#import "ECLogChannel.h"
#import "ECLogHandler.h"

// --------------------------------------------------------------------------
// Private Methods
// --------------------------------------------------------------------------

@interface ECOptionsMenu()

@property (strong, nonatomic) NSDictionary* options;

@end


@implementation ECOptionsMenu


#pragma mark - Lifecycle

// --------------------------------------------------------------------------
//! Set up after creation from a nib.
// --------------------------------------------------------------------------

- (void)awakeFromNib
{
	[super awakeFromNib];

#if EC_DEBUG
	[self setup];
#endif
}

// --------------------------------------------------------------------------
//! Setup after creation from code.
// --------------------------------------------------------------------------

- (id)initWithTitle:(NSString*)title
{
	if ((self = [super initWithTitle: title]) != nil)
	{
		[self setup];
	}

	return self;
}

// --------------------------------------------------------------------------
//! Clean up.
// --------------------------------------------------------------------------

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	[super dealloc];
}


// --------------------------------------------------------------------------
//! Create the menu items.
// --------------------------------------------------------------------------

- (void)setup
{
	ECLogManager* logManager = [ECLogManager sharedInstance];
	self.options = [logManager optionsSettings];

	[self buildMenu];
}

// --------------------------------------------------------------------------
//! Build the channels menu.
//! We make some global items, then a submenu for each registered channel.
// --------------------------------------------------------------------------

- (void)buildMenu
{
#if EC_DEBUG
	[self removeAllItemsEC];

	for (NSString* option in self.options)
	{
		NSDictionary* optionData = self.options[option];
		NSString* title = optionData[@"title"];
		if (!title)
			title = option;

		NSMenuItem* item = [self addItemWithTitle:title action:@selector(optionSelected:) keyEquivalent:@""];
		item.target = self;
		item.representedObject = option;
	};

#endif
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
