// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManager.h"

@interface ECLogManager ()

// --------------------------------------------------------------------------
// Private Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic) NSArray* handlersSorted;
@property (strong, nonatomic) NSDictionary* defaultSettings;


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

static NSString* const ChannelsKey = @"Channels";
static NSString* const ContextKey = @"Context";
static NSString* const DefaultKey = @"Default";
static NSString* const EnabledKey = @"Enabled";
static NSString* const ForceChannelEnabledKey = @"ECLoggingEnableChannel";
static NSString* const ForceChannelDisabledKey = @"ECLoggingDisableChannel";
static NSString* const ForceDebugMenuKey = @"ECLoggingMenu";
static NSString* const HandlersKey = @"Handlers";
static NSString* const InstallDebugMenuKey = @"InstallMenu";
static NSString* const LevelKey = @"Level";
static NSString* const LogManagerSettingsKey = @"ECLogging";
static NSString* const OptionsKey = @"Options";
static NSString* const ResetSettingsKey = @"ECLoggingReset";
static NSString *const SuppressedAssertionsKey = @"SuppressedAssertions";
static NSString* const VersionKey = @"Version";

static NSUInteger kSettingsVersion = 4;

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
//! Initialise the log manager.
// --------------------------------------------------------------------------

- (instancetype)init
{
	if ((self = [super init]) != nil)
	{
		[self startup];
	}

	return self;
}

/**
 Start up the log manager, read settings, etc.
 */

- (void)startup
{
	[self loadSettings];

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


- (void)shutdown
{
	id<ECLogManagerDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(logManagerWillShutdown:)])
		[delegate logManagerWillShutdown:self];

	self.settings = nil;

}

- (void)finishStartup
{
	[self notifyDelegateOfStartup];
}

- (void)notifyDelegateOfStartup
{
	id<ECLogManagerDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(logManagerDidStartup:)])
	{
		[delegate logManagerDidStartup:self];
	}
}

- (void)mergeSettings:(NSMutableDictionary*)settings withOverrides:(NSDictionary*)overrides name:(ec_nullable NSString*)name {
	if (overrides) {
		if (name) {
		}

		NSArray* keys = overrides.allKeys;
		for (NSString* key in keys) {
			id existing = settings[key];
			id override = overrides[key];
			if (existing && [existing isKindOfClass:[NSDictionary class]] && [override isKindOfClass:[NSDictionary class]]) {
				if ([key isEqualToString:HandlersKey] || [key isEqualToString:ChannelsKey]) {
					NSMutableDictionary* merged = [existing mutableCopy];
					[self mergeSettings:merged withOverrides:override name:[NSString stringWithFormat:@"%@.%@", name, key]];
					override = merged;
				}
			}

			settings[key] = override;
		}
	}
}

- (void)mergeSettings:(NSMutableDictionary*)settings fromURL:(NSURL*)url {
	if (url) {
		NSDictionary* overrides = [NSDictionary dictionaryWithContentsOfURL:url];
		[self mergeSettings:settings withOverrides:overrides name:[url lastPathComponent]];
	}
}

- (void)mergeSettings:(NSMutableDictionary*)settings fromBundle:(NSBundle*)bundle
{
	// we look in the bundle for a settings file, and also in the Info.plist for a settings entry
	// the settings in the Info.plist override any in the file (but ideally there should just be one or the other)
	[self mergeSettings:settings fromURL:[bundle URLForResource:LogSettingsFile withExtension:@"plist"]];
	[self mergeSettings:settings withOverrides:bundle.infoDictionary[LogSettingsFile] name:LogSettingsFile];

#if EC_DEBUG
	// for debug builds, we then override these settings with additional ones from an extra optional debug-only file / Info.plist entry
	[self mergeSettings:settings fromURL:[bundle URLForResource:DebugLogSettingsFile withExtension:@"plist"]];
	[self mergeSettings:settings withOverrides:bundle.infoDictionary[DebugLogSettingsFile] name:DebugLogSettingsFile];
#endif
}

// --------------------------------------------------------------------------
//! Return the default settings.
// --------------------------------------------------------------------------

- (NSDictionary*)defaultSettings
{
	if (!_defaultSettings) {
		// start with some defaults
		NSDictionary* defaults = @{
								   VersionKey : @(kSettingsVersion),
								   HandlersKey: @{ @"ECLogHandlerNSLog": @{ @"Default": @YES } },
								   ChannelsKey: @{}
								   };

		NSMutableDictionary* settings = [defaults mutableCopy];

		// try loading settings from the main bundle first
		NSBundle* mainBundle = [NSBundle mainBundle];
		[self mergeSettings:settings fromBundle:mainBundle];

		// also try our bundle if it's different (we might be in a plugin)
		NSBundle* ourBundle = [NSBundle bundleForClass:[self class]];
		if (ourBundle != mainBundle) {
			[self mergeSettings:settings fromBundle:ourBundle];
		}

		// if we're still just using the defaults, report that fact
		if ([settings isEqualToDictionary:defaults])
		{
			NSLog(@"Registering ECLogHandlerNSLog log handler. Add an ECLogging.plist file to your project to customise this behaviour.");
		}

		_defaultSettings = settings;
	}

	return _defaultSettings;
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

	NSMutableDictionary* settings = [[self defaultSettings] mutableCopy];
	self.settings = settings;

	NSUInteger expectedVersion = [self expectedSettingsVersionWithDefaultSettings:settings];
	NSUInteger savedVersion = [savedSettings[VersionKey] unsignedIntegerValue];
	if (savedVersion == expectedVersion)
	{
		// any user settings override the defaults
		[self mergeSettings:settings withOverrides:savedSettings name:@"Saved Settings"];
	}

	// the showMenu property is read/set here in generic code, but it's up to the
	// platform specific UI support to interpret it
	BOOL forceMenu = [userSettings boolForKey:ForceDebugMenuKey];
	if (forceMenu) {
	}
	self.showMenu = (forceMenu || [self.settings[InstallDebugMenuKey] boolValue]);
}


- (NSDictionary*)options
{
	return self.settings[OptionsKey];
}



// --------------------------------------------------------------------------
//! Revert all channels to default settings.
// --------------------------------------------------------------------------

- (void)resetAllSettings
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:LogManagerSettingsKey];
	[self loadSettings];
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

- (BOOL)isAssertionSuppressedForKey:(NSString*)key {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSDictionary* suppressedAssertions = [defaults valueForKey:SuppressedAssertionsKey];
	return [suppressedAssertions[key] boolValue];
}

- (void)suppressAssertionForKey:(NSString*)key {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* suppressedAssertions = [([defaults valueForKey:SuppressedAssertionsKey] ?: @{}) mutableCopy] ;
	suppressedAssertions[key] = @(YES);
	[defaults setValue:suppressedAssertions forKey:SuppressedAssertionsKey];
}

- (void)resetAllAssertions {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:SuppressedAssertionsKey];
}

- (void)showUI {
	id<ECLogManagerDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(showUIForLogManager:)]) {
		[delegate showUIForLogManager:self];
	 }
}

@end
