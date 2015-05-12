// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogViewController.h"
#import "ECLogViewHandler.h"
#import "ECLogViewHandlerItem.h"
#import "ECLogChannel.h"

@interface ECLogViewController ()

@property (nonatomic, strong) NSArray* items;
@property (strong, nonatomic) UIFont* messageFont;
@property (strong, nonatomic) UIFont* contextFont;

@end

@implementation ECLogViewController

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.messageFont = [UIFont systemFontOfSize:14];
	self.contextFont = [UIFont systemFontOfSize:10];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logItemsUpdated:) name:LogItemsUpdated object:nil];
}

#pragma mark - Table view data source

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Log";
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
	}

	// Configure the cell...
	ECLogViewHandlerItem* item = [self.items objectAtIndex:indexPath.row];

	cell.textLabel.text = item.message;
	cell.textLabel.font = self.messageFont;
	cell.textLabel.numberOfLines = 0;

	cell.detailTextLabel.text = item.context;
	cell.detailTextLabel.font = self.contextFont;
	cell.detailTextLabel.numberOfLines = 0;
	//    cell.detailTextLabel.textAlignment = UITextAlignmentRight;

	return cell;
}

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	ECLogViewHandlerItem* item = [self.items objectAtIndex:indexPath.row];

#ifdef __IPHONE_6_0
	NSLineBreakMode mode = NSLineBreakByWordWrapping;
#else
	UILineBreakMode mode = UILineBreakModeWordWrap;
#endif

	CGSize constraint = CGSizeMake(tableView.frame.size.width, 10000.0);
	CGSize messageSize = [item.message sizeWithFont:self.messageFont constrainedToSize:constraint lineBreakMode:mode];
	CGSize contextSize = [item.context sizeWithFont:self.contextFont constrainedToSize:constraint lineBreakMode:mode];

	return messageSize.height + contextSize.height;
}


@end
