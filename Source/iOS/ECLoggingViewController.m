// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLoggingViewController.h"
#import "ECLoggingSettingsViewController.h"
#import "ECLoggingMacros.h"
#import "ECLogManager.h"
#import "ECLogViewController.h"

@interface ECLoggingViewController()

@end

@implementation ECLoggingViewController

#pragma mark - Channels

ECDefineDebugChannel(ECLoggingViewControllerChannel);

#pragma mark - Properties

- (void)dealloc 
{
	[_oLogController release];
	[_oSettingsController release];

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
	self.oSettingsController.navController = self.navigationController;
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
	self.title = @"ECLogging";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneModal)];
	[controller presentModalViewController:navigation animated:YES];
	[navigation release];
}

- (void)doneModal
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillLayoutSubviews
{
	CGRect logFrame = self.oLogController.view.frame;
	logFrame.size.height = self.view.frame.size.height - logFrame.origin.y;
	self.oLogController.view.frame = logFrame;
}

@end
