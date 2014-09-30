// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManagerMacUISupport.h"
#import "ECDebugMenu.h"
#import "ECLoggingMenu.h"
#import "ECOptionsMenu.h"

@implementation ECLogManagerMacUISupport

// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------

static ECLogManagerMacUISupport* gSharedInstance = nil;

/// --------------------------------------------------------------------------
/// Return the shared instance.
/// --------------------------------------------------------------------------

+ (ECLogManagerMacUISupport*)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [ECLogManagerMacUISupport new];
	});

	return gSharedInstance;
}

+ (void)initialize
{
	[ECLogManager sharedInstance].delegate = [self sharedInstance];
}

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

		[menubar addItem:item];
	}

	return result;
}

/// --------------------------------------------------------------------------
/// Install a submenu into the debug menu if it doesn't already exist.
/// --------------------------------------------------------------------------

- (NSMenu*)installDebugSubmenuWithTitle:(NSString*)title class:(Class)menuClass
{
	NSMenuItem* debugItem = [self debugMenuItem];
	NSMenuItem* submenuItem = [debugItem.submenu itemWithTitle:title];
	if (!submenuItem)
	{
		submenuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
		
		id menu = [[menuClass alloc] initWithTitle:title];
		if ([menu respondsToSelector:@selector(setupAsRootMenu)])
			[menu setupAsRootMenu];
		
		submenuItem.submenu = menu;
		
		[debugItem.submenu addItem:submenuItem];
	}
	
	return submenuItem.submenu;
}

/// --------------------------------------------------------------------------
/// Perform some extra Mac-only startup.
/// --------------------------------------------------------------------------

- (void)logManagerDidStartup:(ECLogManager *)manager
{
	if ([manager.settings[@"InstallMenu"] boolValue])
	{
		[[NSOperationQueue mainQueue] addOperationWithBlock:^{
			[self installDebugSubmenuWithTitle:@"Logging" class:[ECLoggingMenu class]];
			[self installDebugSubmenuWithTitle:@"Options" class:[ECOptionsMenu class]];
			NSMenu* utilities = [self installDebugSubmenuWithTitle:@"Utilities" class:[NSMenu class]];
			[utilities addItemWithTitle:@"Crash Now" action:@selector(crashNow:) keyEquivalent:@""].target = self;
			[utilities addItemWithTitle:@"Assert Now" action:@selector(assertNow:) keyEquivalent:@""].target = self;
			[utilities addItemWithTitle:@"Reveal Application Support" action:@selector(revealApplicationSupport:) keyEquivalent:@""].target = self;
		}];
	}

	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(handleBackgroundOrQuitting:) name:NSApplicationWillResignActiveNotification object:nil];
	[nc addObserver:self selector:@selector(handleBackgroundOrQuitting:) name:NSApplicationWillTerminateNotification object:nil];
}

/// --------------------------------------------------------------------------
/// Perform some extra Mac-only cleanup.
/// --------------------------------------------------------------------------

- (void)logManagerWillShutdown:(ECLogManager *)manager
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// --------------------------------------------------------------------------
/// When the app is switched to the background, save out channel
/// settings.
/// --------------------------------------------------------------------------

- (void)handleBackgroundOrQuitting:(NSNotification*)notification
{
    [[ECLogManager sharedInstance] saveChannelSettings];
}

/// --------------------------------------------------------------------------
/// Cause a crash.
/// Useful for testing crash logging etc.
/// --------------------------------------------------------------------------

- (void)crashNow:(id)sender
{
	strcpy((char*)0x1, "I gotta bad feeling about this");
}

/// --------------------------------------------------------------------------
/// Cause an assertion failure.
/// Useful for testing crash logging etc.
/// --------------------------------------------------------------------------

- (void)assertNow:(id)sender
{
	ECAssertShouldntBeHere();
}

/// --------------------------------------------------------------------------
/// Reveal our application support folder.
/// This will open the one in our container, if we're sandboxed.
/// --------------------------------------------------------------------------

- (void)revealApplicationSupport:(id)sender
{
	NSError* error;
	NSFileManager* fm = [NSFileManager defaultManager];
	NSURL* url = [fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
	if (url)
	{
		NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
		while ([identifier length])
		{
			NSURL* specificURL = [url URLByAppendingPathComponent:identifier];
			if ([fm fileExistsAtPath:[specificURL path]])
			{
				url = specificURL;
				break;
			}
			else
			{
				identifier = [identifier stringByDeletingPathExtension];
			}
		}
		[[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
	}
}

@end
