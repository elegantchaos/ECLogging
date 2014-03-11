// --------------------------------------------------------------------------
//
//! @file:
//! Logging utilities.
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#ifndef EC_DEBUG
#ifndef EC_RELEASE
#error You must define either EC_DEBUG or EC_RELEASE
#endif
#endif

#import "ECLogContext.h"


#pragma mark - Plain C interface

// These routines are used in some of the macros, and are generally not intended for public use.


#pragma mark - Channel Declaration Macros

#define ECDeclareLogChannel(channel) \
	extern ECLogChannel* getChannel##channel(void)

#define ECDefineLogChannel(channel) \
	extern ECLogChannel* getChannel##channel(void); \
	ECLogChannel* getChannel##channel(void) \
	{ \
		static dispatch_once_t onceToken; \
		static ECLogChannel* instance = nil; \
		dispatch_once(&onceToken, ^{ \
			instance = registerChannel(#channel); \
		}); \
		return instance; \
	}

#pragma mark - Logging Macros

#define ECLog(channel, ...) do { ECLogChannel* __c = getChannel##channel(); if (channelEnabled(__c)) { ECMakeContext(); logToChannel(__c, &ecLogContext, __VA_ARGS__); } } while (0)

#define ECLogIf(test, channel, ...) do { if (test) { ECLogChannel* __c = getChannel##channel(); ECMakeContext(); if (channelEnabled(__c)) { logToChannel(__c, &ecLogContext, __VA_ARGS__); } } } while (0)

#define ECGetChannel(channel) getChannel##channel()

#define ECEnableChannel(channel) enableChannel(getChannel##channel())

#define ECDisableChannel(channel) disableChannel(getChannel##channel())

#define ECChannelEnabled(channel) channelEnabled(getChannel##channel())

#define ECOptionEnabled(key) ([[NSUserDefaults standardUserDefaults] boolForKey:@ #key])

#pragma mark - Debug Only Macros

#if EC_DEBUG

#define ECDebug ECLog
#define ECDebugIf ECLogIf
#define ECDefineDebugChannel ECDefineLogChannel
#define ECDeclareDebugChannel ECDeclareLogChannel
#define ECDebugChannelEnabled ECChannelEnabled
#define ECDebugOptionEnabled(key) ECOptionEnabled(key)
#define ECEnableDebugChannel ECEnableChannel
#define ECDisableDebugChannel ECDisableChannel

#else

#define ECDebug(...) 
#define ECDebugIf(...)
#define ECDefineDebugChannel(...)
#define ECDeclareDebugChannel(...)
#define ECDebugChannelEnabled(channel) (false)
#define ECDebugOptionEnabled(key) NO
#define ECEnableDebugChannel(...)
#define ECDisableDebugChannel(...)

#endif
