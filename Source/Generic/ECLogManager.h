// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLoggingMacros.h"
#import "ECLogContext.h"

@class ECLogChannel;
@class ECLogHandler;
@class ECLogManager;

@protocol ECLogManagerDelegate <NSObject>
@optional
- (void)logManagerWillStartup:(ECLogManager*)manager;
- (void)logManagerDidStartup:(ECLogManager*)manager;
- (void)logManagerWillShutdown:(ECLogManager*)manager;
- (void)logManagerDidShutdown:(ECLogManager*)manager;

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

@property (strong, nonatomic) NSMutableDictionary* channels;
@property (strong, nonatomic) NSMutableDictionary* handlers;
@property (strong, nonatomic) NSMutableArray* defaultHandlers;
@property (assign, nonatomic) ECLogContextFlags defaultContextFlags;
@property (strong, nonatomic) NSMutableDictionary* settings;
@property (weak, nonatomic) id<ECLogManagerDelegate> delegate;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (ECLogChannel*)registerChannelWithRawName:(const char*)rawName options:(NSDictionary*)options;
- (ECLogChannel*)registerChannelWithName:(NSString*)name options:(NSDictionary*)options;
- (ECLogChannel*)registerChannel:(ECLogChannel*)channel;
- (void)startup;
- (void)shutdown;
- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;
- (void)enableAllChannels;
- (void)disableAllChannels;
- (void)resetAllSettings;
- (void)saveChannelSettings;
- (void)resetChannel:(ECLogChannel*)channel;

- (NSArray*)channelsSortedByName;

- (NSString*)contextFlagNameForIndex:(NSUInteger)index;
- (ECLogContextFlags)contextFlagValueForIndex:(NSUInteger)index;
- (NSUInteger)contextFlagCount;

- (NSArray*)handlersSortedByName;
- (NSString*)handlerNameForIndex:(NSUInteger)index;
- (ECLogHandler*)handlerForIndex:(NSUInteger)index;
- (NSUInteger)handlerCount;
- (BOOL)handlerIsDefault:(ECLogHandler*)handler;
- (void)handler:(ECLogHandler*)handler setDefault:(BOOL)value;

- (NSDictionary*)optionsSettings;

@end

@interface ECLogManager(PlatformSpecific)

@end

// --------------------------------------------------------------------------
// Notifications
// --------------------------------------------------------------------------

extern NSString *const LogChannelsChanged;
