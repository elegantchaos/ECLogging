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

#define EC_DEPRECATED __attribute__((deprecated))

#define ECUnused(v) (void)(v)

#define EC_HINT_UNUSED __attribute__((__unused__))

#define EC_EXPORTED __attribute__((visibility("default")))


#if EC_DEBUG

#define EC_CONFIGURATION_STRING @"Debug"
#define EC_CONFIGURATION_STRING_SHORT @"D"

#define ECUnusedInDebug(v) ECUnused(v)
#define ECUnusedInRelease(v) \
	do                       \
	{                        \
	} while (0)
#define ECDebugOnly(x) x
#define ECReleaseOnly(x) \
	do                   \
	{                    \
	} while (0)
#define ECCastTo(_class_, _expression_) ((_class_*)[ECAssertion assertObject:(_expression_)isOfClass:([_class_ class])])

#else

#define EC_CONFIGURATION_STRING @"Release"
#define EC_CONFIGURATION_STRING_SHORT @"R"

#define ECUnusedInDebug(v) do {} while(0)
#define ECUnusedInRelease(v) ECUnused(v)
#define ECDebugOnly(x) \
	do                 \
	{                  \
	} while (0)
#define ECReleaseOnly(x) x
#define ECCastTo(_class_, _expression_) ((_class_*)(_expression_))

#endif

#ifndef __MAC_10_10_3 // TEMPORARY SUPPORT FOR XC6.2, which doesn't know about some of these
#define nullable
#define nonnull
#define __nonnull
#define SELECTOR_DOUBLE(x) @selector((x))
#endif
