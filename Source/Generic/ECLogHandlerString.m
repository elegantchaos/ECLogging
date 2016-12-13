// --------------------------------------------------------------------------
//  Copyright 2016 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandlerString.h"
#import "ECLogChannel.h"

@implementation ECLogHandlerString

// --------------------------------------------------------------------------
//! Initialise.
// --------------------------------------------------------------------------

- (instancetype) init 
{
    if ((self = [super init]) != nil) 
    {
        self.name = @"String";
		_buffer = [NSMutableString new];
    }
    
    return self;
}

// --------------------------------------------------------------------------
//! Perform the logging.
// --------------------------------------------------------------------------

- (void) logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext*)context
{
    NSString* output = [self simpleOutputStringForChannel:channel withObject:object arguments:arguments context:context];
	[self.buffer appendFormat:@"%@\n", output];
}

@end
