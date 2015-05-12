// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license:http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugHandlersViewController.h"

#import "ECDebugChannelViewController.h"
#import "ECLoggingSettingsViewController.h"

#import "ECLogHandler.h"
#import "ECLogManager.h"

// --------------------------------------------------------------------------
// Private Methods
// --------------------------------------------------------------------------

static NSString* const DebugHandlersViewCell = @"DebugHandlersViewCell";

@implementation ECDebugHandlersViewController

// --------------------------------------------------------------------------
// Log Channels
// --------------------------------------------------------------------------

ECDefineDebugChannel(DebugHandlersViewChannel);

// --------------------------------------------------------------------------
//! Finish setting up the view.
// --------------------------------------------------------------------------

- (void)viewDidLoad
{
	ECDebug(DebugHandlersViewChannel, @"setting up view");

	self.handlers = [[ECLogManager sharedInstance] handlersSortedByName];
	[super viewDidLoad];
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
	return @"Default Handlers";
}

// --------------------------------------------------------------------------
//! Return the header title for a section.
// --------------------------------------------------------------------------

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
	return @"Messages for any channel set to use the default handlers will be sent to all ticked items.";
}

// --------------------------------------------------------------------------
//! Return the number of rows in a section.
// --------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)sectionIndex
{
	return [self.handlers count];
}


// --------------------------------------------------------------------------
//! Return the view for a given row.
// --------------------------------------------------------------------------

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	ECLogHandler* handler = [self.handlers objectAtIndex:indexPath.row];

	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DebugHandlersViewCell];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DebugHandlersViewCell];
	}

	cell.textLabel.text = handler.name;
	cell.accessoryType = [[ECLogManager sharedInstance] handlerIsDefault:handler] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}


// --------------------------------------------------------------------------
//! Handle selecting a table row.
// --------------------------------------------------------------------------

- (void)tableView:(UITableView*)table didSelectRowAtIndexPath:(NSIndexPath*)path
{
	ECLogHandler* handler = [self.handlers objectAtIndex:path.row];
	ECLogManager* lm = [ECLogManager sharedInstance];
	BOOL isDefault = [lm handlerIsDefault:handler];
	[lm handler:handler setDefault:!isDefault];
	[self.tableView reloadData];
}

@end
