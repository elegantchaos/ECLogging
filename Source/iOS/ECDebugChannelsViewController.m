// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugChannelsViewController.h"

#import "ECDebugChannelViewController.h"
#import "ECLoggingSettingsViewController.h"

#import "ECLogChannel.h"
#import "ECLogManager.h"

static NSString *const DebugChannelsViewCell = @"DebugChannelsViewCell";

@interface ECDebugChannelsViewController()

@property (strong, nonatomic) UIFont* font;

@end
@implementation ECDebugChannelsViewController

// --------------------------------------------------------------------------
// Log Channels
// --------------------------------------------------------------------------

ECDefineDebugChannel(DebugChannelsViewChannel);

// --------------------------------------------------------------------------
//! Finish setting up the view.
// --------------------------------------------------------------------------

- (void) viewDidLoad
{
	ECDebug(DebugChannelsViewChannel, @"setting up view");

    self.channels = [[ECLogManager sharedInstance] channelsSortedByName];
	self.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
	self.tableView.rowHeight = 32.0;
	
    [super viewDidLoad];
}

// --------------------------------------------------------------------------
//! Support any orientation.
// --------------------------------------------------------------------------

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark UITableViewDataSource methods

// --------------------------------------------------------------------------
//! How many sections are there?
// --------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// --------------------------------------------------------------------------
//! Return the header title for a section.
// --------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection: (NSInteger) section
{
    return @"Log Channels";
}


// --------------------------------------------------------------------------
//! Return the header title for a section.
// --------------------------------------------------------------------------

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection: (NSInteger) section
{
    return @"This is a list of the channels encountered so far. Other channels may appear in the list as something gets logged to them. Tap a channel to enable/disable it, or tap the disclosure button to configure it.";
}

// --------------------------------------------------------------------------
//! Return the number of rows in a section.
// --------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger) sectionIndex
{
    return [self.channels count];
}


// --------------------------------------------------------------------------
//! Return the view for a given row.
// --------------------------------------------------------------------------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ECLogChannel* channel = [self.channels objectAtIndex:indexPath.row];
    
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DebugChannelsViewCell];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:DebugChannelsViewCell];
	}
	
    cell.textLabel.text = channel.name;
	cell.textLabel.font = self.font;
    cell.detailTextLabel.text = channel.enabled ? @"enabled" : @"disabled";
	cell.detailTextLabel.font = self.font;
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    
	return cell;
}


// --------------------------------------------------------------------------
//! Handle selecting a table row.
// --------------------------------------------------------------------------

- (void) tableView:(UITableView*) table didSelectRowAtIndexPath:(NSIndexPath*) path
{
    ECLogChannel* channel = [self.channels objectAtIndex:path.row];
    channel.enabled = !channel.enabled;
    [self.tableView reloadData];
}



// --------------------------------------------------------------------------
//! Handle a tap on the accessory button.
// --------------------------------------------------------------------------

- (void) tableView: (UITableView*) table accessoryButtonTappedForRowWithIndexPath: (NSIndexPath*) path
{
    ECLogChannel* channel = [self.channels objectAtIndex:path.row];
    ECDebugChannelViewController* controller = [[ECDebugChannelViewController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.title = channel.name;
    controller.channel = channel;
    [self.debugViewController pushViewController:controller];
}

@end
