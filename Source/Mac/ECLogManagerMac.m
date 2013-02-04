// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManagerMac.h"

@implementation ECLogManager(PlatformSpecific)

static ECLogManager* gSharedInstance = nil;

/// --------------------------------------------------------------------------
/// Return the shared instance.
/// --------------------------------------------------------------------------

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

/// --------------------------------------------------------------------------
/// Return the top level Debug menu item.
/// If it doesn't already exist, we add one.
/// --------------------------------------------------------------------------

- (NSMenuItem*)debugMenuItem
{
	NSMenuItem* result;

	NSMenu* menubar = [NSApp mainMenu];
	result = [menubar itemWithTitle:@"Debug"];
	if (!result)
	{
		NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:@"Debug" action:nil keyEquivalent:@""];
		result = item;

		ECDebugMenu* menu = [[ECDebugMenu alloc] initWithTitle:@"Debug"];
		item.submenu = menu;
		[menu release];

		[menubar addItem:item];
		[item release];
	}

	return result;
}

/// --------------------------------------------------------------------------
/// Install a Logging menu with log related controls.
/// --------------------------------------------------------------------------

- (void)installLoggingMenu
{
	NSMenuItem* debugItem = [self debugMenuItem];
	NSMenuItem* loggingItem = [debugItem.submenu itemWithTitle:@"Logging"];
	if (!loggingItem)
	{
		loggingItem = [[NSMenuItem alloc] initWithTitle:@"Logging" action:nil keyEquivalent:@""];

		ECLoggingMenu* menu = [[ECLoggingMenu alloc] initWithTitle:@"Logging"];
		loggingItem.submenu = menu;
		[menu release];

		[debugItem.submenu addItem:loggingItem];
		[loggingItem release];
	}
}

/// --------------------------------------------------------------------------
/// Perform some extra Mac-only startup.
/// --------------------------------------------------------------------------

- (void)startup
{
	[super startup];

	if ([self.settings[@"InstallMenu"] boolValue])
	{
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self installLoggingMenu];
		}];
	}

	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(saveSettings:) name:NSApplicationWillResignActiveNotification object:nil];
	[nc addObserver:self selector:@selector(saveSettings:) name:NSApplicationWillTerminateNotification object:nil];
}

/// --------------------------------------------------------------------------
/// Perform some extra Mac-only cleanup.
/// --------------------------------------------------------------------------

- (void)shutdown
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super shutdown];
}

/// --------------------------------------------------------------------------
/// When the app is switched to the background, save out channel
/// settings.
/// --------------------------------------------------------------------------

- (void)saveSettings:(NSNotification*)notification
{
    [self saveChannelSettings];
}

@end
