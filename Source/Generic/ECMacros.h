// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#ifndef EC_DEBUG
#ifndef EC_RELEASE
#error You must define either EC_DEBUG or EC_RELEASE in the project configuration.
#endif
#endif

#define EC_NULL_SUPPORT 0

#if EC_NULL_SUPPORT
#define EC_ASSUME_NONNULL_BEGIN NS_ASSUME_NONNULL_BEGIN
#define EC_ASSUME_NONNULL_END NS_ASSUME_NONNULL_END
#define ec_nullable nullable
#define EC_Nullable _Nullable
#define EC_Nonnull _Nonnull

#else
#define EC_ASSUME_NONNULL_BEGIN
#define EC_ASSUME_NONNULL_END
#define ec_nullable
#define EC_Nullable
#define EC_Nonnull
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
#define ECSafeCastTo ECCastTo

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
#define ECSafeCastTo(_class_, _expression_) ([_expression_ isKindOfClass:[_class_ class]] ? (_class_*)(_expression_) : nil)

#endif
