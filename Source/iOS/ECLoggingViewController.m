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
    [[ECLogManager sharedInstance] saveChannelSettings];
}

@end
