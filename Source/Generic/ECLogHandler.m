// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandler.h"
#import "ECAssertion.h"
#import "ECLogChannel.h"
#import "ECLoggingMacros.h"

@implementation ECLogHandler

#pragma mark - Logging

// --------------------------------------------------------------------------
//! Log.
// --------------------------------------------------------------------------


- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
	ECAssertShouldntBeHere();
}

#pragma mark - Sorting

// --------------------------------------------------------------------------
//! Comparison function for sorting alphabetically by name.
// --------------------------------------------------------------------------

- (NSComparisonResult)caseInsensitiveCompare:(ECLogHandler*)other
{
	return [self.name caseInsensitiveCompare:other.name];
}

// --------------------------------------------------------------------------
//! Utility for simple log handlers that just output a string.
//! Converts the input parameters into a string to log.
// --------------------------------------------------------------------------

- (NSString*)simpleOutputStringForChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
	NSString* result;

	if (![channel showContext:ECLogContextMessage])
	{
		// just log the context
		result = [channel stringFromContext:context];
	}
	else
	{
		// log the message, possibly with a context appended
		if ([object isKindOfClass:[NSString class]])
		{
			NSString* format = object;
			result = [[NSString alloc] initWithFormat:format arguments:arguments];
		}
		else
		{
			result = [object description];
		}

		NSString* contextString = [channel stringFromContext:context];
		if ([contextString length])
		{
			result = [NSString stringWithFormat:@"%@ «%@»", result, contextString];
		}
	}

	return result;
}

#pragma mark - Default Enabled/Disabled Notifications

// --------------------------------------------------------------------------
//! Indicate that the handler was enabled for a given channel.
//! By default we just log the fact to the channel.
// --------------------------------------------------------------------------

- (void)wasEnabledForChannel:(ECLogChannel*)channel
{
	ECMakeContext();
	if (channel.context & ECLogContextMeta) {
		logToChannel(channel, &ecLogContext, @"Enabled handler %@", self.name);
	}
}

// --------------------------------------------------------------------------
//! Indicate that the handler was disabled for a given channel.
//! By default we just log the fact to the channel.
// --------------------------------------------------------------------------

- (void)wasDisabledForChannel:(ECLogChannel*)channel
{
	ECMakeContext();
	if (channel.context & ECLogContextMeta) {
		logToChannel(channel, &ecLogContext, @"Disabled handler %@", self.name);
	}
}

@end
