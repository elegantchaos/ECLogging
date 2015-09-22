// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugChannelViewController.h"

#import "ECLogChannel.h"
#import "ECLogHandler.h"
#import "ECLogManager.h"
#import "ECLogContext.h"

// --------------------------------------------------------------------------
// Private Methods
// --------------------------------------------------------------------------

@interface ECDebugChannelViewController ()

@property (assign, nonatomic) ECLogManager* logManager;

@end


@implementation ECDebugChannelViewController

// --------------------------------------------------------------------------
// Constants
// --------------------------------------------------------------------------

enum
{
	kSettingsSection,
	kHandlersSection,
	kContextSection,
	kResetSection
};

NSString* const kSections[] = { @"Settings", @"Handlers", @"Context", @"Reset" };
NSString* const kSectionFooters[] = { @"Enabled channels produce output. Disabled channels are ignored.", @"Messages sent to this channel will be processed by the ticked handlers.", @"Ticked context items will be logged along with each message.", @"Resetting puts a channel back to the default state." };

- (id)initWithStyle:(UITableViewStyle)style
{
	if ((self = [super initWithStyle:style]) != nil)
	{
		self.logManager = [ECLogManager sharedInstance];
	}

	return self;
}

#pragma mark UITableViewDataSource methods

// --------------------------------------------------------------------------
//! How many sections are there?
// --------------------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return sizeof(kSections) / sizeof(NSString*);
}

// --------------------------------------------------------------------------
//! Return the header title for a section.
// --------------------------------------------------------------------------

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return kSections[section];
}

// --------------------------------------------------------------------------
//! Return the footer title for a section.
// --------------------------------------------------------------------------

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
	return kSectionFooters[section];
}

// --------------------------------------------------------------------------
//! Return the number of rows in a section.
// --------------------------------------------------------------------------

- (NSInteger)tableView:(UITableView*)table numberOfRowsInSection:(NSInteger)section
{
	if (section == kSettingsSection)
	{
		return 1;
	}
	else if (section == kHandlersSection)
	{
		return [self.logManager handlerCount];
	}
	else if (section == kContextSection)
	{
		return [self.logManager contextFlagCount];
	}
	else
	{
		return 1;
	}
}


// --------------------------------------------------------------------------
//! Return the view for a given row.
// --------------------------------------------------------------------------

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)path
{
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelViewCell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChannelViewCell"];
	}

	NSString* label;
	BOOL ticked;

	if (path.section == kSettingsSection)
	{
		label = @"Enabled";
		ticked = self.channel.enabled;
	}
	else if (path.section == kHandlersSection)
	{
		label = [self.logManager handlerNameForIndex:path.row];
		ticked = [self.channel tickHandlerWithIndex:path.row];
	}
	else if (path.section == kContextSection)
	{
		label = [self.logManager contextFlagNameForIndex:path.row];
		ticked = [self.channel tickFlagWithIndex:path.row];
	}
	else
	{
		label = @"Reset";
		ticked = NO;
	}

	cell.textLabel.text = label;
	cell.accessoryType = ticked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}


// --------------------------------------------------------------------------
//! Handle selecting a table row.
// --------------------------------------------------------------------------

- (void)tableView:(UITableView*)table didSelectRowAtIndexPath:(NSIndexPath*)path
{
	if (path.section == kSettingsSection)
	{
		ECMakeContext();
		if (self.channel.enabled)
		{
			logToChannel(self.channel, &ecLogContext, @"disabled channel");
			self.channel.enabled = NO;
		}
		else
		{
			self.channel.enabled = YES;
			logToChannel(self.channel, &ecLogContext, @"enabled channel");
		}
		[self.logManager saveChannelSettings];
	}
	else if (path.section == kHandlersSection)
	{
		[self.channel selectHandlerWithIndex:path.row];
	}
	else if (path.section == kContextSection)
	{
		[self.channel selectFlagWithIndex:path.row];
	}
	else
	{
		[self.logManager resetChannel:self.channel];
	}

	[table deselectRowAtIndexPath:path animated:YES];
	[self.tableView reloadData];
}

@end
