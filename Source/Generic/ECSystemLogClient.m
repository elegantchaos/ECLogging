// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECSystemLogClient.h"

@implementation ECSystemLogClient

- (instancetype)init
{
	self = [self initWithName:@"Untitled"];
	return self;
}


- (instancetype)initWithName:(NSString*)name
{
	if ((self = [super init]) != nil)
	{
	}

	return self;
}

// --------------------------------------------------------------------------
//! Log to ASL.
// --------------------------------------------------------------------------

- (void)logAtLevel:(ECSystemLogLevel)level withFormat:(NSString*)format args:(va_list)args
{
	NSString* text = [[NSString alloc] initWithFormat:format arguments:args];
	NSLog(@"%@", text);
}


// --------------------------------------------------------------------------
//! Log to ASL. at a given level
// --------------------------------------------------------------------------

- (void)logAtLevel:(ECSystemLogLevel)level withFormat:(NSString*)format, ...
{
	va_list args;
	va_start(args, format);
	[self logAtLevel:level withFormat:format args:args];
	va_end(args);
}

// --------------------------------------------------------------------------
//! Log info to ASL.
// --------------------------------------------------------------------------

- (void)log:(NSString*)format, ...
{
	va_list args;
	va_start(args, format);
	[self logAtLevel:ECSystemLogLevelInfo withFormat:format args:args];
	va_end(args);
}

// --------------------------------------------------------------------------
//! Log error to ASL.
// --------------------------------------------------------------------------

- (void)error:(NSString*)format, ...
{
	va_list args;
	va_start(args, format);
	[self logAtLevel:ECSystemLogLevelInfo withFormat:format args:args];
	va_end(args);
}


@end
