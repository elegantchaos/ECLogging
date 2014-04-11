// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

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
	NSString* message;
	if ([object isMemberOfClass:[NSError class]])
	{
		message = [object localizedDescription];
	}
	else if ([object isMemberOfClass:[ECErrorAndMessage class]])
	{
		ECErrorAndMessage* eam = object;
		message = [eam description];
	}
	else 
	{
		message = [self simpleOutputStringForChannel:channel withObject:object arguments:arguments context:context];
	}

	NSString* title = @"Error";
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
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
