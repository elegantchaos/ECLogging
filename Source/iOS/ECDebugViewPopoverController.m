// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECDebugViewPopoverController.h"
#import "ECLoggingSettingsViewController.h"

@interface ECDebugViewPopoverController ()

@property (strong, nonatomic) UINavigationController* navController;

@end

@implementation ECDebugViewPopoverController

- (void)loadView
{
	CGRect frame = CGRectMake(0, 0, 600, 800);
	UIView* root = [[UIView alloc] initWithFrame:frame];

	// Implement loadView to create a view hierarchy programmatically, without using a nib.
	ECLoggingSettingsViewController* dc = [[ECLoggingSettingsViewController alloc] init];
	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:dc];
	self.navController = nc;
	dc.view.frame = frame;
	nc.view.frame = frame;
	[root addSubview:nc.view];

	self.view = root;
}

@end
