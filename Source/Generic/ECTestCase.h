// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestComparisons.h"


@class NSBitmapImageRep;

typedef NS_ENUM(NSUInteger, ECTestComparisonMode)
{
	ECTestComparisonShowChars,
	ECTestComparisonShowLines,
	ECTestComparisonShowLinesIgnoreWhitespace,
	ECTestComparisonDiff,
	ECTestComparisonDiffNoJSON,
	ECTestComparisonDefault
};

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


#define ECTestAssertNotNilFormat XCTAssertNotNil
#define ECTestAssertNilFormat XCTAssertNil
#define ECTestAssertTrueFormat XCTAssertTrue
#define ECTestAssertFalseFormat XCTAssertFalse
#define ECTestFail XCTFail

#ifdef _XCTPrimitiveAssertGreaterThan // indicates a newer version of XCTest
// Yosemite version of XCTest takes a self parameter for _XCTRegisterFailure
#define ECAssertTest(expr, isTrueVal, expString, description, ...)                                \
	do                                                                                            \
	{                                                                                             \
		if (!(expr))                                                                              \
		{                                                                                         \
			NSString* condition = [NSString stringWithFormat:@"assertion failed: %@", expString]; \
			_XCTRegisterFailure(self, condition, description, __VA_ARGS__);                       \
		}                                                                                         \
	} while (0)
#else
#define ECAssertTest(expr, isTrueVal, expString, description, ...)                                \
	do                                                                                            \
	{                                                                                             \
		if (!(expr))                                                                              \
		{                                                                                         \
			NSString* condition = [NSString stringWithFormat:@"assertion failed: %@", expString]; \
			_XCTRegisterFailure(condition, description, __VA_ARGS__);                             \
		}                                                                                         \
	} while (0)
#endif


//_XCTFailureHandler(self, isTrueVal, __FILE__, __LINE__, [NSString stringWithFormat:@"assertion failed: %@", expString], description, ##__VA_ARGS__);


#define ECTestAssertNotNil(x) ECTestAssertNotNilFormat((x), @"%s shouldn't be nil", #x)
#define ECTestAssertNil(x) ECTestAssertNilFormat((x), @"%s should be nil, was %0x", #x, (unsigned int)x)
#define ECTestAssertZero(x) ECTestAssertTrueFormat((x) == 0, @"%s should be zero, was %0x", #x, (unsigned int)x)
#define ECTestAssertTrue(x) ECTestAssertTrueFormat((x), "%s should be true", #x)
#define ECTestAssertFalse(x) ECTestAssertFalseFormat((x), "%s should be false", #x)
#define ECTestAssertStringIsEqual(x, y) ECAssertTest([(x)isEqualToString:(y)], NO, @"" #x " and " #y " match", @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertStringBeginsWith(x, y) ECAssertTest([ECTestCase string:(x) beginsWithString:(y)], NO, @"" #x " begins with " #y, @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertStringEndsWith(x, y) ECAssertTest([ECTestCase string:(x) endsWithString:(y)], NO, @"" #x " ends with " #y, @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertStringContains(x, y) ECAssertTest([ECTestCase string:x containsString:(y)], NO, @"" #x " contains " #y, @"Values were \"%@\" and \"%@\"", x, y)
#define ECTestAssertIsEmpty(x) ECAssertTest([ECTestCase genericCount:(x)] == 0, NO, @"Object" #x "is empty", @"Value is %@", x)
#define ECTestAssertNotEmpty(x) ECAssertTest([ECTestCase genericCount:(x)] != 0, YES, @"Object" #x "is empty", @"Value is %@", x)
#define ECTestAssertLength(x, l) ECAssertTest([ECTestCase genericCount:(x)] == l, NO, @"Length of " #x " is " #l, @"Value is %@, length is %ld", x, (long)[ECTestCase genericCount:x])
#define ECTestAssertIsEqual(x, y) ECAssertTest([(x) isEqual:(y)], NO, @"" #x " and " #y " are equal", @"Values were %@ and %@", x, y)
#define ECTestAssertIsNotEqual(x, y) ECAssertTest(![(x) isEqual:(y)], NO, @"" #x " and " #y " are not equal", @"Values were %@ and %@", x, y)
#define ECTestAssertTextIsEqual(x, y) [self assertString:(x) matchesString:(y)]
#define ECTestAssertNoError(e) ECTestAssertTrueFormat(e == 0, @"expected no error, but got %@", e)
#define ECTestAssertOkNoError(status, e) ECTestAssertTrueFormat(status, @"expected %s to be true, but got %@", #status, e)

#define ECTestAssertIsKindOfClass(o, c) ECTestAssertTrueFormat(((o) == nil) || [(o) isKindOfClass:[c class]], @"%s should be a kind of %s, is actually a %@", #o, #c, [o class])
#define ECTestAssertIsMemberOfClass(o, c) ECTestAssertTrueFormat(((o) == nil) || [(o) isMemberOfClass:[c class]], @"%s should be a %s, is actually a %@", #o, #c, [o class])

#define ECTestAssertOperator(x, t, y, f, c) ECAssertTest((x)t(y), NO, @"" #x #t #y, @"Values are " f " and " f ")", ((c)(x)), ((c)(y)))

#define ECTestAssertIntegerIsEqual(x, y) ECTestAssertOperator((x), ==, (y), "%ld", long)
#define ECTestAssertIntegerIsNotEqual(x, y) ECTestAssertOperator((x), !=, (y), "%ld", long)
#define ECTestAssertIntegerIsGreater(x, y) ECTestAssertOperator((x), >, (y), "%ld", long)
#define ECTestAssertIntegerIsGreaterEqual(x, y) ECTestAssertOperator((x), >=, (y), "%ld", long)
#define ECTestAssertIntegerIsLess(x, y) ECTestAssertOperator((x), <, (y), "%ld", long)
#define ECTestAssertIntegerIsLessEqual(x, y) ECTestAssertOperator((x), <=, (y), "%ld", long)

#define ECTestAssertRealIsEqual(x, y) ECTestAssertOperator((x), ==, (y), "%lf", double)
#define ECTestAssertRealIsNotEqual(x, y) ECTestAssertOperator((x), !=, (y), "%lf", double)
#define ECTestAssertRealIsGreater(x, y) ECTestAssertOperator((x), >, (y), "%lf", double)
#define ECTestAssertRealIsGreaterEqual(x, y) ECTestAssertOperator((x), >=, (y), "%lf", double)
#define ECTestAssertRealIsLess(x, y) ECTestAssertOperator((x), <, (y), "%lf", double)
#define ECTestAssertRealIsLessEqual(x, y) ECTestAssertOperator((x), <=, (y), "%lf", double)


#define ECTestLog NSLog

/**
* This class contains a few utility methods which:
*
* - support the macros
* - support using classes that need run loops from unit tests
*
* See [this blog post](http://www.bornsleepy.com/bornsleepy/run-loop-cocoa-unit-tests) for more details of the run loop support.
*/

@interface ECTestCase : XCTestCase

/**
 Perform some more detailed checking of two bits of text.
 @param string1 First string to compare.
 @param string2 Second string to compare.
 @return YES if the items match, NO otherwise
 */

- (BOOL)checkString:(NSString*)string1 matchesString:(NSString*)string2;

/**
 Perform some more detailed checking of two bits of text.
 If they don't match, we call ECTestFail reporting the point where they differed.
 @param string1 First string to compare.
 @param string2 Second string to compare.
 @return YES if the items match, NO otherwise
 */

- (BOOL)assertString:(NSString*)string1 matchesString:(NSString*)string2;

/**
 Perform some more detailed checking of two bits of text.
 
 The comparison modes determine exactly how differences are reported.
 - ECAssertStringTestShowChars:  we report the differing lengths, and the characters where they diverge
 - ECAssertStringTestShowLines: we report the lines where they diverge
 - ECAssertStringTestShowLinesIgnoreWhitespace: we report the lines where they diverge, ignoring blank lines
 
 @param string1 First string to compare.
 @param string2 Second string to compare.
 @param mode Comparison mode to use.
 @return YES if the items match, NO otherwise
 */

- (BOOL)checkString:(NSString*)string1 matchesString:(NSString*)string2 mode:(ECTestComparisonMode)mode;

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
 @return YES if the items match, NO otherwise
 */

- (BOOL)assertString:(NSString*)string1 matchesString:(NSString*)string2 mode:(ECTestComparisonMode)mode;

/**
 Check some text against a file.

 The comparison modes determine exactly how differences are reported.

 @param string The string to compare.
 @param url The file containing text to compare against.
 @param mode Comparison mode to use.
 @return YES if the items match, NO otherwise
 */

- (BOOL)checkString:(NSString*)string matchesContentsOfURL:(NSURL*)url mode:(ECTestComparisonMode)mode;

/**
 Check some text against a file.
 If they don't match, we call STFail reporting the point where they differed.
 
 The comparison modes determine exactly how differences are reported.
 
 @param string The string to compare.
 @param url The file containing text to compare against.
 @param mode Comparison mode to use.
 @return YES if the items match, NO otherwise
 */

- (BOOL)assertString:(NSString*)string matchesContentsOfURL:(NSURL*)url mode:(ECTestComparisonMode)mode;

/**
 Check that two collections match.
 If they don't match, we call STFail reporting the point where they differed.

 This is implemented by calling description on them both, then calling assertString:matchesString.
 @param collection1 first collection
 @param collection2 second collection
 @return YES if the items match, NO otherwise
 */

- (BOOL)assertCollection:(id)collection1 matchesCollection:(id)collection2;

/**
 Check that a collection matches the contents of a file.
 If they don't match, we call STFail reporting the point where they differed.

 This is implemented by calling description on them both, then calling assertString:matchesString.
 @param collection Collection to test.
 @param url The file to test against
 @param mode The testing mode.
 @return YES if the items match, NO otherwise
 */

- (BOOL)assertCollection:(id)collection matchesContentsOfURL:(NSURL*)url mode:(ECTestComparisonMode)mode;

/**
 Check that two collections match.
 If they don't match, we call STFail reporting the point where they differed.

 This is implemented by calling description on them both, then calling assertString:matchesString.
 @param collection1 First collection.
 @param collection2 Second collection.
 @param mode String comparison mode to use.
 @return YES if the items match, NO otherwise
 */

- (BOOL)assertCollection:(id)collection1 matchesCollection:(id)collection2 mode:(ECTestComparisonMode)mode;

+ (NSUInteger)genericCount:(id)item;
+ (BOOL)string:(NSString*)string1 beginsWithString:(NSString*)string2;
+ (BOOL)string:(NSString*)string1 endsWithString:(NSString*)string2;
+ (BOOL)string:(NSString*)string1 containsString:(NSString*)string2;

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

- (NSURL*)URLForTemporaryFileNamed:(NSString*)name withExtension:(NSString*)ext;

/**
 Return a list of URLs of all files in a folder with the test class's name, inside the test bundle's Resource folder, which match the extension.
 */

+ (NSArray*)URLsForTestResourcesWithExtension:(NSString*)extension;


- (NSURL*)URLForTestResource:(NSString*)name withExtension:(NSString*)ext;
- (NSURL*)URLForTestResource:(NSString*)name withExtension:(NSString*)ext subdirectory:(NSString*)subpath;

- (NSBundle*)exampleBundle;
- (NSURL*)exampleBundleURL;
- (NSString*)exampleBundlePath;

/**
 Prepare for some code which is going to run asynchronously and will call
 timeToExitRunLoop and runUntilTimeToExit.
 
 Calling this method signals that we want to use an XCTestExpectation
 to do the timing.
 
 If we just call runUntilTimeToExit without first calling this, we'll do the
 synchronisation the old way (with a boolean flag).
 */

- (void)prepareForRunLoopTest;

/**
 Pause in this thread until something calls timeToExitRunLoop.
 */

- (void)runUntilTimeToExit;

/**
 Pause in this thread until something calls timeToExitRunLoop,
 or we time out.
 */

- (void)runUntilTimeToExitOrTimeout:(NSTimeInterval)timeout;


/**
 Indicate that our asynchronous task is finished, and it's now time to return from the runUntilTimeToExit call.
 */

- (void)timeToExitRunLoop;


/**
 Compare two files and output a diff.
 The diff program is /usr/bin/diff by default, but can be changed with defaults, e.g:
     defaults write xctext DiffTool "/usr/local/bin/ksdiff"

 @param url1 Location of first file to diff.
 @param url2 Location of second file to diff.
 */

- (void)diffURL:(NSURL*)url1 againstURL:(NSURL*)url2;

/**
 The name to use for determining output file locations for this test module.
 By default, we use the name of the test bundle.
 */

+ (NSString*)testModuleName;

/**
 URL of the folder to use for test output.
 @param asReference If true, the output will be the reference version of the file, if false, the version generated by this test.
 */

- (NSURL*)URLForOutputAsReference:(BOOL)asReference;

/**
 Write some data as an output file.
 */

- (NSURL*)writeOutputData:(NSDictionary*)dictionary name:(NSString*)name extension:(NSString*)extension asReference:(BOOL)asReference;

/**
 Write some text as an output file.
 */

- (NSURL*)writeOutputText:(NSString*)data name:(NSString*)name extension:(NSString*)extension asReference:(BOOL)asReference;

#if !TARGET_OS_IPHONE

/**
 Run a command line tool and return its output.
 */

- (NSData*)runCommand:(NSString*)command arguments:(NSArray*)arguments;

/**
 Run a command line tool and return its output.
 */

- (NSData*)runCommand:(NSString*)command arguments:(NSArray*)arguments status:(int*)status;

/**
 Write an image as an output file.
 */

- (NSURL*)writeOutputImage:(NSBitmapImageRep*)image name:(NSString*)name asReference:(BOOL)asReference;

/**
 Compare two bitmap images as PNGs and report whether they are equal.
 
 @param image Image to compare.
 @param reference Reference image to compare against.
 @return YES if the images are identical after conversion to PNG.
 */

- (BOOL)imageAsPNG:(NSBitmapImageRep*)image exactlyMatchesReferenceImageAsPNG:(NSBitmapImageRep*)reference;

/**
 Compare two bitmaps images and say whether they match within a certain threshold of error.
 
 @param image Image to compare.
 @param reference Reference image to compare against.
 @param properties A dictionary of properties which fine-tune the comparison:
 The properties include:
 - threshold The maximum average difference allowed between each of the corresponding pixels.
 - pixelThreshold The maximum difference allowed between any two corresponding pixels.
 - maxWidth The maximum width of the image that's allowed (to avoid trying to compare images that are enourmous).
 - maxHeight The maximum width of the image that's allowed (to avoid trying to compare images that are enourmous).
 - maxSize: The value to use for both maxWidth and maxHeight
 - maxSizeMatchesReference: Ignore maxWidth/maxHeight and use the size of the reference image instead.
 @return YES if the images match within the given thresholds.
 */

- (BOOL)image:(NSBitmapImageRep*)image matchesReferenceImage:(NSBitmapImageRep*)reference properties:(NSDictionary*)properties;

/**
 Return an image from the test bundle.
 */

- (NSImage*)imageNamed:(NSString*)name;

#endif

@end
