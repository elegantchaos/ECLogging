// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogViewController.h"
#import "ECLogSettingsViewController.h"
#import "ECLoggingMacros.h"
#import "ECLogManager.h"
#import "ECLogTranscriptViewController.h"
#import "ECLogManagerIOSUISupport.h"

@interface ECLogViewController ()
@property (copy, nonatomic) ECLoggingSettingsViewControllerDoneBlock doneBlock;
@end

@implementation ECLogViewController

#pragma mark - Channels



#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[self.oTranscriptController setupInitialLogItems];
	[super viewWillAppear:animated];
	
}
- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	self.oSettingsController.navController = self.navigationController;
	[[ECLogManager sharedInstance] saveChannelSettings];
}

- (void)showInController:(UIViewController*)controller doneBlock:(ECLoggingSettingsViewControllerDoneBlock)doneBlock
{
	self.edgesForExtendedLayout = UIRectEdgeNone;
	self.doneBlock = doneBlock;
	UINavigationController* nav = [controller navigationController];
	if (nav)
	{
		[nav pushViewController:self animated:YES];
	}
	else
	{
		UINavigationController* navigation = [[UINavigationController alloc] initWithRootViewController:self];
		self.title = @"ECLogging";
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneModal)];
		
		[controller presentViewController:navigation animated:YES completion:^{
			
		}];
	}
}

- (void)doneModal
{
	[self dismissViewControllerAnimated:YES completion:^{
		[[ECLogManager sharedInstance] saveChannelSettings];
		[self removeFromParentViewController];
		if (self.doneBlock)
			self.doneBlock();
	}];
}

@end
