// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLoggingMenu.h"
#import "NSMenu+ECLogging.h"

// --------------------------------------------------------------------------
// Private Methods
// --------------------------------------------------------------------------

@interface ECLoggingMenu()

@property (weak, nonatomic) ECLogManager* logManager;

- (void)setup;
- (void)buildMenu;
- (void)channelsChanged:(NSNotification*)notification;

@end


@implementation ECLoggingMenu


#pragma mark - Lifecycle

// --------------------------------------------------------------------------
//! Set up after creation from a nib.
// --------------------------------------------------------------------------

- (void)awakeFromNib
{
	[super awakeFromNib];

	[self setup];
}

// --------------------------------------------------------------------------
//! Setup after creation from code.
// --------------------------------------------------------------------------

- (id)initWithTitle:(NSString*)title
{
	if ((self = [super initWithTitle: title]) != nil)
	{
		[self setup];
	}
	
	return self;
}

// --------------------------------------------------------------------------
//! Clean up.
// --------------------------------------------------------------------------

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}


// --------------------------------------------------------------------------
//! Create the menu items.
// --------------------------------------------------------------------------

- (void)setup
{
	ECLogManager* lm = [ECLogManager sharedInstance];
	self.logManager = lm;
	if (lm.showMenu)
	{
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc addObserver: self selector: @selector(channelsChanged:) name: LogChannelsChanged object: nil];
		[self buildMenu];
	}
}

// --------------------------------------------------------------------------
//! Build a channel submenu.
// --------------------------------------------------------------------------

- (NSMenu*)buildMenuForChannel:(ECLogChannel*)channel
{
    NSMenu* menu = [[NSMenu alloc] initWithTitle:channel.name];
    
    NSMenuItem* item = [[NSMenuItem alloc] initWithTitle: @"Enabled" action: @selector(channelSelected:) keyEquivalent: @""];
    item.target = self;
    item.state = channel.enabled ? NSOnState : NSOffState;
    item.representedObject = channel;
    [menu addItem: item];

    [menu addItem: [NSMenuItem separatorItem]];

	ECLogManager* manager = self.logManager;
    NSUInteger count = [manager handlerCount];
    for (NSUInteger n = 0; n < count; ++n)
	{
        NSMenuItem* handlerItem = [[NSMenuItem alloc] initWithTitle: [manager handlerNameForIndex:n] action: @selector(handlerSelected:) keyEquivalent: @""];
        handlerItem.target = self;
        handlerItem.tag = n;
        [menu addItem: handlerItem];
    }
    
    [menu addItem: [NSMenuItem separatorItem]];
    
    count = [manager contextFlagCount];
    for (NSUInteger n = 0; n < count; ++n)
    {
        NSString* name = [manager contextFlagNameForIndex:n];
		NSMenuItem* flagItem = [[NSMenuItem alloc] initWithTitle:name action: @selector(contextMenuSelected:) keyEquivalent: @""];
		flagItem.target = self;
        flagItem.tag = n;
		[menu addItem: flagItem];
    }
    
    [menu addItem: [NSMenuItem separatorItem]];
    item = [[NSMenuItem alloc] initWithTitle:@"Reset" action: @selector(resetSelected:) keyEquivalent: @""];
    item.target = self;
    item.representedObject = channel;
    [menu addItem: item];

    return menu;
}

// --------------------------------------------------------------------------
//! Build a channel submenu.
// --------------------------------------------------------------------------

- (NSMenu*)buildDefaultHandlersMenu
{
    NSMenu* menu = [[NSMenu alloc] initWithTitle:@"Default Handlers"];
	
	ECLogManager* manager = self.logManager;
    NSUInteger count = [manager handlerCount];
    for (NSUInteger n = 1; n < count; ++n)
	{
        ECLogHandler* handler = [manager handlerForIndex:n];
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle: handler.name action: @selector(defaultHandlerSelected:) keyEquivalent: @""];
        item.target = self;
        item.representedObject = handler;
        [menu addItem:item];

    }

    return menu;
}

// --------------------------------------------------------------------------
//! Build the channels menu.
//! We make some global items, then a submenu for each registered channel.
// --------------------------------------------------------------------------

- (void)buildMenu
{
	ECLogManager* manager = self.logManager;
	if (manager.showMenu)
	{
		[self removeAllItemsEC];
		
		NSMenuItem* enableAllItem = [[NSMenuItem alloc] initWithTitle: @"Enable All Channels" action: @selector(enableAllChannels) keyEquivalent: @""];
		enableAllItem.target = manager;
		[self addItem: enableAllItem];
		
		NSMenuItem* disableAllItem = [[NSMenuItem alloc] initWithTitle: @"Disable All Channels" action: @selector(disableAllChannels) keyEquivalent: @""];
		disableAllItem.target = manager;
		[self addItem: disableAllItem];
		
		NSMenuItem* resetAllItem = [[NSMenuItem alloc] initWithTitle: @"Reset All Settings" action: @selector(resetAllSettings) keyEquivalent: @""];
		resetAllItem.target = manager;
		[self addItem: resetAllItem];
		
		NSMenuItem* revealLogFilesItem = [[NSMenuItem alloc] initWithTitle: @"Reveal Log Files" action: @selector(revealLogFiles) keyEquivalent: @""];
		revealLogFilesItem.target = self;
		[self addItem: revealLogFilesItem];
		
		NSMenuItem* revealSettingsItem = [[NSMenuItem alloc] initWithTitle: @"Reveal Settings" action: @selector(revealSettings) keyEquivalent: @""];
		revealSettingsItem.target = self;
		[self addItem: revealSettingsItem];
		
		[self addItem:[NSMenuItem separatorItem]];
		
		NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:@"Default Handlers" action:nil keyEquivalent: @""];
		item.submenu = [self buildDefaultHandlersMenu];
		item.target = self;
		[self addItem: item];
		
		[self addItem:[NSMenuItem separatorItem]];
		
		for (ECLogChannel* channel in manager.channelsSortedByName)
		{
			NSMenuItem* channelItem = [[NSMenuItem alloc] initWithTitle: channel.name action: @selector(channelMenuSelected:) keyEquivalent: @""];
			channelItem.submenu = [self buildMenuForChannel:channel];
			channelItem.target = self;
			channelItem.representedObject = channel;
			[self addItem: channelItem];
		}
		
	}
}

#pragma mark - Actions

// --------------------------------------------------------------------------
//! Respond to a channel menu item being selected.
//! We enabled/disable the channel.
// --------------------------------------------------------------------------

- (IBAction)channelMenuSelected:(NSMenuItem*)item
{
	ECLogManager* manager = self.logManager;
	ECLogChannel* channel = item.representedObject;
	channel.enabled = !channel.enabled;
	[manager saveChannelSettings];
}

// --------------------------------------------------------------------------
//! Respond to a channel menu item being selected.
//! We enabled/disable the channel.
// --------------------------------------------------------------------------

- (IBAction)contextMenuSelected:(NSMenuItem*)item
{
    ECLogChannel* channel = [item parentItem].representedObject;
    [channel selectFlagWithIndex:item.tag];
}

// --------------------------------------------------------------------------
//! Respond to a channel menu item being selected.
//! We enabled/disable the channel.
// --------------------------------------------------------------------------

- (IBAction)channelSelected:(NSMenuItem*)item
{
	ECLogManager* manager = self.logManager;
	ECLogChannel* channel = item.representedObject;
	channel.enabled = !channel.enabled;
	[manager saveChannelSettings];
}

// --------------------------------------------------------------------------
//! Respond to a handler menu item being selected.
//! We enable/disable the handler for the channel that the parent menu represents.
// --------------------------------------------------------------------------

- (IBAction)handlerSelected:(NSMenuItem*)item
{
    ECLogChannel* channel = [item parentItem].representedObject;
    [channel selectHandlerWithIndex:item.tag];
}

// --------------------------------------------------------------------------
//! Respond to a handler menu item being selected.
//! We enable/disable the handler for the channel that the parent menu represents.
// --------------------------------------------------------------------------

- (IBAction)resetSelected:(NSMenuItem*)item
{
	ECLogManager* manager = self.logManager;
    ECLogChannel* channel = [item parentItem].representedObject;
    [manager resetChannel:channel];
}

// --------------------------------------------------------------------------
//! Respond to a default handler menu item being selected.
//! We add/remove the handler from the default handlers array
// --------------------------------------------------------------------------

- (IBAction)defaultHandlerSelected:(NSMenuItem*)item
{
	ECLogHandler* handler = item.representedObject;
    
	ECLogManager* manager = self.logManager;
    BOOL currentlyEnabled = [manager.defaultHandlers containsObject:handler];
    BOOL newEnabled = !currentlyEnabled;
    
    if (newEnabled)
    {
        [manager.defaultHandlers addObject:handler];
    }
    else
	{
        [manager.defaultHandlers removeObject:handler];
    }
    
	[manager saveChannelSettings];
}

// --------------------------------------------------------------------------
//! Respond to change notification by rebuilding all items.
// --------------------------------------------------------------------------

- (void)channelsChanged:(NSNotification*)notification
{
	[self buildMenu];
}

// --------------------------------------------------------------------------
//! Update the state of the menu items to reflect the current state of the 
//! channels/handlers that they represent.
// --------------------------------------------------------------------------

- (BOOL)validateMenuItem:(NSMenuItem*)item
{
	BOOL enabled = YES;
	
    if ((item.action == @selector(channelSelected:))|| (item.action == @selector(channelMenuSelected:)))
    {
        ECLogChannel* channel = item.representedObject;
        item.state = channel.enabled ? NSOnState : NSOffState;
    }
    
    else if (item.action == @selector(handlerSelected:))
    {
        ECLogChannel* channel = [item parentItem].representedObject;
        
        BOOL currentlyEnabled = [channel tickHandlerWithIndex:item.tag];
        item.state = currentlyEnabled ? NSOnState : NSOffState;
    }
    
    else if (item.action == @selector(contextMenuSelected:))
    {
        ECLogChannel* channel = [item parentItem].representedObject;

        BOOL currentlyEnabled = [channel tickFlagWithIndex:item.tag];
        item.state = currentlyEnabled ? NSOnState : NSOffState;
    }
    
    else if (item.action == @selector(defaultHandlerSelected:))
    {
        ECLogHandler* handler = item.representedObject;
        
		ECLogManager* manager = self.logManager;
        BOOL currentlyEnabled = [manager.defaultHandlers containsObject:handler];
        item.state = currentlyEnabled ? NSOnState : NSOffState;
    }

	else if (item.action == @selector(revealLogFiles))
	{
		NSURL* url = [self logFolder];
		NSFileManager* fm = [NSFileManager defaultManager];
		enabled = [fm fileExistsAtPath:[url path]];
	}
	
    return enabled;
}

- (NSURL*)logFolder
{
	NSError* error = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* libraryFolder = [fm URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    NSURL* logsFolder = [libraryFolder URLByAppendingPathComponent:@"Logs"];
    NSURL* logFolder = [logsFolder URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];

	return logFolder;
}

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

- (void)revealLogFiles
{
    [[NSWorkspace sharedWorkspace] selectFile:[[self logFolder] path] inFileViewerRootedAtPath:nil];
}

- (void)revealSettings
{
	NSError* error = nil;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSURL* libraryFolder = [fm URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:&error];
    NSURL* preferencesFolder = [libraryFolder URLByAppendingPathComponent:@"Preferences"];
    NSURL* preferencesFile = [[preferencesFolder URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] URLByAppendingPathExtension:@"plist"];

    [[NSWorkspace sharedWorkspace] selectFile:[preferencesFile path] inFileViewerRootedAtPath:nil];
}

@end
