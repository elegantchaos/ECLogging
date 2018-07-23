// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

EC_ASSUME_NONNULL_BEGIN

@class ECLogChannel;
@class ECLogHandler;
@class ECLogManager;

@protocol ECLogManagerDelegate <NSObject>
@optional
- (void)logManagerDidStartup:(ECLogManager*)manager;
- (void)logManagerWillShutdown:(ECLogManager*)manager;
- (void)showUIForLogManager:(ECLogManager*)manager;
@end

/**
 * Singleton which keeps track of all the log channels and log handlers, and mediates the logging process.
 * 
 * The singleton is obtained using [ECLogManager sharedInstance], but you don't generally need to access it directly.
 *
 * See <Index> for more details.
 */

@interface ECLogManager : NSObject


/**
 * Return the shared log manager.
 */

+ (ECLogManager*)sharedInstance;

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

@property (strong, nonatomic, ec_nullable) NSMutableArray* defaultHandlers;

/**
 All the ECLogManager settings.
 */

@property (strong, nonatomic, ec_nullable) NSMutableDictionary* settings;

/**
 Options, as specified in the settings files.
 These are used to build an Options menu, as a quick way of changing user default values.
 */

@property (strong, nonatomic, readonly) NSDictionary* options;

@property (weak, nonatomic) id<ECLogManagerDelegate> delegate;
@property (assign, nonatomic) BOOL showMenu;
@property (assign, nonatomic, readonly, getter=debugChannelsAreEnabled) BOOL debugChannelsAreEnabled;
@property (assign, nonatomic, readonly, getter=assertionsAreEnabled) BOOL assertionsAreEnabled;


/**
 Cleanup and shut down.
 
 This should typically be called from `applicationWillTerminate`.
 */

- (void)shutdown;



/**
 Has the user suppressed the alert for a given assertion?
 */

- (BOOL)isAssertionSuppressedForKey:(NSString*)key;

/**
 Suppress the alert for a given assertion.
 */

- (void)suppressAssertionForKey:(NSString*)key;

/**
 Remove all assertion suppression settings. All assertions will cause alerts.
 */

- (void)resetAllAssertions;

/**
 Display some UI which allows configuration of the log manager.
 This is implemented by the delegate, and can be an overlay, a separate window, or
 anything else appropriate.
 */

- (void)showUI;

@end

// --------------------------------------------------------------------------
// Notifications
// --------------------------------------------------------------------------

extern NSString* const LogChannelsChanged;

EC_ASSUME_NONNULL_END
