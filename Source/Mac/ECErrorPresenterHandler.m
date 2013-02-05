//
//  ECErrorPresenterHandler.m
//  ECLogging
//
//  Created by Sam Deane on 10/04/2012.
//  Copyright (c) 2012 Elegant Chaos. All rights reserved.
//

#import "ECErrorPresenterHandler.h"
#import "ECErrorAndMessage.h"

@implementation ECErrorPresenterHandler

NSString *const ECLoggingErrorDomain = @"ECLogging";
const NSInteger ECLoggingUnknownError = -1;

// --------------------------------------------------------------------------
//! Initialise.
// --------------------------------------------------------------------------

- (id) init 
{
    if ((self = [super init]) != nil) 
    {
        self.name = @"ErrorPresenter";
    }
    
    return self;
}

#pragma mark - Logging

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext *)context
{
	NSError* error;
	
	if ([object isMemberOfClass:[NSError class]])
	{
		error = object;
	}
	else if ([object isMemberOfClass:[ECErrorAndMessage class]])
	{
		ECErrorAndMessage* eam = object;
		error = eam.error;
	}
	else 
	{
		NSString* string = [self simpleOutputStringForChannel:channel withObject:object arguments:arguments context:context];
		error = [NSError errorWithDomain:ECLoggingErrorDomain code:ECLoggingUnknownError userInfo:@{NSLocalizedDescriptionKey: string}];
	}

	[[NSApplication sharedApplication] presentError:error];
}

// --------------------------------------------------------------------------
//! Called to indicate that the handler was enabled for a given channel.
//! We don't want to do the default thing here - which would have been
//! to log the information to the channel, since that would cause us
//! to display an error alert which we only want to do for actual errors.
// --------------------------------------------------------------------------

- (void)wasEnabledForChannel:(ECLogChannel *)channel
{
}

// --------------------------------------------------------------------------
//! Called to indicate that the handler was disabled for a given channel.
//! We don't want to do the default thing here - which would have been
//! to log the information to the channel, since that would cause us
//! to display an error alert which we only want to do for actual errors.
// --------------------------------------------------------------------------

- (void)wasDisabledForChannel:(ECLogChannel *)channel
{
}

@end
