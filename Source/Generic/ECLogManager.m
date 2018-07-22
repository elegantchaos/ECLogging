// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManager.h"

@interface ECLogManager ()
@property (strong, nonatomic) NSDictionary* defaultSettings;
@property (strong, nonatomic, nullable) NSDictionary* settings;

@end


@implementation ECLogManager

// --------------------------------------------------------------------------
// Constants
// --------------------------------------------------------------------------

static NSString* const DebugLogSettingsFile = @"ECLoggingDebug";
static NSString* const LogSettingsFile = @"ECLogging";

static NSString* const InstallDebugMenuKey = @"InstallMenu";
static NSString* const OptionsKey = @"Options";

// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------

static ECLogManager* gSharedInstance = nil;

/// --------------------------------------------------------------------------
/// Return the shared instance.
/// --------------------------------------------------------------------------

+ (ECLogManager*)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [ECLogManager new];
	});

	return gSharedInstance;
}

// --------------------------------------------------------------------------
//! Initialise the log manager.
// --------------------------------------------------------------------------

- (instancetype)init {
	self = [super init];
	if (self) {
		[self startup];
	}
	return self;
}

/**
 Start up the log manager, read settings, etc.
 */

- (void)startup {
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

- (void)finishStartup {
	[self notifyDelegateOfStartup];
}

- (void)notifyDelegateOfStartup {
	id<ECLogManagerDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(logManagerDidStartup:)]) {
		[delegate logManagerDidStartup:self];
	}
}

- (void)mergeSettings:(NSMutableDictionary*)settings withOverrides:(NSDictionary*)overrides name:(nullable NSString*)name {
	[settings addEntriesFromDictionary:overrides];
}

- (void)mergeSettings:(NSMutableDictionary*)settings fromURL:(NSURL*)url {
	if (url) {
		NSDictionary* overrides = [NSDictionary dictionaryWithContentsOfURL:url];
		[self mergeSettings:settings withOverrides:overrides name:[url lastPathComponent]];
	}
}

// --------------------------------------------------------------------------
//! Return the default settings.
// --------------------------------------------------------------------------

- (NSDictionary*)defaultSettings {
	if (!_defaultSettings) {
		// start with some defaults
		NSMutableDictionary* settings = [NSMutableDictionary new];

		// try loading settings from the main bundle first
		NSBundle* bundle = [NSBundle mainBundle];
		
		// we look in the bundle for a settings file, and also in the Info.plist for a settings entry
		// the settings in the Info.plist override any in the file (but ideally there should just be one or the other)
		[self mergeSettings:settings fromURL:[bundle URLForResource:LogSettingsFile withExtension:@"plist"]];
		[self mergeSettings:settings withOverrides:bundle.infoDictionary[LogSettingsFile] name:LogSettingsFile];
		
#if EC_DEBUG
		// for debug builds, we then override these settings with additional ones from an extra optional debug-only file / Info.plist entry
		[self mergeSettings:settings fromURL:[bundle URLForResource:DebugLogSettingsFile withExtension:@"plist"]];
		[self mergeSettings:settings withOverrides:bundle.infoDictionary[DebugLogSettingsFile] name:DebugLogSettingsFile];
#endif
		
		_defaultSettings = settings;
	}

	return _defaultSettings;
}

// --------------------------------------------------------------------------
//! Load saved channel details.
//! We make and register any channel found in the settings.
// --------------------------------------------------------------------------

- (void)loadSettings {
	self.settings = [self defaultSettings];

	// the showMenu property is read/set here in generic code, but it's up to the
	// platform specific UI support to interpret it
	self.showMenu = [self.settings[InstallDebugMenuKey] boolValue];
}

- (NSDictionary*)options {
	return self.settings[OptionsKey];
}

- (void)showUI {
	id<ECLogManagerDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(showUIForLogManager:)]) {
		[delegate showUIForLogManager:self];
	 }
}

@end
