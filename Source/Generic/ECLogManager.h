// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogContext.h"

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
 Default context flag values.
 */

@property (assign, nonatomic) ECLogContextFlags defaultContextFlags;

/**
 The number of named context info flags.
 */

@property (assign, nonatomic, readonly) NSUInteger contextFlagCount;

/**
 Dictionary of all channels and their settings.
 */

@property (strong, nonatomic, ec_nullable) NSMutableDictionary* channels;

/**
 Sorted list of all channels.
 */

@property (strong, nonatomic, readonly) NSArray* channelsSortedByName;

/**
 Dictionary of all handlers and their settings.
 */

@property (strong, nonatomic, ec_nullable) NSMutableDictionary* handlers;

/**
 The number of handler indexes.
 This is the number of handlers, plus one (or the "Use Defaults" label).
 */

@property (assign, nonatomic, readonly) NSUInteger handlerCount;

/**
 Sorted list of all handlers.
 */

@property (strong, nonatomic, readonly) NSArray* handlersSortedByName;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

/**
 Register a new channel.
 */

- (ECLogChannel*)registerChannelWithName:(NSString*)name options:(ec_nullable NSDictionary*)options;

/**
 Register a new channel with a raw C-style name.
 */

- (ECLogChannel*)registerChannelWithRawName:(const char*)rawName options:(ec_nullable NSDictionary*)options;

/**
 Register a dynamically created channel.
 */

- (ECLogChannel*)registerChannel:(ECLogChannel*)channel;

/**
 Cleanup and shut down.
 
 This should typically be called from `applicationWillTerminate`.
 */

- (void)shutdown;

/**
 Log to all valid handlers for a channel.
 
 Generally you don't need to call this directly - use the ECLog and ECDebug macros instead.
 */

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;

/**
 Turn on every channel.
 */

- (void)enableAllChannels;


/**
 Turn off every channel.
 */

- (void)disableAllChannels;

/**
 Reset all channels and handlers to their default settings.
 */

- (void)resetAllSettings;


/**
 Save the current configuration for all channels.
 */

- (void)saveChannelSettings;

/**
 Reset a channel to its default settings.
 */

- (void)resetChannel:(ECLogChannel*)channel;

/**
 Return a text label for a context info flag.
 */

- (NSString*)contextFlagNameForIndex:(NSUInteger)index;

/**
 Return a context info flag.
 */

- (ECLogContextFlags)contextFlagValueForIndex:(NSUInteger)index;

/**
 Return the name of a given handler index.
 Index 0 represents the Default Handlers, and returns "Use Defaults".
*/

- (NSString*)handlerNameForIndex:(NSUInteger)index;

 /**
  Return the handler for a given index.
  Index 0 represents the Default Handlers, and returns nil.
  */

- (ec_nullable ECLogHandler*)handlerForIndex:(NSUInteger)index;

/**
 Is a handler one of the default set.
 Any channel that hasn't had a custom set of handlers specified will use the default set.
 */

- (BOOL)handlerIsDefault:(ECLogHandler*)handler;

/**
 Add a handler to the default set.
 Any channel that hasn't had a custom set of handlers specified will use the default set.
 */

- (void)handler:(ECLogHandler*)handler setDefault:(BOOL)value;

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
