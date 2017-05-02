// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogChannel.h"
#import "ECLogHandlerNSLog.h"
#import "ECLogManager.h"

@interface ECLogManager ()

// Turn this setting on to output debug message on the log manager itself, using NSLog
#define LOG_MANAGER_DEBUGGING 0

#if LOG_MANAGER_DEBUGGING
#define LogManagerLog(format, ...) NSLog(@"ECLogManager: %@", [NSString stringWithFormat:format, ##__VA_ARGS__])
#else
#define LogManagerLog(...)
#endif


// --------------------------------------------------------------------------
// Private Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic) NSArray* handlersSorted;

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

NSString* const LogChannelsChanged = @"LogChannelsChanged";

// --------------------------------------------------------------------------
// Constants
// --------------------------------------------------------------------------

static NSString* const DebugLogSettingsFile = @"ECLoggingDebug";
static NSString* const LogSettingsFile = @"ECLogging";

static NSString* const ContextKey = @"Context";
static NSString* const EnabledKey = @"Enabled";
static NSString* const HandlersKey = @"Handlers";
static NSString* const OptionsKey = @"Options";
static NSString* const LevelKey = @"Level";
static NSString* const LogManagerSettingsKey = @"ECLogging";
static NSString* const ChannelsKey = @"Channels";
static NSString* const DefaultKey = @"Default";
static NSString* const VersionKey = @"Version";
static NSString* const ResetSettingsKey = @"ECLoggingReset";
static NSString* const ForceChannelEnabledKey = @"ECLoggingEnableChannel";
static NSString* const ForceChannelDisabledKey = @"ECLoggingDisableChannel";
static NSString* const ForceDebugMenuKey = @"ECLoggingMenu";
static NSString* const InstallDebugMenuKey = @"InstallMenu";

static NSUInteger kSettingsVersion = 2;

typedef struct
{
	ECLogContextFlags flag;
	NSString* __unsafe_unretained name;
} ContextFlagInfo;

const ContextFlagInfo kContextFlagInfo[] = {
	{ ECLogContextDefault, @"Use Default Flags" },
	{ ECLogContextFile, @"File" },
	{ ECLogContextDate, @"Date" },
	{ ECLogContextFunction, @"Function" },
	{ ECLogContextMessage, @"Message" },
	{ ECLogContextName, @"Name" },
	{ ECLogContextMeta, @"Meta" }
};

#define TEST_ERROR 0 // enable this for a deliberate compiler error (handy when testing build reporting scripts)
#define TEST_WARNING 0 // enable this for a deliberate compiler warning (handy when testing build reporting scripts)
#define TEST_ANALYZER 0 // enable this for a deliberate analyser warning (handy when testing build reporting scripts)

#if TEST_ERROR
xyz
#endif


// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------

static ECLogManager* gSharedInstance = nil;

/// --------------------------------------------------------------------------
/// Return the shared instance.
/// --------------------------------------------------------------------------

+ (ECLogManager*)sharedInstance
{
#if TEST_WARNING
	int x = 10;
#endif
#if TEST_ANALYZER
	NSString* string = @"blah";
	string = @"doodah";
#endif

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [ECLogManager new];
	});

	return gSharedInstance;
}

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
		channel = [[ECLogChannel alloc] initWithName:name];
		channel.enabled = NO;
	}

	if (!channel.setup)
	{
		channel = [self registerChannel:channel];
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
	NSNotification* notification = [NSNotification notificationWithName:LogChannelsChanged object:self];
	[[NSNotificationQueue defaultQueue] enqueueNotification:notification postingStyle:NSPostWhenIdle coalesceMask:NSNotificationCoalescingOnName forModes:nil];
}

// --------------------------------------------------------------------------
//! Apply some settings to a channel.
// --------------------------------------------------------------------------

- (void)applySettings:(NSDictionary*)channelSettings toChannel:(ECLogChannel*)channel
{
	channel.enabled = [channelSettings[EnabledKey] boolValue];
	channel.level = channelSettings[LevelKey];
	NSNumber* contextValue = channelSettings[ContextKey];
	channel.context = contextValue ? ((ECLogContextFlags)[contextValue integerValue]) : ECLogContextDefault;
	LogManagerLog(@"loaded channel %@ setting enabled: %d", channel.name, channel.enabled);

	NSArray* handlerNames = channelSettings[HandlersKey];
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

- (ECLogChannel*)registerChannel:(ECLogChannel*)channel
{
	ECLogChannel* result = self.channels[channel.name];
	if (result)
	{
		LogManagerLog(@"channel %@ already exists", channel.name);
	}
	else
	{
		LogManagerLog(@"adding channel %@", channel.name);

		result = channel;
		self.channels[channel.name] = channel;

		if (self.settings)
		{
			NSDictionary* allChannels = self.settings[ChannelsKey];
			NSDictionary* channelSettings = allChannels[channel.name];
			[self applySettings:channelSettings toChannel:channel];

			channel.setup = YES;
		}

		[self postUpdateNotification];
	}

	return result;
}

// --------------------------------------------------------------------------
//! Regist a channel with the log manager.
// --------------------------------------------------------------------------

- (void)registerHandlers
{
	self.handlers = [NSMutableDictionary dictionary];
	self.defaultHandlers = [NSMutableArray array];
	NSDictionary* allHandlers = self.settings[HandlersKey];
	if ([allHandlers count] == 0)
	{
		ECLogHandler* handler = [[ECLogHandlerNSLog alloc] init];
		self.handlers[handler.name] = handler;
		[self.defaultHandlers addObject:handler];
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
				(self.handlers)[handler.name] = handler;
				LogManagerLog(@"registered handler %@", handler.name);

				if ([handlerSettings[DefaultKey] boolValue])
				{
					LogManagerLog(@"add handler %@ to default handlers", handler.name);
					[self.defaultHandlers addObject:handler];
				}
			}
			else
			{
				NSLog(@"unknown log handler class %@", handlerName);
			}
		}
	}

	self.handlersSorted = [[self.handlers allValues] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


// --------------------------------------------------------------------------
//! Initialise the log manager.
// --------------------------------------------------------------------------

- (instancetype)init
{
	if ((self = [super init]) != nil)
	{
		LogManagerLog(@"initialised log manager");
		[self startup];
	}

	return self;
}

// --------------------------------------------------------------------------
//! Cleanup and release retained objects.
// --------------------------------------------------------------------------


// --------------------------------------------------------------------------
//! Start up the log manager, read settings, etc.
// --------------------------------------------------------------------------

- (void)startup
{
	LogManagerLog(@"starting log manager");

	NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
	self.channels = dictionary;
	self.defaultContextFlags = ECLogContextName | ECLogContextMessage | ECLogContextMeta;

	[self loadSettings];
	[self registerHandlers];
	[self loadChannelSettings];

	// The log manager is created on demand, the first time that a channel needs to register itself.
	// This allows channels to be declared and used in the simplest possible way, and to work in code
	// that runs early.
	// Since this can be before main() is called, and definitely before something nice and high level
	// like applicationWillFinishLaunching has been called, the client application won't have an opportunity
	// to set a delegate before startup is run.
	// As a workaround for this, we defer the final parts of the startup until the main runloop is in action.
	// This gives a window during which the client can set a delegate and adjust some other settings.

	dispatch_async(dispatch_get_main_queue(), ^{
		[self finishStartup];
	});
}

// --------------------------------------------------------------------------
//! Cleanup and shut down.
// --------------------------------------------------------------------------

- (void)shutdown
{
	id<ECLogManagerDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(logManagerWillShutdown:)])
		[delegate logManagerWillShutdown:self];

	[self saveChannelSettings];
	self.channels = nil;
	self.handlers = nil;
	self.settings = nil;

	LogManagerLog(@"log manager shutdown");
}

- (void)finishStartup
{
	[self processForcedChannels];
	[self notifyDelegateOfStartup];
}

- (void)processForcedChannels
{
	NSString* enabledChannel = [[NSUserDefaults standardUserDefaults] stringForKey:ForceChannelEnabledKey];
	if (enabledChannel)
	{
		ECLogChannel* channel = self.channels[enabledChannel];
		if (!channel) {
			channel = [self registerChannelWithName:enabledChannel options:nil];
		}
		[channel enable];
	}

	NSString* disabledChannel = [[NSUserDefaults standardUserDefaults] stringForKey:ForceChannelDisabledKey];
	if (disabledChannel)
	{
		ECLogChannel* channel = self.channels[disabledChannel];
		[channel disable];
	}

	if (enabledChannel || disabledChannel)
	{
		[self saveChannelSettings];
	}
}

- (void)notifyDelegateOfStartup
{
	id<ECLogManagerDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(logManagerDidStartup:)])
	{
		[delegate logManagerDidStartup:self];
	}
}

- (NSDictionary*)settingsFromBundle:(NSBundle*)bundle
{
	NSURL* url;
#if EC_DEBUG
	url = [bundle URLForResource:DebugLogSettingsFile withExtension:@"plist"];
	if (url)
	{
		LogManagerLog(@"loaded defaults from %@.plist", DebugLogSettingsFile);
	}
	else
#endif
	{
		url = [bundle URLForResource:LogSettingsFile withExtension:@"plist"];
		if (url)
		{
			LogManagerLog(@"loaded defaults from %@.plist", LogSettingsFile);
		}
		else
		{
			LogManagerLog(@"couldn't load defaults from %@.plist", LogSettingsFile);
		}
	}

	NSDictionary* result = nil;
	if (url) {
		result = [NSDictionary dictionaryWithContentsOfURL:url];
	}

	if (![result count])
	{
#if EC_DEBUG
		result = bundle.infoDictionary[DebugLogSettingsFile];
#endif
		if (![result count])
		{
			result = bundle.infoDictionary[LogSettingsFile];
		}
	}

	return result;
}

// --------------------------------------------------------------------------
//! Return the default settings.
// --------------------------------------------------------------------------

- (NSDictionary*)defaultSettings
{
	// try loading settings from the main bundle first
	NSDictionary* defaultSettings = [self settingsFromBundle:[NSBundle mainBundle]];

	// if that doesn't work, try our bundle (we might be in a plugin)
	if (![defaultSettings count])
		defaultSettings = [self settingsFromBundle:[NSBundle bundleForClass:[self class]]];

	// if that doesn't work, use some defaults
	if (![defaultSettings count])
	{
		NSLog(@"Registering ECLogHandlerNSLog log handler. Add an ECLogging.plist file to your project to customise this behaviour.");
		defaultSettings = [NSMutableDictionary dictionaryWithDictionary:@{ @"Handlers": @{ @"ECLogHandlerNSLog": @{ @"Default": @YES } } }];
	}
	return defaultSettings;
}

- (NSUInteger)expectedSettingsVersionWithDefaultSettings:(NSDictionary*)defaultSettings
{
	NSUInteger expectedVersion = [defaultSettings[VersionKey] unsignedIntegerValue];
	if (expectedVersion == 0)
		expectedVersion = kSettingsVersion;

	return expectedVersion;
}

// --------------------------------------------------------------------------
//! Load saved channel details.
//! We make and register any channel found in the settings.
// --------------------------------------------------------------------------

- (void)loadSettings
{
	LogManagerLog(@"log manager loading settings");

	NSUserDefaults* userSettings = [NSUserDefaults standardUserDefaults];
	BOOL skipSavedSettings = [userSettings boolForKey:ResetSettingsKey];
	NSDictionary* savedSettings;
	if (skipSavedSettings)
	{
		[userSettings removeObjectForKey:LogManagerSettingsKey];
		savedSettings = nil;
	}
	else
	{
		savedSettings = [userSettings dictionaryForKey:LogManagerSettingsKey];
	}

	NSDictionary* defaultSettings = [self defaultSettings];
	self.settings = [NSMutableDictionary dictionaryWithDictionary:defaultSettings];

	NSUInteger expectedVersion = [self expectedSettingsVersionWithDefaultSettings:defaultSettings];
	NSUInteger savedVersion = [savedSettings[VersionKey] unsignedIntegerValue];
	if (savedVersion == expectedVersion)
	{
		// use saved channel settings if we have them, otherwise the defaults
		id channels = savedSettings[ChannelsKey];
		if (!channels)
		{
			channels = defaultSettings[ChannelsKey];
		}

		// always use list of handlers from the defaults, but merge in saved handler settings
		NSDictionary* defaultHandlers = defaultSettings[HandlersKey];
		NSDictionary* savedHandlers = savedSettings[HandlersKey];
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

		self.settings[ChannelsKey] = channels;
		self.settings[HandlersKey] = handlers;
	}

	// the showMenu property is read/set here in generic code, but it's up to the
	// platform specific UI support to interpret it
	BOOL forceMenu = [userSettings boolForKey:ForceDebugMenuKey];
	self.showMenu = (forceMenu || [self.settings[InstallDebugMenuKey] boolValue]);
}

// --------------------------------------------------------------------------
//! Load saved channel details.
//! We make and register any channel found in the settings.
// --------------------------------------------------------------------------

- (void)loadChannelSettings
{
	LogManagerLog(@"log manager loading settings");

	NSDictionary* channelSettings = self.settings[ChannelsKey];
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
	NSDictionary* defaultChannelSettings = defaultSettings[ChannelsKey];
	NSMutableDictionary* allChannelSettings = [[NSMutableDictionary alloc] init];

	for (ECLogChannel* channel in [self.channels allValues])
	{
		NSMutableDictionary* channelSettings = [NSMutableDictionary dictionaryWithDictionary:defaultChannelSettings[channel.name]];
		channelSettings[EnabledKey] = @(channel.enabled);
		channelSettings[ContextKey] = @(channel.context);
		NSSet* channelHandlers = channel.handlers;
		if (channelHandlers)
		{
			NSMutableArray* handlerNames = [NSMutableArray arrayWithCapacity:[channel.handlers count]];
			for (ECLogHandler* handler in channelHandlers)
			{
				[handlerNames addObject:handler.name];
			}
			channelSettings[HandlersKey] = handlerNames;
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
		allHandlerSettings[handlerClass] = @{ DefaultKey: @(isDefault) };
	}

	NSDictionary* allSettings =
	    @{
		    VersionKey: @([self expectedSettingsVersionWithDefaultSettings:defaultSettings]),
		    ChannelsKey: allChannelSettings,
		    HandlersKey: allHandlerSettings
		};

	[defaults setObject:allSettings forKey:LogManagerSettingsKey];
	[defaults synchronize];
}

- (NSDictionary*)optionsSettings
{
	return self.settings[OptionsKey];
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

	ECLogChannel* parent = channel.parent;
	if (parent) {
		[self logFromChannel:parent withObject:object arguments:arguments context:context];
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

- (void)resetChannel:(ECLogChannel*)channel
{
	LogManagerLog(@"reset channel %@", channel.name);
	NSDictionary* defaultSettings = [self defaultSettings];
	NSDictionary* allChannelSettings = defaultSettings[ChannelsKey];
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
	NSDictionary* allChannelSettings = defaultSettings[ChannelsKey];
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
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LogManagerSettingsKey];
	[self loadSettings];
	[self registerHandlers];
	[self loadChannelSettings];
	[self resetAllChannels];
	[self postUpdateNotification];
}

// --------------------------------------------------------------------------
//! Return an array of channels sorted by name.
// --------------------------------------------------------------------------

- (NSArray*)channelsSortedByName
{
	NSArray* channelObjects = [self.channels allValues];
	NSArray* sorted = [channelObjects sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];

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
	return sizeof(kContextFlagInfo) / sizeof(ContextFlagInfo);
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
		result = (self.handlersSorted)[index - 1];
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
		ECLogHandler* handler = (self.handlersSorted)[index - 1];
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

- (BOOL)debugChannelsAreEnabled {
#if EC_DEBUG
	return YES;
#else
	return NO;
#endif
}

- (BOOL)assertionsAreEnabled {
#if NS_BLOCK_ASSERTIONS
	return NO;
#else
	return YES;
#endif
}

@end
