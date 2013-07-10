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
	ECAssertStringDiff,
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

/**
 Perform some more detailed checking of two bits of text.
 If they don't match, we call STFail reporting the point where they differed.
 @param string1 First string to compare.
 @param string2 Second string to compare.
 */

- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2;

/**
 Perform some more detailed checking of two bits of text.
 If they don't match, we call STFail reporting the point where they differed.

 The comparison modes determine exactly how differences are reported.
 - ECAssertStringTestShowChars:  we report the differing lengths, and the characters where they diverge
 - ECAssertStringTestShowLines: we report the lines where they diverge
 - ECAssertStringTestShowLinesIgnoreWhitespace: we report the lines where they diverge, ignoring blank lines

 @param string1 First string to compare.
 @param string2 Second string to compare.
 @param mode Comparison mode to use.
 */

- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2 mode:(ECAssertStringTestMode)mode;

/**
 Check some text against a file.
 If they don't match, we call STFail reporting the point where they differed.

 The comparison modes determine exactly how differences are reported.

 @param string The string to compare.
 @param url The file containing text to compare against.
 @param mode Comparison mode to use.
 */

- (void)assertString:(NSString*)string matchesContentsOfURL:(NSURL*)url mode:(ECAssertStringTestMode)mode;

/**
 Check that two collections match.
 If they don't match, we call STFail reporting the point where they differed.

 This is implemented by calling description on them both, then calling assertString:matchesString.
 @param collection1 first collection
 @param collection2 second collection
 */

- (void)assertCollection:(id)collection1 matchesCollection:(id)collection2;

/**
 Check that a collection matches the contents of a file.
 If they don't match, we call STFail reporting the point where they differed.

 This is implemented by calling description on them both, then calling assertString:matchesString.
 @param collection Collection to test.
 @param url The file to test against
 @param mode The testing mode.
 */

- (void)assertCollection:(id)collection matchesContentsOfURL:(NSURL*)url mode:(ECAssertStringTestMode)mode;

/**
 Check that two collections match.
 If they don't match, we call STFail reporting the point where they differed.

 This is implemented by calling description on them both, then calling assertString:matchesString.
 @param collection1 First collection.
 @param collection2 Second collection.
 @param mode String comparison mode to use.
 */

- (void)assertCollection:(id)collection1 matchesCollection:(id)collection2 mode:(ECAssertStringTestMode)mode;

+ (NSUInteger)genericCount:(id)item;
+ (BOOL)string:(NSString*)string1 beginsWithString:(NSString *)string2;
+ (BOOL)string:(NSString*)string1 endsWithString:(NSString *)string2;
+ (BOOL)string:(NSString*)string1 containsString:(NSString *)string2;

/**
 Return a URL to a temporary folder.
 This will be named using the test name, so should be unique to the test.
 */

- (NSURL*)URLForTemporaryFolder;

/**
 Return a URL to a file within the temporary folder.
 @param name The name (and extension) to use for the temporary file.
 */

- (NSURL*)URLForTemporaryFileNamed:(NSString*)name;

/**
 Return a URL to a file within the temporary folder.
 @param name The name to use for the temporary file.
 @param ext The extension to use for the temporary file.
 */

- (NSURL*)URLForTemporaryFileNamed:(NSString *)name withExtension:(NSString *)ext;

- (NSURL *)URLForTestResource:(NSString *)name withExtension:(NSString *)ext;
- (NSURL *)URLForTestResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath;

- (NSBundle*)exampleBundle;
- (NSURL*)exampleBundleURL;
- (NSString*)exampleBundlePath;

- (void)runUntilTimeToExit;
- (void)timeToExitRunLoop;

/**
 Compare two files and output a diff.
 The diff program is /usr/bin/diff by default, but can be changed with defaults, e.g:
     defaults write otest DiffTool "/usr/local/bin/ksdiff"

 @param url1 Location of first file to diff.
 @param url2 Location of second file to diff.
 */

- (void)diffURL:(NSURL*)url1 againstURL:(NSURL*)url2;

@end
