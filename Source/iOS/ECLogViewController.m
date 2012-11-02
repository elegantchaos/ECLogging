//
//  ECLogViewController.m
//  ECLoggingSample
//
//  Created by Sam Deane on 02/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ECLogViewController.h"
#import "ECLogViewHandler.h"
#import "ECLogViewHandlerItem.h"
#import "ECLogChannel.h"

@interface ECLogViewController()

@property (nonatomic, strong) NSArray* items;
@property (nonatomic, retain) UIFont* messageFont;
@property (nonatomic, retain) UIFont* contextFont;

@end

@implementation ECLogViewController

@synthesize messageFont = _messageFont;
@synthesize contextFont = _contextFont;
@synthesize items = _items;

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

    [_contextFont release];
    [_items release];
    [_messageFont release];

    [super dealloc];
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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
