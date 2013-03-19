// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLoggingViewController.h"
#import "ECDebugViewController.h"
#import "ECLoggingMacros.h"
#import "ECLogManager.h"

@interface ECLoggingViewController()

@end

@implementation ECLoggingViewController

#pragma mark - Channels

ECDefineDebugChannel(ECLoggingViewControllerChannel);

#pragma mark - Properties

- (void)dealloc 
{
	[_commandsController release];
	[_logController release];

    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	self.commandsController.navController = self.navigationController;
    [[ECLogManager sharedInstance] saveChannelSettings];
}

- (void)showModallyWithController:(UIViewController*)controller
{
	CGRect frame = self.view.frame;
    const CGFloat kInset = 10.0;
    frame.origin.x += kInset;
    frame.origin.y += kInset;
    frame.size.width -= kInset * 2.0;
    frame.size.height -= kInset * 2.0;

	UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:self];
	navigation.view.frame = frame;
	self.title = @"Test";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleDone target:self action:@selector(doneModal)];
	[controller presentModalViewController:navigation animated:YES];
	[navigation release];
}

- (void)doneModal
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
