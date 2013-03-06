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

@property (strong, nonatomic) ECDebugViewController* debugController;

@end

@implementation ECLoggingViewController

#pragma mark - Channels

ECDefineDebugChannel(ECLoggingViewControllerChannel);

#pragma mark - Properties

@synthesize debugController;
@synthesize logView;

- (void)dealloc 
{
    [debugController release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.debugController = [[[ECDebugViewController alloc] initWithNibName:nil bundle:nil] autorelease];
}

- (void)viewDidUnload
{
    self.debugController = nil;
    
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[ECLogManager sharedInstance] saveChannelSettings];
}

- (IBAction)tappedShowDebugView:(id)sender
{
    [self.navigationController pushViewController:self.debugController animated:YES];
}

- (IBAction)tappedTestOutput:(id)sender
{
    ECDebug(ECLoggingViewControllerChannel, @"some test output");
    ECDebug(ECLoggingViewControllerChannel, @"some more output this should spill over many lines hopefully at least it will if I really keep wittering on and on for a really long time");
}

@end
