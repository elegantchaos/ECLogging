// --------------------------------------------------------------------------
//  Copyright 2016 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECOSLogClient.h"

#import <os/log.h>

@interface ECOSLogClient ()

@property (strong, nonatomic) os_log_t log;

@end

@implementation ECOSLogClient


// --------------------------------------------------------------------------
//! Set up ASL connection etc.
// --------------------------------------------------------------------------

- (instancetype)initWithName:(NSString*)name
{
	if ((self = [super initWithName:name]) != nil)
	{
		const char* subsystem_c = [[[NSBundle mainBundle] bundleIdentifier] UTF8String];
		const char* name_c = [name UTF8String];
		_log = os_log_create(subsystem_c, name_c);
	}

	return self;
}


// --------------------------------------------------------------------------
//! Log to ASL.
// --------------------------------------------------------------------------

- (void)logAtLevel:(int)level withFormat:(NSString*)format args:(va_list)args
{
	NSString* text = [[NSString alloc] initWithFormat:format arguments:args];

	int type;
	switch (level) {
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
	os_log_with_type(self.log, type, "%{public}s", [text UTF8String]);
}

@end
