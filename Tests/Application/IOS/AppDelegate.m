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
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[ECLogManager sharedInstance] saveChannelSettings];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
}


- (void)applicationWillTerminate:(UIApplication *)application {
	[[ECLogManager sharedInstance] shutdown];
}


@end
