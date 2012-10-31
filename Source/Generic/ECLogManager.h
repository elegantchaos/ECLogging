// --------------------------------------------------------------------------
//! @author Sam Deane
//! @date 12/04/2011
//
//  Copyright 2012 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLoggingMacros.h"
#import "ECLogContext.h"

@class ECLogChannel;
@class ECLogHandler;

// --------------------------------------------------------------------------
//! Manager which keeps track of all the log channels.
// --------------------------------------------------------------------------

@interface ECLogManager : NSObject

{
@private
	NSMutableDictionary* _channels;
	NSMutableDictionary* _handlers;
	NSMutableArray* _defaultHandlers;
	NSMutableDictionary* _settings;
    ECLogContextFlags _defaultContextFlags;
}

// --------------------------------------------------------------------------
// Public Properties
// --------------------------------------------------------------------------

@property (nonatomic, retain) NSMutableDictionary* channels;
@property (nonatomic, retain) NSMutableDictionary* handlers;
@property (nonatomic, retain) NSMutableArray* defaultHandlers;
@property (nonatomic, assign) ECLogContextFlags defaultContextFlags;

// --------------------------------------------------------------------------
// Public Methods
// --------------------------------------------------------------------------

- (ECLogChannel*)registerChannelWithRawName:(const char*)rawName options:(NSDictionary*)options;
- (ECLogChannel*)registerChannelWithName:(NSString*)name options:(NSDictionary*)options;
- (void)registerChannel:(ECLogChannel*)channel;
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

- (NSString*)handlerNameForIndex:(NSUInteger)index;
- (ECLogHandler*)handlerForIndex:(NSUInteger)index;
- (NSUInteger)handlerCount;

@end

@interface ECLogManager(PlatformSpecific)

+ (ECLogManager*)sharedInstance;

@end

// --------------------------------------------------------------------------
// Notifications
// --------------------------------------------------------------------------

extern NSString *const LogChannelsChanged;
