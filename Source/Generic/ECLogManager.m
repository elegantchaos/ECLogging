// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManager.h"
#import "ECOptionsMenu.h"

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








// --------------------------------------------------------------------------
// Properties
// --------------------------------------------------------------------------


/// --------------------------------------------------------------------------
/// Return the top level Debug menu item.
/// If it doesn't already exist, we add one.
/// --------------------------------------------------------------------------



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
	
#if EC_DEBUG
	[[NSOperationQueue mainQueue] addOperationWithBlock:^{
		[self installDebugSubmenuWithTitle:NSLocalizedString(@"Options", @"options submenu title") class:[ECOptionsMenu class]];
		NSMenu* utilities = [self installDebugSubmenuWithTitle:NSLocalizedString(@"Utilities", @"utilities submenu title") class:[NSMenu class]];
		[utilities addItemWithTitle:NSLocalizedString(@"Reveal Application Support", @"show the application support folder in the finder") action:@selector(revealApplicationSupport:) keyEquivalent:@""].target = self;
	}];
#endif
}

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

- (NSMenuItem*)debugMenuItem
{
	NSMenuItem* result;
	
	NSString* title = NSLocalizedString(@"Debug", @"Debug menu title");
	NSMenu* menubar = [NSApp mainMenu];
	result = [menubar itemWithTitle:title];
	if (!result)
	{
		NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
		result = item;
		
		NSMenu* menu = [[NSMenu alloc] initWithTitle:title];
		item.submenu = menu;
		
		[menubar addItem:item];
	}
	
	return result;
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

- (void)mergeSettings:(NSMutableDictionary*)settings fromURL:(NSURL*)url {
	if (url) {
		NSDictionary* overrides = [NSDictionary dictionaryWithContentsOfURL:url];
		[settings addEntriesFromDictionary:overrides];
	}
}






- (NSDictionary*)options {
	return self.settings[OptionsKey];
}

@end
