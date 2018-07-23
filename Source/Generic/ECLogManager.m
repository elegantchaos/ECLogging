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

static NSString* const DebugLogSettingsFile = @"ECLoggingDebug";
static NSString* const LogSettingsFile = @"ECLogging";

static NSString* const OptionsKey = @"Options";

static ECLogManager* gSharedInstance = nil;

+ (ECLogManager*)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [ECLogManager new];
	});

	return gSharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		[self startup];
	}
	return self;
}

/** Start up the log manager, read settings, etc. */
- (void)startup {
	self.settings = [self defaultSettings];

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

- (void)mergeSettings:(NSMutableDictionary*)settings fromURL:(NSURL*)url {
	if (url) {
		NSDictionary* overrides = [NSDictionary dictionaryWithContentsOfURL:url];
		[settings addEntriesFromDictionary:overrides];
	}
}

- (NSDictionary*)defaultSettings {
	if (!_defaultSettings) {
		NSBundle *bundle = [NSBundle mainBundle];
		NSMutableDictionary* settings = [NSMutableDictionary new];
		
		// we look in the bundle for a settings file, and also in the Info.plist for a settings entry
		// the settings in the Info.plist override any in the file (but ideally there should just be one or the other)
		[self mergeSettings:settings fromURL:[bundle URLForResource:LogSettingsFile withExtension:@"plist"]];
		
#if EC_DEBUG
		// for debug builds, we then override these settings with additional ones from an extra optional debug-only file / Info.plist entry
		[self mergeSettings:settings fromURL:[bundle URLForResource:DebugLogSettingsFile withExtension:@"plist"]];
#endif
		
		_defaultSettings = settings;
	}

	return _defaultSettings;
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
