//
//  ViewController.m
//  ECLoggingIOSTest
//
//  Created by Sam Deane on 26/07/2017.
//  Copyright © 2017 Elegant Chaos. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

#pragma mark - Channels



@implementation ViewController


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[[ECLogManager sharedInstance] saveChannelSettings];
}

- (IBAction)tappedShowDebugView:(id)sender
{
	[[ECLogManager sharedInstance] showUI];
}

- (IBAction)tappedTestOutput:(id)sender
{
}

@end
