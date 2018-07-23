// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogManager.h"
#import "ECOptionsMenu.h"

@interface ECLogManager ()
@property (strong, nonatomic, nullable) NSDictionary* settings;
@end

@implementation ECLogManager

static NSString* const LogSettingsFile = @"ECLogging";
static NSString* const OptionsKey = @"Options";

static ECLogManager* gSharedInstance = nil;

+ (ECLogManager*)sharedInstance {
	//TODO: BCSingleton exists
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		gSharedInstance = [ECLogManager new];
	});

	return gSharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		self.settings = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] URLForResource:LogSettingsFile withExtension:@"plist"]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self finishStartup];
		});
	}
	return self;
}

- (void)finishStartup {
#if EC_DEBUG
	[self installDebugSubmenuWithTitle:NSLocalizedString(@"Options", @"options submenu title") class:[ECOptionsMenu class]];
	NSMenu* utilities = [self installDebugSubmenuWithTitle:NSLocalizedString(@"Utilities", @"utilities submenu title") class:[NSMenu class]];
	[utilities addItemWithTitle:NSLocalizedString(@"Reveal Application Support", @"show the application support folder in the finder") action:@selector(revealApplicationSupport:) keyEquivalent:@""].target = self;
#endif
}

- (NSMenu *)installDebugSubmenuWithTitle:(NSString *)title class:(Class)menuClass {
	NSMenuItem *debugItem = [self debugMenuItem];
	NSMenuItem *submenuItem = [debugItem.submenu itemWithTitle:title];
	if (!submenuItem) {
		submenuItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
		
		id menu = [[menuClass alloc] initWithTitle:title];
		if ([menu respondsToSelector:@selector(setupAsRootMenu)])
			[menu setupAsRootMenu];
		
		submenuItem.submenu = menu;
		
		[debugItem.submenu addItem:submenuItem];
	}
	return submenuItem.submenu;
}

- (NSMenuItem *)debugMenuItem {
	NSString *title = @"Debug"; //deliberately not localised because its for internal use
	NSMenuItem *item = [[NSApp mainMenu] itemWithTitle:title];
	
	if (!item) {
		item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
		item.submenu = [[NSMenu alloc] initWithTitle:title];
		[[NSApp mainMenu] addItem:item];
	}
	
	return item;
}

- (NSDictionary*)options {
	return self.settings[OptionsKey];
}

//////

- (void)revealApplicationSupport:(id)sender {
	//TODO: There's a category in Chocolat we should really use
	
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
