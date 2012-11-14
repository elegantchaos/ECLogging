//
//  ECLogManagerMac.m
//  ECLogging
//
//  Created by Sam Deane on 31/10/2012.
//  Copyright (c) 2012 Elegant Chaos. All rights reserved.
//

#import "ECLogManagerMac.h"

@implementation ECLogManager(PlatformSpecific)

static ECLogManager* gSharedInstance = nil;

// --------------------------------------------------------------------------
//! Return the shared instance.
// --------------------------------------------------------------------------

+ (ECLogManager*)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [[ECLogManagerMac alloc] init];
	});

	return gSharedInstance;
}

@end

@implementation ECLogManagerMac

- (void)installDebugMenu
{

	NSMenu* menubar = [NSApp mainMenu];
	ECLoggingMenu* menu = [[ECLoggingMenu alloc] initWithTitle:@"Debug"];
	NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:@"Debug" action:nil keyEquivalent:@""];
	item.submenu = menu;
	[menubar addItem:item];
	[item release];
	[menu release];
}

- (void)startup
{
	[super startup];

	if ([self.settings[@"InstallMenu"] boolValue])
	{
		[self performSelector:@selector(installDebugMenu) withObject:nil afterDelay:0.0];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:NSApplicationWillResignActiveNotification object:nil];
}

- (void)shutdown
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super shutdown];
}

- (void)appWillResignActive:(NSNotification*)notification
{
    [self saveChannelSettings];
}

@end
