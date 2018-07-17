// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#ifndef EC_DEBUG
#ifndef EC_RELEASE
#error You must define either EC_DEBUG or EC_RELEASE
#endif
#endif


#define ECOptionEnabled(key) ([[NSUserDefaults standardUserDefaults] boolForKey:@ #key])

#pragma mark - Debug Only Macros

#if EC_DEBUG

#define ECDebugDynamic ECLogDynamic
#define ECDebugChannelEnabled ECChannelEnabled
#define ECDebugOptionEnabled(key) ECOptionEnabled(key)

#else

#define ECDebugDynamic(...)
#define ECDebugChannelEnabled(channel) (false)
#define ECDebugOptionEnabled(key) NO

#endif
