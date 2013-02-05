// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLoggingMacros.h"

@class ECLogChannel;

/**
 * Base class for all log handlers.
 */

@interface ECLogHandler : NSObject 

{
@private
	NSString* name;
}

@property (strong, nonatomic) NSString* name;

/**
 * Called by the log manager for each message/object sent to a channel.
 */

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;

/**
 * Helper method to perform a case insensitive comparison with another handler - can be used to sort handlers by name.
 */

- (NSComparisonResult)caseInsensitiveCompare:(ECLogHandler*)other;

- (NSString*)simpleOutputStringForChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context;

/**
 * Called by the log manager to indicate that the handler was enabled for a channel.
 *
 * @param channel The channel that is now using the handler.
 */

- (void)wasEnabledForChannel:(ECLogChannel*)channel;

/**
 * Called by the log manager to indicate that the handler was disabled for a channel.
 *
 * @param channel The channel that has stopped using the handler.
 */

- (void)wasDisabledForChannel:(ECLogChannel*)channel;
@end
