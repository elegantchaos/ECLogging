// --------------------------------------------------------------------------
//  Copyright 2016 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECLogHandlerOSLog.h"
#import "ECLogChannel.h"

#import <os/log.h>

@interface ECLogHandlerOSLog()
@property (strong, nonatomic) NSMutableDictionary* osLogs;
@end

@implementation ECLogHandlerOSLog

#pragma mark - Lifecycle

// --------------------------------------------------------------------------
//! Initialise.
// --------------------------------------------------------------------------

- (instancetype) init 
{
    if ((self = [super init]) != nil)
    {
        self.name = @"OSLog";
		_osLogs = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - Logging

- (void)logFromChannel:(ECLogChannel*)channel withObject:(id)object arguments:(va_list)arguments context:(ECLogContext *)context
{
    os_log_t log = (self.osLogs)[channel.name];
    if (!log)
    {
		log = os_log_create([channel.nameIncludingApplication UTF8String], "ECLogging");
		(self.osLogs)[channel.name] = log;
    }
    
    NSString* output = [self simpleOutputStringForChannel:channel withObject:object arguments:arguments context:context];

	int type = OS_LOG_TYPE_DEFAULT;
	if (channel.level) {
		switch ([channel.level integerValue]) {
			case ECSystemLogLevelNotice:
				type = OS_LOG_TYPE_INFO;
				break;

			case ECSystemLogLevelDebug:
				type = OS_LOG_TYPE_DEBUG;
				break;

			case ECSystemLogLevelCritical:
				type = OS_LOG_TYPE_FAULT;
				break;

			case ECSystemLogLevelError:
			case ECSystemLogLevelAlert:
			case ECSystemLogLevelWarning:
				type = OS_LOG_TYPE_ERROR;
				break;

			default: type = OS_LOG_TYPE_DEFAULT;
		}
	}

	os_log_with_type(log, type, "%{public}s", [output UTF8String]);
}

@end
