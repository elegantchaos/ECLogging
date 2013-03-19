// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManagerIOS.h"
#import "ECLoggingViewController.h"

@implementation ECLogManager(PlatformSpecific)

static ECLogManager* gSharedInstance = nil;

// --------------------------------------------------------------------------
//! Return the shared instance.
// --------------------------------------------------------------------------

+ (ECLogManager*)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [[ECLogManagerIOS alloc] init];
	});

	return gSharedInstance;
}

@end

@interface ECLogManagerIOS()

@property (strong, nonatomic) ECLoggingViewController* viewController;

@end


@implementation ECLogManagerIOS

- (void)showUI
{
	if (!self.viewController)
	{
		NSURL* url = [[NSBundle mainBundle] URLForResource:@"ECLogging" withExtension:@"bundle"];
		NSBundle* bundle = [NSBundle bundleWithURL:url];
		ECLoggingViewController* controller = [[ECLoggingViewController alloc] initWithNibName:@"ECLoggingViewController" bundle:bundle];
		self.viewController = controller;
		[controller release];
	}

	UIWindow* window = [UIApplication sharedApplication].windows[0];
	[self.viewController showModallyWithController:window.rootViewController];
}

@end
