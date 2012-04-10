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
		error = [NSError errorWithDomain:ECLoggingErrorDomain code:ECLoggingUnknownError userInfo:[NSDictionary dictionaryWithObjectsAndKeys:string, NSLocalizedDescriptionKey, nil]];
	}

	[[NSApplication sharedApplication] presentError:error];
}

@end
