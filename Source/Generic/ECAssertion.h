// --------------------------------------------------------------------------
//  Copyright 2017 Elegant Chaos Limited. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------


#if !NS_BLOCK_ASSERTIONS && !defined(__clang_analyzer__) // don't evaluate assertions whilst we're being analyzed as it can confuse clang into thinking that some code paths are normal when actually they aren't

#pragma mark - Assertions Enabled

#define ECAssert(expression) NSAssert((int)(expression) != 0, @"ECAssertion failed for expression: %s", #expression);

#ifdef __OBJC
#define ECAssertC(expression) NSAssertC((int)(expression) != 0, @"ECAssertion failed for expression: %s", #expression);
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
#define ECAssertIsMainThreadBase(imp) imp(([NSThread isMainThread]))
#define ECAssertFailBase(imp) imp(FALSE)


#define ECAssertContains(container, object) ECAssertContainsBase(container, object, ECAssert)

#define ECAssertDoesntContain(container, object) ECAssertDoesntContainBase(container, object, ECAssert)
#define ECAssertDoesntContainC(container, object) ECAssertDoesntContainBase(container, object, ECAssertC)

#define ECAssertSubclassShouldOverride() ECAssertSubclassShouldOverrideBase(ECAssert)

#define ECAssertShouldntBeHere() ECAssertShouldntBeHereBase(ECAssert)
#define ECAssertShouldntBeHereC() ECAssertShouldntBeHereBase(ECAssertC)

#define ECAssertNonNil(expression) ECAssertNonNilBase(expression, ECAssert)
#define ECAssertNonNilC(expression) ECAssertNonNilBase(expression, ECAssertC)

#define ECAssertNil(expression) ECAssertNilBase(expression, ECAssert)




#define ECAssertIsKindOfClass(o, c) ECAssert(((o) == nil) || [o isKindOfClass:[c class]])
#define ECAssertConformsToProtocol(o, p) ECAssert(((o) == nil) || [o conformsToProtocol:@protocol(p)])

#define ECAssertIsKindOfClassDynamic(o, dc) ECAssert(((o) == nil) || [o isKindOfClass:dc])

#define ECAssertIsMainThread() ECAssertIsMainThreadBase(ECAssert)

#define ECAssertFail()	{ ECAssertFailBase(ECAssert); }

NS_ASSUME_NONNULL_BEGIN

@interface ECAssertion : NSObject

+ (id)assertObject:(id)object isOfClass:(Class)c;

@end

NS_ASSUME_NONNULL_END
