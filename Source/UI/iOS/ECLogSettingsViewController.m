// --------------------------------------------------------------------------
//  Copyright (c) 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license:http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogSettingsViewController.h"
#import "ECDebugChannelsViewController.h"
#import "ECDebugHandlersViewController.h"

#import "ECLogChannel.h"
#import "ECLogManager.h"
#import "ECLoggingMacros.h"

@interface ECLogSettingsViewController ()

@property (strong, nonatomic) UIFont* settingsFont;

@end

@implementation ECLogSettingsViewController

// --------------------------------------------------------------------------
// Log Channels
// --------------------------------------------------------------------------

ECDefineDebugChannel(DebugViewChannel);

// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Constants
// --------------------------------------------------------------------------


typedef enum
{
	kShowChannelsCommand,
	kShowHandlersCommand,
	kEnableAllChannelsCommand,
	kDisableAllChannelsCommand,
	kResetAllSettingsCommand
} Command;

typedef struct
{
	NSString* const __unsafe_unretained name;
	UITableViewCellAccessoryType accessory;
	Command command;
} Item;

Item kItems[] = {
	{ @"Configure Channels", UITableViewCellAccessoryDisclosureIndicator, kShowChannelsCommand },
	{ @"Default Handlers", UITableViewCellAccessoryDisclosureIndicator, kShowHandlersCommand },
	{ @"Enable All", UITableViewCellAccessoryNone, kEnableAllChannelsCommand },
	{ @"Disable All", UITableViewCellAccessoryNone, kDisableAllChannelsCommand },
	{ @"Reset All", UITableViewCellAccessoryNone, kResetAllSettingsCommand }
};

// --------------------------------------------------------------------------

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [super initWithStyle:UITableViewStyleGrouped]) != nil)
	{
	}

	return self;
}

// --------------------------------------------------------------------------
//! Finish setting up the view.
// --------------------------------------------------------------------------

- (void)viewDidLoad
{
	ECDebug(DebugViewChannel, @"setting up view");
	self.title = @"Debug";
	self.settingsFont = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	[super viewDidLoad];
}

// --------------------------------------------------------------------------
//! Show the channels sub-view
// --------------------------------------------------------------------------

- (void)showChannels
{
	ECDebugChannelsViewController* controller = [[ECDebugChannelsViewController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.settingsViewController = self;
	[self pushViewController:controller];
}

// --------------------------------------------------------------------------
//! Show the handlers sub-view
// --------------------------------------------------------------------------

- (void)showHandlers
{
	ECDebugHandlersViewController* controller = [[ECDebugHandlersViewController alloc] initWithStyle:UITableViewStyleGrouped];
	controller.settingsViewController = self;
	[self pushViewController:controller];
}

// --------------------------------------------------------------------------
//! Push a controller to the right nav controller.
// --------------------------------------------------------------------------

- (void)pushViewController:(UIViewController*)controller
{
	UINavigationController* nav = self.navController;
	if (!nav)
	{
		nav = self.navigationController;
	}

	[nav pushViewController:controller animated:TRUE];
}

#pragma mark UITableViewDataSource methods

// --------------------------------------------------------------------------
//! How many sections are there?
// --------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

// --------------------------------------------------------------------------
//! Return the header title for a section.
// --------------------------------------------------------------------------

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Settings";
}

// --------------------------------------------------------------------------
//! Return the number of rows in a section.
// --------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)sectionIndex
{
	return sizeof(kItems) / sizeof(Item);
}


// --------------------------------------------------------------------------
//! Return the view for a given row.
// --------------------------------------------------------------------------

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"DebugViewCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DebugViewCell"];
	}

	Item* item = &kItems[indexPath.row];
	cell.textLabel.text = item->name;
	cell.textLabel.font = self.settingsFont;
	cell.accessoryType = item->accessory;

	return cell;
}


// --------------------------------------------------------------------------
//! Handle selecting a table row.
// --------------------------------------------------------------------------

- (void)tableView:(UITableView*)table didSelectRowAtIndexPath:(NSIndexPath*)path
{
	Item* item = &kItems[path.row];
	switch (item->command)
	{
		case kShowChannelsCommand:
			[self showChannels];
			break;

		case kShowHandlersCommand:
			[self showHandlers];
			break;

		case kEnableAllChannelsCommand:
			[[ECLogManager sharedInstance] enableAllChannels];
			break;

		case kDisableAllChannelsCommand:
			[[ECLogManager sharedInstance] disableAllChannels];
			break;

		case kResetAllSettingsCommand:
			[[ECLogManager sharedInstance] resetAllSettings];
			break;
	}

	[table deselectRowAtIndexPath:path animated:YES];
}

@end
