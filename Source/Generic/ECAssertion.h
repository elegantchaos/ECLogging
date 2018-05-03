// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------


#if !NS_BLOCK_ASSERTIONS && !defined(__clang_analyzer__) // don't evaluate assertions whilst we're being analyzed as it can confuse clang into thinking that some code paths are normal when actually they aren't

#pragma mark - Assertions Enabled

#import "ECLoggingMacros.h"

@class ECLogChannel;

ECDeclareLogChannel(AssertionChannel);

#define ECAssert(expression)																\
	do {																					\
		BOOL _expression_ok = ((int)(expression)) != 0;                                     \
		if (!_expression_ok) {                                                              \
			ECLog(AssertionChannel, @"%s was false", #expression);							\
		}																					\
		NSAssert(_expression_ok, @"ECAssertion failed for expression: %s", #expression);	\
	} while (0)

#ifdef __OBJC
#define ECAssertC(expression)																\
	do {																					\
		BOOL _expression_ok = ((int)(expression)) != 0;                                     \
		if (!_expression_ok) {                                                              \
			ECLog(AssertionChannel, @"%s was false", #expression);							\
		}																					\
		NSAssertC(_expression_ok, @"ECAssertion failed for expression: %s", #expression);   \
	} while (0)
#else
#define ECAssertC assert
#endif
#else

#pragma mark - Assertions Disabled

#define ECAssert(expression)
#define ECAssertC(expression)

#endif

#pragma mark - Generic Macros

#define ECAssertContainsBase(container, object, imp) imp([(container)containsObject:(object)])
#define ECAssertDoesntContainBase(container, object, imp) imp(![(container)containsObject:(object)])
#define ECAssertShouldntBeHereBase(imp) imp(FALSE)
#define ECAssertSubclassShouldOverrideBase(imp) imp(FALSE)
#define ECAssertNonNilBase(expression, imp) imp((expression) != nil)
#define ECAssertNilBase(expression, imp) imp((expression) == nil)
#define ECAssertCountAtLeastBase(container, countMinimum, imp) imp([(container)count] >= (countMinimum))
#define ECAssertEmptyBase(object, imp)
#define ECAssertIsMainThreadBase(imp) imp(([NSThread isMainThread]))
#define ECAssertFailBase(imp) imp(FALSE)


#define ECAssertContains(container, object) ECAssertContainsBase(container, object, ECAssert)
#define ECAssertContainsC(container, object) ECAssertContainsBase(container, object, ECAssertC)

#define ECAssertDoesntContain(container, object) ECAssertDoesntContainBase(container, object, ECAssert)
#define ECAssertDoesntContainC(container, object) ECAssertDoesntContainBase(container, object, ECAssertC)

#define ECAssertSubclassShouldOverride() ECAssertSubclassShouldOverrideBase(ECAssert)
#define ECAssertSubclassShouldOverrideC() ECAssertSubclassShouldOverrideBase(ECAssertC)

#define ECAssertShouldntBeHere() ECAssertShouldntBeHereBase(ECAssert)
#define ECAssertShouldntBeHereC() ECAssertShouldntBeHereBase(ECAssertC)

#define ECAssertNonNil(expression) ECAssertNonNilBase(expression, ECAssert)
#define ECAssertNonNilC(expression) ECAssertNonNilBase(expression, ECAssertC)

#define ECAssertNil(expression) ECAssertNilBase(expression, ECAssert)
#define ECAssertNilC(expression) ECAssertNilBase(expression, ECAssertC)

#define ECAssertCountAtLeast(container, countMinimum) ECAssertCountAtLeastBase(container, countMinimum, ECAssert)
#define ECAssertCountAtLeastC(container, countMinimum) ECAssertCountAtLeastBase(container, countMinimum, ECAssertC)

#define ECAssertEmpty(item)                              \
	do                                                   \
	{                                                    \
		if ([item respondsToSelector:@selector(length)]) \
		{                                                \
			ECAssert([(NSString*)item length] == 0);     \
		}                                                \
		else                                             \
		{                                                \
			ECAssert([item count] == 0);                 \
		}                                                \
	} while (0)

#define ECAssertIsKindOfClass(o, c) ECAssert(((o) == nil) || [o isKindOfClass:[c class]])
#define ECAssertIsMemberOfClass(o, c) ECAssert(((o) == nil) || [o isMemberOfClass:[c class]])
#define ECAssertConformsToProtocol(o, p) ECAssert(((o) == nil) || [o conformsToProtocol:@protocol(p)])

#define ECAssertIsKindOfClassDynamic(o, dc) ECAssert(((o) == nil) || [o isKindOfClass:dc])
#define ECAssertIsMemberOfClassDynamic(o, dc) ECAssert(((o) == nil) || [o isMemberOfClass:dc])

#define ECAssertIsMainThread() ECAssertIsMainThreadBase(ECAssert)
#define ECAssertIsMainThreadC() ECAssertIsMainThreadBase(ECAssertC)

#define ECAssertFail()	{ ECAssertFailBase(ECAssert); }
#define ECAssertFailC()	{ ECAssertFailBase(ECAssertC); }

EC_ASSUME_NONNULL_BEGIN

@interface ECAssertion : NSObject

+ (id)assertObject:(id)object isOfClass:(Class)c;

@end

EC_ASSUME_NONNULL_END
