// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
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
@property (assign, nonatomic) BOOL uiShowing;

@end


@implementation ECLogManagerIOS

- (UIViewController*)rootViewController
{
	UIWindow* window = [UIApplication sharedApplication].windows[0];
	UIViewController* root = window.rootViewController;

	return root;
}

- (id)init
{
	if ((self = [super init]) != nil)
	{
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(installGestureRecognizer) name:UIApplicationDidFinishLaunchingNotification object:nil];
	}

	return self;
}

- (void)installGestureRecognizer
{
	UIWindow* window = [UIApplication sharedApplication].windows[0];
	//	UISwipeGestureRecognizer* recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showUI)];
	//	recognizer.numberOfTouchesRequired = 4;
	UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showUI)];
	recognizer.numberOfTouchesRequired = 2;
	[window addGestureRecognizer:recognizer];
}

- (void)showUI
{
		if (!self.viewController)
		{
			NSURL* url = [[NSBundle mainBundle] URLForResource:@"ECLogging" withExtension:@"bundle"];
			NSBundle* bundle = [NSBundle bundleWithURL:url];
			ECLoggingViewController* controller = [[ECLoggingViewController alloc] initWithNibName:@"ECLoggingViewController" bundle:bundle];
			self.viewController = controller;
		}

	if (!self.viewController.parentViewController)
	{

		UIViewController* root = [self rootViewController];
		UIViewController* modal = [root presentedViewController];
		UIViewController* viewToDoPresenting = modal ? modal : root;
		UINavigationController* nav = [viewToDoPresenting navigationController];
		if (nav)
		{
			[nav pushViewController:self.viewController animated:YES];
		}
		else
		{
			[self.viewController showModallyWithController:viewToDoPresenting];
			[self installGestureRecognizer];
		}
	}
}

@end
