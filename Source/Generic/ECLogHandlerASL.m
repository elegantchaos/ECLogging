// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandlerASL.h"
#import "ECLogChannel.h"
#import "ECLogManager.h"

#import <asl.h>

@interface ECLogHandlerASL()
@property (strong, nonatomic) NSMutableDictionary*  aslClients;
@end

@implementation ECLogHandlerASL

#pragma mark - Lifecycle

// --------------------------------------------------------------------------
//! Initialise.
// --------------------------------------------------------------------------

- (instancetype) init 
{
    if ((self = [super init]) != nil) 
    {
        self.name = @"ASL";
        self.aslClients = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (void)dealloc 
{
    for (NSValue* client in [self.aslClients allValues])
    {
        asl_close([client pointerValue]);
    }
}

#pragma mark - Logging

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext *)context
{
    aslclient client = [(self.aslClients)[channel.name] pointerValue];
    if (!client)
    {
		client = asl_open([channel.nameIncludingApplication UTF8String], "ECLogging", ASL_OPT_STDERR);
		(self.aslClients)[channel.name] = [NSValue valueWithPointer:client];

    }

    int level = channel.level ? (int) [channel.level integerValue] : ASL_LEVEL_NOTICE;

	ECLogContextFlags oldContext = [channel disableFlags:ECLogContextName];
    NSString* output = [self simpleOutputStringForChannel:channel withObject:object arguments:arguments context:context];
	channel.context = oldContext;
	aslmsg aslMsg = asl_new(ASL_TYPE_MSG);
    asl_log(client, aslMsg, level, "%s", [output UTF8String]);
	asl_free(aslMsg);
}

@end
