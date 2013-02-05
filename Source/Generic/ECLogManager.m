// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManager.h"
#import "ECLogChannel.h"
#import "ECLogHandlerNSLog.h"

@interface ECLogManager()

// Turn this setting on to output debug message on the log manager itself, using NSLog
#define LOG_MANAGER_DEBUGGING 0

#if LOG_MANAGER_DEBUGGING
#define LogManagerLog(format, ...)NSLog(@"ECLogManager: %@", [NSString stringWithFormat:format, ## __VA_ARGS__])
#else
#define LogManagerLog(...)
#endif


// --------------------------------------------------------------------------
// Private Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic)NSArray* handlersSorted;

// --------------------------------------------------------------------------
// Private Methods
// --------------------------------------------------------------------------

- (void)saveChannelSettings;
- (void)postUpdateNotification;

@end


@implementation ECLogManager

// --------------------------------------------------------------------------
// Notifications
// --------------------------------------------------------------------------

NSString *const LogChannelsChanged = @"LogChannelsChanged";

// --------------------------------------------------------------------------
// Constants
// --------------------------------------------------------------------------

static NSString *const DebugLogSettingsFile = @"ECLoggingDebug";
static NSString *const LogSettingsFile = @"ECLogging";

NSString *const ContextSetting = @"Context";
NSString *const EnabledSetting = @"Enabled";
NSString *const HandlersSetting = @"Handlers";
NSString *const LevelSetting = @"Level";
NSString *const LogManagerSettings = @"ECLogging";
NSString *const ChannelsSetting = @"Channels";
NSString *const DefaultSetting = @"Default";
NSString *const VersionSetting = @"Version";

static NSUInteger kSettingsVersion = 1;

typedef struct 
{
    ECLogContextFlags flag;
    NSString* name;
} ContextFlagInfo;

const ContextFlagInfo kContextFlagInfo[] = 
{
    { ECLogContextDefault, @"Use Default Flags"},
    { ECLogContextFile, @"File" },
    { ECLogContextDate, @"Date"},
    { ECLogContextFunction, @"Function"}, 
    { ECLogContextMessage, @"Message"},
    { ECLogContextName, @"Name"}
};

// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------

@synthesize channels = _channels;
@synthesize defaultContextFlags = _defaultContextFlags;
@synthesize handlers = _handlers;
@synthesize handlersSorted = _handlersSorted;
@synthesize settings = _settings;
@synthesize defaultHandlers = _defaultHandlers;

// --------------------------------------------------------------------------
//! Return the channel with a given name, making it first if necessary.
//! If the channel was created, we register it.
// --------------------------------------------------------------------------

- (ECLogChannel*)registerChannelWithRawName:(const char*)rawName options:(NSDictionary*)options
{
    LogManagerLog(@"registering raw channel with name %s", rawName);
    NSString* name = [ECLogChannel cleanName:rawName];
    return [self registerChannelWithName:name options:options];
}

// --------------------------------------------------------------------------
//! Return the channel with a given name, making it first if necessary.
//! If the channel was created, we register it.
// --------------------------------------------------------------------------

- (ECLogChannel*)registerChannelWithName:(NSString*)name options:(NSDictionary*)options
{
    LogManagerLog(@"registering channel with name %@", name);
    ECLogChannel* channel = self.channels[name];
    if (!channel)
    {
        channel = [[[ECLogChannel alloc] initWithName: name] autorelease];
        channel.enabled = NO;
    }

    if (!channel.setup)
    {
        [self registerChannel:channel];
    }
    
    return channel;
}

// --------------------------------------------------------------------------
//! Post a notification to the default queue to say that the channel list has changed.
//! Make sure that it only gets processed on idle, so that we don't get stuck
//! in an infinite loop if the notification causes another notification to be posted
// --------------------------------------------------------------------------

- (void)postUpdateNotification
{
    NSNotification* notification = [NSNotification notificationWithName: LogChannelsChanged object: self];
    [[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes: nil];
    
}

// --------------------------------------------------------------------------
//! Apply some settings to a channel.
// --------------------------------------------------------------------------

- (void)applySettings:(NSDictionary*)channelSettings toChannel:(ECLogChannel*)channel
{
    channel.enabled = [channelSettings[EnabledSetting] boolValue];
    channel.level = channelSettings[LevelSetting];
    NSNumber* contextValue = channelSettings[ContextSetting];
    channel.context = contextValue ? ((ECLogContextFlags)[contextValue integerValue]): ECLogContextDefault;
    LogManagerLog(@"loaded channel %@ setting enabled: %d", channel.name, channel.enabled);
    
    NSArray* handlerNames = channelSettings[HandlersSetting];
    if (handlerNames)
    {
        for (NSString* handlerName in handlerNames)
        {
            ECLogHandler* handler = self.handlers[handlerName];
            if (handler)
            {
                LogManagerLog(@"added channel %@ handler %@", channel.name, handler.name);
                [channel enableHandler:handler];
            }
        }
    }
    else
    {
        channel.handlers = nil;
    }
}

// --------------------------------------------------------------------------
//! Register a channel with the log manager.
// --------------------------------------------------------------------------

- (void)registerChannel:(ECLogChannel*)channel
{
    LogManagerLog(@"adding channel %@", channel.name);
	self.channels[channel.name] = channel;
	
    if (self.settings)
    {
        NSDictionary* allChannels = self.settings[ChannelsSetting];
        NSDictionary* channelSettings = allChannels[channel.name];
        [self applySettings:channelSettings toChannel:channel];
        
        channel.setup = YES;
    }
    
    [self postUpdateNotification];    
}

// --------------------------------------------------------------------------
//! Regist a channel with the log manager.
// --------------------------------------------------------------------------

- (void)registerHandlers
{
	self.handlers = [NSMutableDictionary dictionary];
	self.defaultHandlers = [NSMutableArray array];
	NSDictionary* allHandlers = self.settings[HandlersSetting];
	if ([allHandlers count] == 0)
	{
		ECLogHandler* handler = [[ECLogHandlerNSLog alloc] init];
		self.handlers[handler.name] = handler;
		[self.defaultHandlers addObject:handler];
		[handler release];
	}
	else
	{
		for (NSString* handlerName in allHandlers)
		{
			Class handlerClass = NSClassFromString(handlerName);
			ECLogHandler* handler = [[handlerClass alloc] init];
			if (handler)
			{
				NSDictionary* handlerSettings = allHandlers[handlerName];
				[self.handlers setObject:handler forKey:handler.name];
				LogManagerLog(@"registered handler %@", handler.name);

				if ([handlerSettings[DefaultSetting] boolValue])
				{
					LogManagerLog(@"add handler %@ to default handlers", handler.name);
					[self.defaultHandlers addObject:handler];
				}

			}
			else
			{
				NSLog(@"unknown log handler class %@", handlerName);
			}
			[handler release];
		}
	}

	self.handlersSorted = [[self.handlers allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


// --------------------------------------------------------------------------
//! Initialise the log manager.
// --------------------------------------------------------------------------

- (id)init
{
	if ((self = [super init])!= nil)
	{
        LogManagerLog(@"initialised log manager");
		[self startup];
	}

	return self;
}

// --------------------------------------------------------------------------
//! Cleanup and release retained objects.
// --------------------------------------------------------------------------

- (void)dealloc
{
	[_channels release];
	[_defaultHandlers release];
	[_handlers release];
	[_handlersSorted release];
	[_settings release];

	[super dealloc];
}

// --------------------------------------------------------------------------
//! Start up the log manager, read settings, etc.
// --------------------------------------------------------------------------

- (void)startup
{
	LogManagerLog(@"starting log manager");

	NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
	self.channels = dictionary;
	[dictionary release];
	self.defaultContextFlags = ECLogContextName | ECLogContextMessage;

	[self loadSettings];
	[self registerHandlers];
}

// --------------------------------------------------------------------------
//! Cleanup and shut down.
// --------------------------------------------------------------------------

- (void)shutdown
{
	[self saveChannelSettings];
	self.channels = nil;
    self.handlers = nil;
    self.settings = nil;

    LogManagerLog(@"log manager shutdown");
}

// --------------------------------------------------------------------------
//! Return the default settings.
// --------------------------------------------------------------------------

- (NSDictionary*)defaultSettings
{
	NSURL* defaultSettingsFile;
#if EC_DEBUG
	defaultSettingsFile = [[NSBundle mainBundle] URLForResource:DebugLogSettingsFile withExtension:@"plist"];
	if (defaultSettingsFile)
	{
		LogManagerLog(@"loaded defaults from %@.plist", DebugLogSettingsFile);
	}
	else
#endif
	{
		defaultSettingsFile = [[NSBundle mainBundle] URLForResource:LogSettingsFile withExtension:@"plist"];
		if (defaultSettingsFile)
		{
			LogManagerLog(@"loaded defaults from %@.plist", LogSettingsFile);
		}
		else
		{
			LogManagerLog(@"couldn't load defaults from %@.plist", LogSettingsFile);
		}
	}

	NSDictionary* defaultSettings = [NSDictionary dictionaryWithContentsOfURL:defaultSettingsFile];

	if (![defaultSettings count])
	{
		NSLog(@"Registering ECLogHandlerNSLog log handler. Add an ECLogging.plist file to your project to customise this behaviour.");
		defaultSettings = [NSMutableDictionary dictionaryWithDictionary:@{ @"Handlers" : @{ @"ECLogHandlerNSLog" : @{ @"Default" : @YES } } }];
	}
	return defaultSettings;
}

// --------------------------------------------------------------------------
//! Load saved channel details.
//! We make and register any channel found in the settings.
// --------------------------------------------------------------------------

- (void)loadSettings
{
    LogManagerLog(@"log manager loading settings");

	NSDictionary* savedSettings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:LogManagerSettings];
	NSDictionary* defaultSettings = [self defaultSettings];
	self.settings = [NSMutableDictionary dictionaryWithDictionary:defaultSettings];
	
	NSUInteger savedVersion = [savedSettings[VersionSetting] unsignedIntegerValue];
	if (savedVersion == kSettingsVersion)
	{
		// use saved channel settings if we have them, otherwise the defaults
		id channels = savedSettings[ChannelsSetting];
		if (!channels)
		{
			channels = defaultSettings[ChannelsSetting];
		}

		// always use list of handlers from the defaults, but merge in saved handler settings
		NSDictionary* defaultHandlers = defaultSettings[HandlersSetting];
		NSDictionary* savedHandlers = savedSettings[HandlersSetting];
		NSMutableDictionary* handlers = [NSMutableDictionary dictionary];
		for (NSString* handlerName in defaultHandlers)
		{
			NSDictionary* savedHandlerSettings = defaultHandlers[handlerName];
			if ([savedHandlerSettings isKindOfClass:[NSDictionary class]])
			{
				NSMutableDictionary* handlerSettings = [NSMutableDictionary dictionaryWithDictionary:savedHandlerSettings];
				[handlerSettings addEntriesFromDictionary:savedHandlers[handlerName]];
				handlers[handlerName] = handlerSettings;
			}
		}
		
		self.settings[ChannelsSetting] = channels;
		self.settings[HandlersSetting] = handlers;
	}

	[self loadChannelSettings];
}

// --------------------------------------------------------------------------
//! Load saved channel details.
//! We make and register any channel found in the settings.
// --------------------------------------------------------------------------

- (void)loadChannelSettings
{
    LogManagerLog(@"log manager loading settings");

	NSDictionary* channelSettings = self.settings[ChannelsSetting];
	for (NSString* channel in [channelSettings allKeys])
	{
		LogManagerLog(@"loaded settings for channel %@", channel);
		[self registerChannelWithName:channel options:nil];
	}
}

// --------------------------------------------------------------------------
//! Save out the channel settings for next time.
// --------------------------------------------------------------------------

- (void)saveChannelSettings
{
    LogManagerLog(@"log manager saving settings");
    
	NSDictionary* defaultSettings = [self defaultSettings];
	NSDictionary* defaultChannelSettings = defaultSettings[ChannelsSetting];
	NSMutableDictionary* allChannelSettings = [[NSMutableDictionary alloc] init];

	for (ECLogChannel* channel in [self.channels allValues])
	{
        NSMutableDictionary* channelSettings = [NSMutableDictionary dictionaryWithDictionary:defaultChannelSettings[channel.name]];
		channelSettings[EnabledSetting] = [NSNumber numberWithBool: channel.enabled];
		channelSettings[ContextSetting] = [NSNumber numberWithInteger: channel.context];
        NSSet* channelHandlers = channel.handlers;
        if (channelHandlers)
        {
            NSMutableArray* handlerNames = [NSMutableArray arrayWithCapacity:[channel.handlers count]];
            for (ECLogHandler* handler in channelHandlers)
            {
                [handlerNames addObject:handler.name];
            }
            channelSettings[HandlersSetting] = handlerNames;
        }
        
        LogManagerLog(@"settings for channel %@:%@", channel.name, channelSettings);

		allChannelSettings[channel.name] = channelSettings;
	}
	
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray* defaultHandlerNames = [NSMutableArray arrayWithCapacity:[self.defaultHandlers count]];
    for (ECLogHandler* handler in self.defaultHandlers)
    {
        [defaultHandlerNames addObject:handler.name];
    }

	NSMutableDictionary* allHandlerSettings = [NSMutableDictionary dictionaryWithCapacity:[self.handlers count]];
	for (NSString* handlerName in self.handlers)
	{
		ECLogHandler* handler = self.handlers[handlerName];
		NSString* handlerClass = NSStringFromClass([handler class]);
		BOOL isDefault = [self.defaultHandlers containsObject:handler];
		allHandlerSettings[handlerClass] = @{ DefaultSetting : @(isDefault) };
	}

    NSDictionary* allSettings =
		@{
		VersionSetting : @(kSettingsVersion),
		ChannelsSetting : allChannelSettings,
		HandlersSetting : allHandlerSettings
		};

    [defaults setObject:allSettings forKey:LogManagerSettings];
    [defaults synchronize];

	[allChannelSettings release];

}

// --------------------------------------------------------------------------
//! Log to all valid handlers for a channel
// --------------------------------------------------------------------------

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
    // if no handlers specified, use them all
    NSArray* handlersToUse = [channel.handlers allObjects];
    if (!handlersToUse)
    {
        handlersToUse = self.defaultHandlers;
    }
    
	for (ECLogHandler* handler in handlersToUse)
	{
		va_list arg_copy;
		va_copy(arg_copy, arguments);
		[handler logFromChannel:channel withObject:object arguments:arg_copy context:context];
	}
}

// --------------------------------------------------------------------------
//! Turn on every channel.
// --------------------------------------------------------------------------

- (void)enableAllChannels
{
    LogManagerLog(@"enabling all channels");
    
	for (ECLogChannel* channel in [self.channels allValues])
	{
        [channel enable];
	}
    [self saveChannelSettings];
}

// --------------------------------------------------------------------------
//! Turn off every channel.
// --------------------------------------------------------------------------

- (void)disableAllChannels
{
	for (ECLogChannel* channel in [self.channels allValues])
	{
        [channel disable];
	}
    [self saveChannelSettings];
}

// --------------------------------------------------------------------------
//! Revert all channels to default settings.
// --------------------------------------------------------------------------

- (void)resetChannel:(ECLogChannel *)channel
{
    LogManagerLog(@"reset channel %@", channel.name);
    NSDictionary* defaultSettings = [self defaultSettings];
	NSDictionary* allChannelSettings = defaultSettings[ChannelsSetting];
    [self applySettings:allChannelSettings[channel.name] toChannel:channel];
    [self saveChannelSettings];
}


// --------------------------------------------------------------------------
//! Revert all channels to default settings.
// --------------------------------------------------------------------------

- (void)resetAllChannels
{
    LogManagerLog(@"reset all channels");
    NSDictionary* defaultSettings = [self defaultSettings];
	NSDictionary* allChannelSettings = defaultSettings[ChannelsSetting];
	for (NSString* name in self.channels)
	{
        ECLogChannel* channel = self.channels[name];
        [self applySettings:allChannelSettings[name] toChannel:channel];
	}
    [self saveChannelSettings];
}

// --------------------------------------------------------------------------
//! Revert all channels to default settings.
// --------------------------------------------------------------------------

- (void)resetAllSettings
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LogManagerSettings];
	[self loadSettings];
	[self registerHandlers];
	[self resetAllChannels];
	[self postUpdateNotification];
}

// --------------------------------------------------------------------------
//! Return an array of channels sorted by name.
// --------------------------------------------------------------------------

- (NSArray*)channelsSortedByName
{
    NSArray* channelObjects = [self.channels allValues];
    NSArray* sorted = [channelObjects sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    return sorted;
}

// --------------------------------------------------------------------------
//! Return a text label for a context info flag.
// --------------------------------------------------------------------------

- (NSString*)contextFlagNameForIndex:(NSUInteger)index
{
    return kContextFlagInfo[index].name;
}

// --------------------------------------------------------------------------
//! Return a context info flag.
// --------------------------------------------------------------------------

- (ECLogContextFlags)contextFlagValueForIndex:(NSUInteger)index
{
    return kContextFlagInfo[index].flag;
}

// --------------------------------------------------------------------------
//! Return the number of named context info flags.
// --------------------------------------------------------------------------

- (NSUInteger)contextFlagCount
{
    return sizeof(kContextFlagInfo)/ sizeof(ContextFlagInfo);
}

// --------------------------------------------------------------------------
//! Return the handler for a given index.
//! Index 0 represents the Default Handlers, and returns nil.
// --------------------------------------------------------------------------

- (ECLogHandler*)handlerForIndex:(NSUInteger)index
{
    ECLogHandler* result;
    if (index == 0)
    {
        result = nil;
    }
    else
    {
        result = [self.handlersSorted objectAtIndex:index - 1];
    }
    
    return result;
}


// --------------------------------------------------------------------------
//! Return the name of a given handler index.
//! Index 0 represents the Default Handlers, and returns "Use Defaults".
// --------------------------------------------------------------------------

- (NSString*)handlerNameForIndex:(NSUInteger)index
{
    NSString* result;
    if (index == 0)
    {
        result = @"Use Default Handlers";
    }
    else
    {
        ECLogHandler* handler = [self.handlersSorted objectAtIndex:index - 1];
        result = handler.name;
    }
    
    return result;
}


// --------------------------------------------------------------------------
//! Return the number of handler indexes.
//! This is the number of handlers, plus one (or the "Use Defaults" label).
// --------------------------------------------------------------------------

- (NSUInteger)handlerCount
{
    return [self.handlers count] + 1;
}

// --------------------------------------------------------------------------
//! Return all the handlers.
// --------------------------------------------------------------------------

- (NSArray*)handlersSortedByName
{
	return self.handlersSorted;
}

- (BOOL)handlerIsDefault:(ECLogHandler*)handler
{
	return [self.defaultHandlers containsObject:handler];
}

- (void)handler:(ECLogHandler*)handler setDefault:(BOOL)value
{
	[self.defaultHandlers removeObject:handler];
	if (value)
	{
		[self.defaultHandlers addObject:handler];
	}
}

@end
