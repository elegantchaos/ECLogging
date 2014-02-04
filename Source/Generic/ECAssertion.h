// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

#define ECAssertShouldntBeHereBase(imp)							imp(FALSE)
#define ECAssertNonNilBase(expression, imp)						imp((expression) != nil)
#define ECAssertNilBase(expression, imp)						imp((expression) == nil)
#define ECAssertCountAtLeastBase(container, countMinimum, imp)	imp([container count] >= countMinimum)
#define ECAssertEmptyBase(object, imp)							

#if EC_DEBUG

#import "ECLoggingMacros.h"

ECDeclareDebugChannel(AssertionChannel);

#endif

#if EC_DEBUG && !defined(__clang_analyzer__) // don't evaluate assertions whilst we're being analyzed as it can confuse clang into thinking that some code paths are normal when actually they aren't

#define ECAssert(expression) do { if (!(expression)) { ECDebug(AssertionChannel, @"Expression %s was false", #expression); [ECAssertion failAssertion:#expression]; } } while(0)
#define ECAssertC(expression) assert(expression)

#else // NON-DEBUG

#define ECAssert(expression)
#define ECAssertC(expression)

#endif

#define ECAssertShouldntBeHere() ECAssertShouldntBeHereBase(ECAssert)
#define ECAssertShouldntBeHereC() ECAssertShouldntBeHereBase(ECAssertC)

#define ECAssertNonNil(expression) ECAssertNonNilBase(expression, ECAssert)
#define ECAssertNonNilC(expression) ECAssertNonNilBase(expression, ECAssertC)

#define ECAssertNil(expression) ECAssertNilBase(expression, ECAssert)
#define ECAssertNilC(expression) ECAssertNilBase(expression, ECAssertC)

#define ECAssertCountAtLeast(container, countMinimum) ECAssertCountAtLeastBase(container, countMinimum, ECAssert)
#define ECAssertCountAtLeastC(container, countMinimum) ECAssertCountAtLeastBase(container, countMinimum, ECAssertC)

#define ECAssertEmpty(item) do { if ([item respondsToSelector:@selector(length)]) { ECAssert([(NSString*) item length] == 0); } else { ECAssert([item count] == 0); } } while (0)

#define ECAssertIsKindOfClass(o, c) ECAssert(((o) == nil) || [o isKindOfClass:[c class]])
#define ECAssertIsMemberOfClass(o, c) ECAssert(((o) == nil) || [o isMemberOfClass:[c class]])

@interface ECAssertion : NSObject

+ (void)failAssertion:(const char*)expression;

@end
