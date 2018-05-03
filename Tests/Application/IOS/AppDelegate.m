//
//  AppDelegate.m
//  ECLoggingIOSTest
//
//  Created by Sam Deane on 26/07/2017.
//  Copyright © 2017 Elegant Chaos. All rights reserved.
//

#import "AppDelegate.h"

ECDefineDebugChannel(ApplicationChannel);

@interface AppDelegate ()
@property (strong, nonatomic) ECLogManagerIOSUISupport* logSupport;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	ECLogManager* lm = [ECLogManager sharedInstance];
	ECLogManagerIOSUISupport* logSupport = [ECLogManagerIOSUISupport new];
	lm.delegate = logSupport;
	self.logSupport = logSupport;

	return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
	ECDebug(ApplicationChannel, @"will resign active");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	ECDebug(ApplicationChannel, @"did enter background");
	[[ECLogManager sharedInstance] saveChannelSettings];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
	ECDebug(ApplicationChannel, @"will enter foreground");
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	ECDebug(ApplicationChannel, @"did become active");
}


- (void)applicationWillTerminate:(UIApplication *)application {
	ECDebug(ApplicationChannel, @"will terminate");

	[[ECLogManager sharedInstance] shutdown];
}


@end
