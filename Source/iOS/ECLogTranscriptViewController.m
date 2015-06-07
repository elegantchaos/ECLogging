// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogTranscriptViewController.h"
#import "ECLogViewHandler.h"
#import "ECLogViewHandlerItem.h"
#import "ECLogChannel.h"
#import "ECLogManager.h"

@interface ECLogTranscriptViewController ()

@property (nonatomic, strong) NSArray* items;
@property (strong, nonatomic) UIFont* messageFont;
@property (strong, nonatomic) UIFont* contextFont;

@end

const CGFloat ECLogViewControllerCellPadding = 16.0;

@implementation ECLogTranscriptViewController

- (id)initWithStyle:(UITableViewStyle)style
{
	if ((self = [super initWithStyle:style]) != nil)
	{
	}

	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:LogItemsUpdated object:nil];
}

#pragma mark - Notifications

- (void)logItemsUpdated:(NSNotification*)notification
{
	self.items = notification.object;
	[self.tableView reloadData];
}

- (void)setupInitialLogItems
{
	// find the log view handler and extract our initial items list from it
	ECLogManager* logManager = [ECLogManager sharedInstance];
	ECLogViewHandler* handler = logManager.handlers[@"View"];
	self.items = handler.items;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.messageFont = [UIFont systemFontOfSize:11];
	self.contextFont = [UIFont systemFontOfSize:9];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logItemsUpdated:) name:LogItemsUpdated object:nil];
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Transcript";
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.items count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* CellIdentifier = @"Cell";

	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.font = self.messageFont;
		cell.textLabel.numberOfLines = 0;
		cell.detailTextLabel.font = self.contextFont;
		cell.detailTextLabel.numberOfLines = 0;
		cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
		cell.detailTextLabel.textColor = [UIColor darkGrayColor];
	}

	// Configure the cell...
	ECLogViewHandlerItem* item = [self.items objectAtIndex:indexPath.row];
	cell.textLabel.text = item.message;
	cell.detailTextLabel.text = item.context;

	return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	ECLogViewHandlerItem* item = [self.items objectAtIndex:indexPath.row];
	NSLineBreakMode mode = NSLineBreakByWordWrapping;
	CGSize constraint = CGSizeMake(tableView.frame.size.width, 10000.0);
	CGSize messageSize = [item.message sizeWithFont:self.messageFont constrainedToSize:constraint lineBreakMode:mode];
	CGSize contextSize = [item.context sizeWithFont:self.contextFont constrainedToSize:constraint lineBreakMode:mode];

	return messageSize.height + contextSize.height + ECLogViewControllerCellPadding;
}


@end
