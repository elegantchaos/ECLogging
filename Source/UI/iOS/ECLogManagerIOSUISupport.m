// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManagerIOSUISupport.h"
#import "ECLogViewController.h"

@interface ECLogManagerIOSUISupport ()

@property (strong, nonatomic) ECLogViewController* viewController;
@property (assign, nonatomic) BOOL uiShowing;

@end


@implementation ECLogManagerIOSUISupport

static ECLogManagerIOSUISupport* gSharedInstance = nil;

// --------------------------------------------------------------------------
//! Return the shared instance.
// --------------------------------------------------------------------------

+ (ECLogManagerIOSUISupport*)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [ECLogManagerIOSUISupport new];
	});

	return gSharedInstance;
}

- (UIViewController*)rootViewController
{
	UIWindow* window = [UIApplication sharedApplication].windows[0];
	UIViewController* root = window.rootViewController;

	return root;
}

- (void)logManagerDidStartup:(ECLogManager*)manager
{
#if EC_DEBUG
	[self installGestureRecognizer];
#endif
}

- (void)showUIForLogManager:(ECLogManager *)manager
{
	[self showUI];
}
	
- (void)installGestureRecognizer
{
	UIWindow* window = UIApplication.sharedApplication.keyWindow;
	if (window) {
		UILongPressGestureRecognizer* recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showUI)];
		recognizer.numberOfTouchesRequired = 2;
		[window addGestureRecognizer:recognizer];
	}
}

- (void)showUI
{
	if (!self.viewController)
	{
		NSBundle* bundle = [NSBundle bundleForClass:[self class]];
		ECLogViewController* controller = [[ECLogViewController alloc] initWithNibName:@"ECLogViewController" bundle:bundle];
		self.viewController = controller;
	}

	if (!self.uiShowing)
	{
		UIViewController* root = [self rootViewController];
		UIViewController* modal = [root presentedViewController];
		[self.viewController showInController:(modal ?: root) doneBlock:^{
			self.uiShowing = NO;
		}];
		self.uiShowing = YES;
	}
}

@end
