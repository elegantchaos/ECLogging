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

ECDefineDebugChannel(LoggingSampleViewControllerChannel);

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
		ECDebug(LoggingSampleViewControllerChannel, @"some test output");
		ECDebug(LoggingSampleViewControllerChannel, @"some more output this should spill over many lines hopefully at least it will if I really keep wittering on and on for a really long time");
	}

@end
