// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogContext.h"

NS_ASSUME_NONNULL_BEGIN
@class ECLogChannel;
@class ECLogHandler;
@class ECLogManager;

@protocol ECLogManagerDelegate <NSObject>
@optional
- (void)logManagerDidStartup:(ECLogManager*)manager;
- (void)logManagerWillShutdown:(ECLogManager*)manager;
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

@property (strong, nonatomic, nullable) NSMutableDictionary* channels;
@property (strong, nonatomic, nullable) NSMutableDictionary* handlers;
@property (strong, nonatomic, nullable) NSMutableArray* defaultHandlers;
@property (assign, nonatomic) ECLogContextFlags defaultContextFlags;
@property (strong, nonatomic, nullable) NSMutableDictionary* settings;
@property (weak, nonatomic) id<ECLogManagerDelegate> delegate;
@property (assign, nonatomic) BOOL showMenu;
@property (assign, nonatomic, readonly, getter=debugChannelsAreEnabled) BOOL debugChannelsAreEnabled;
@property (assign, nonatomic, readonly, getter=assertionsAreEnabled) BOOL assertionsAreEnabled;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (ECLogChannel*)registerChannelWithRawName:(const char*)rawName options:(nullable NSDictionary*)options;
- (ECLogChannel*)registerChannelWithName:(NSString*)name options:(nullable NSDictionary*)options;
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

- (BOOL)isAssertionSuppressedForKey:(NSString*)key;
- (void)suppressAssertionForKey:(NSString*)key;
- (void)resetAllAssertions;

@end

@interface ECLogManager (PlatformSpecific)

@end

// --------------------------------------------------------------------------
// Notifications
// --------------------------------------------------------------------------

extern NSString* const LogChannelsChanged;

NS_ASSUME_NONNULL_END
