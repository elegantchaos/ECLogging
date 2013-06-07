// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <SenTestingKit/SenTestingKit.h>

typedef NS_ENUM(NSUInteger, ECAssertStringTestMode)
{
	ECAssertStringTestShowChars,
	ECAssertStringTestShowLines,
	ECAssertStringTestShowLinesIgnoreWhitespace,
};

#define ECAssertTest(expr, isTrueVal, expString, description, ...) \
do { \
BOOL _evaluatedExpression = (expr);\
if (!_evaluatedExpression) {\
[self failWithException:([NSException failureInCondition:expString \
isTrue:isTrueVal \
inFile:[NSString stringWithUTF8String:__FILE__] \
atLine:__LINE__ \
withDescription:@"%@", STComposeString(description, ##__VA_ARGS__)])]; \
} \
} while (0)

// --------------------------------------------------------------------------
/// The ECTestAssert macros are generally like the STAssert
/// macros, except that they don't take a description string.
/// Instead, they generate their own description of what went
/// wrong. This is sufficient for a lot of cases, and makes the
/// test code a bit less cluttered - as often the description
/// string is pretty redundant and just repeats the logic
/// from the assertion.
///
/// You can still use the STAssert macros too of course.
// --------------------------------------------------------------------------

#define ECTestAssertNotNilFormat				STAssertNotNil
#define ECTestAssertNilFormat					STAssertNil
#define ECTestAssertTrueFormat					STAssertTrue
#define ECTestAssertFalseFormat					STAssertFalse

#define ECTestAssertNotNil(x)					ECTestAssertNotNilFormat((x), @"%s shouldn't be nil", #x)
#define ECTestAssertNil(x)						ECTestAssertNilFormat(x, @"%s should be nil, was %0x", #x, x)
#define ECTestAssertZero(x)						ECTestAssertTrueFormat(x == 0, @"%s should be zero, was %0x", #x, x)
#define ECTestAssertTrue(x)						ECTestAssertTrueFormat(x, @"%s should be true", #x)
#define ECTestAssertFalse(x)					ECTestAssertFalseFormat(x, @"%s should be false", #x)
#define ECTestAssertStringIsEqual(x,y)			ECAssertTest([(x) isEqualToString:(y)], NO, @"" #x " and " #y " match", @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertStringBeginsWith(x,y)		ECAssertTest([ECTestCase string:x beginsWithString:y], NO, @"" #x " begins with " #y, @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertStringEndsWith(x,y)			ECAssertTest([ECTestCase string:x endsWithString:y], NO, @"" #x " ends with " #y, @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertStringContains(x,y)			ECAssertTest([ECTestCase string:x containsString:y], NO, @"" #x " contains " #y, @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertIsEmpty(x)					ECAssertTest([ECTestCase genericCount:x] == 0, NO, @"Object" #x "is empty", @"Value is %@", x)
#define ECTestAssertNotEmpty(x)					ECAssertTest([ECTestCase genericCount:x] != 0, YES, @"Object" #x "is empty", @"Value is %@", x)
#define ECTestAssertLength(x, l)				ECAssertTest([ECTestCase genericCount:x] == l, NO, @"Length of " #x " is " #l, @"Value is %@, length is %d", x, [ECTestCase genericCount:x])
#define ECTestAssertIsEqual(x, y)				ECAssertTest([x isEqual:y], NO, @"" #x " and " #y " are equal", @"Values were %@ and %@", x, y)
#define ECTestAssertTextIsEqual(x,y)			[self assertString:x matchesString:y]
#define ECTestAssertNoError(e)					ECTestAssertTrueFormat(e == 0, @"expected no error, but got %@", e)
#define ECTestAssertOkNoError(status,e)			ECTestAssertTrueFormat(status, @"expected %s to be true, but got %@", #status, e)

#define ECTestAssertOperator(x,t,y,f)			ECAssertTest((x) t (y), NO, @"" #x #t #y, @"Values are " f " and " f ")", x, y)

#define ECTestAssertIntegerIsEqual(x,y)			ECTestAssertOperator(x, ==, y, "%ld")
#define ECTestAssertIntegerIsNotEqual(x,y)		ECTestAssertOperator(x, !=, y, "%ld")
#define ECTestAssertIntegerIsGreater(x,y)		ECTestAssertOperator(x, >, y, "%ld")
#define ECTestAssertIntegerIsGreaterEqual(x,y)	ECTestAssertOperator(x, >=, y, "%ld")
#define ECTestAssertIntegerIsLess(x,y)			ECTestAssertOperator(x, <, y, "%ld")
#define ECTestAssertIntegerIsLessEqual(x,y)		ECTestAssertOperator(x, <=, y, "%ld")

#define ECTestAssertRealIsEqual(x,y)			ECTestAssertOperator(x, ==, y, "%lf")
#define ECTestAssertRealIsNotEqual(x,y)			ECTestAssertOperator(x, !=, y, "%lf")
#define ECTestAssertRealIsGreater(x,y)			ECTestAssertOperator(x, >, y, "%lf")
#define ECTestAssertRealIsGreaterEqual(x,y)		ECTestAssertOperator(x, >=, y, "%lf")
#define ECTestAssertRealIsLess(x,y)				ECTestAssertOperator(x, <, y, "%lf")
#define ECTestAssertRealIsLessEqual(x,y)		ECTestAssertOperator(x, <=, y, "%lf")


#define ECTestFail						STFail
#define ECTestLog						NSLog

/**
* This class contains a few utility methods which:
*
* - support the macros
* - support using classes that need run loops from unit tests
*
* See [this blog post](http://www.bornsleepy.com/bornsleepy/run-loop-cocoa-unit-tests) for more details of the run loop support.
*/

@interface ECTestCase : SenTestCase
{
@private
    BOOL _exitRunLoop;
}

- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2;
- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2 mode:(ECAssertStringTestMode)mode;

+ (NSUInteger)genericCount:(id)item;
+ (BOOL)string:(NSString*)string1 beginsWithString:(NSString *)string2;
+ (BOOL)string:(NSString*)string1 endsWithString:(NSString *)string2;
+ (BOOL)string:(NSString*)string1 containsString:(NSString *)string2;

- (NSBundle*)exampleBundle;
- (NSURL*)exampleBundleURL;
- (NSString*)exampleBundlePath;

- (void)runUntilTimeToExit;
- (void)timeToExitRunLoop;

@end
