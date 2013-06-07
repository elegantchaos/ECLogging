// --------------------------------------------------------------------------
///  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
///  This source code is distributed under the terms of Elegant Chaos's
///  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"
#import "ECParameterisedTestCase.h"
#import "NSString+ECLogging.h"

@interface ECTestCase()

@property (assign, atomic) BOOL exitRunLoop;

@end

@implementation ECTestCase

@synthesize exitRunLoop = _exitRunLoop;

// --------------------------------------------------------------------------
/// Return the default test suite.
/// We don't want ECTestCase to show up in the unit test
/// output, since it is an abstract class and has no tests of
/// its own.
/// So we suppress generation of a suite for these classes.
// --------------------------------------------------------------------------

+ (id) defaultTestSuite
{
    id result = nil;
    if (self != [ECTestCase class])
    {
        result = [super defaultTestSuite];
    }
    
    return result;
}

// --------------------------------------------------------------------------
/// Perform some more detailed checking of two bits of text.
/// If they don't match, we report the differing lengths, and
/// the characters where they diverge, as well as the full
/// text of both strings.
// --------------------------------------------------------------------------

- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2
{
    if (![string1 isEqualToString:string2])
    {
        NSString* prefix = [string1 commonPrefixWithString:string2 options:NSLiteralSearch];
        NSUInteger divergence = [prefix length];
        UniChar divergentChar = [string1 characterAtIndex:divergence];
        UniChar expectedChar = [string2 characterAtIndex:divergence];
        STFail(@"strings diverge at character %d ('%lc' instead of '%lc')\n\nwe expected:\n%@\n\nwe got:\n%@\n\nthe bit that matched:\n%@\n\nthe bit that didn't:\n%@", divergence, divergentChar, expectedChar, string2, string1, prefix, [string1 substringFromIndex:divergence]); 
    }
}

- (void)assertLinesOfString:(NSString *)string1 matchesString:(NSString *)string2
{
    if (![string1 isEqualToString:string2])
	{
		NSString* common = [string1 commonPrefixWithString:string2 options:0];
		NSString* string1Diverged = [[string1 substringFromIndex:[common length]] firstLines:2];
		NSString* string2Diverged = [[string2 substringFromIndex:[common length]] firstLines:2];
		STFail(@"strings diverge around line %ld:\n%@\n\nwe expected:'%@'\n\nwe got:'%@'\n\nfull string was:\n%@", [[common componentsSeparatedByString:@"\n"] count], [common lastLines:2], string2Diverged, string1Diverged, string1);
	}
}

- (void)assertLinesIgnoringWhitespaceOfString:(NSString *)string1 matchesString:(NSString *)string2
{
    if (![string1 isEqualToString:string2])
	{
		NSCharacterSet* ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		NSArray* lines1 = [string1 componentsSeparatedByString:@"\n"];
		NSArray* lines2 = [string2 componentsSeparatedByString:@"\n"];
		NSUInteger count1 = [lines1 count];
		NSUInteger count2 = [lines2 count];
		NSUInteger n1 = 0;
		NSUInteger n2 = 0;
		while ((n1 < count1) && (n2 < count2))
		{
			NSString* trimmed1 = [lines1[n1] stringByTrimmingCharactersInSet:ws];
			NSString* trimmed2 = [lines2[n2] stringByTrimmingCharactersInSet:ws];
			if ([trimmed1 isEqualToString:trimmed2])
			{
				++n1;
				++n2;
			}
			else if ([trimmed1 length] == 0)
			{
				++n1;
			}
			else if ([trimmed2 length] == 0)
			{
				++n2;
			}
			else
			{
				STFail(@"strings diverge at lines %ld/%ld:\nwe expected:'%@'\n\nwe got:'%@'\n\nfull string was:\n%@", n1, n2, trimmed2, trimmed1, string1);
				break;
			}
		}
	}
}

- (void)assertString:(NSString*)string1 matchesString:(NSString*)string2 mode:(ECAssertStringTestMode)mode
{
	switch (mode)
	{
		case ECAssertStringTestShowChars:
			[self assertString:string1 matchesString:string2];
			break;

		case ECAssertStringTestShowLines:
			[self assertLinesOfString:string1 matchesString:string2];
			break;

		case ECAssertStringTestShowLinesIgnoreWhitespace:
		default:
			[self assertLinesIgnoringWhitespaceOfString:string1 matchesString:string2];
			break;
	}
}

// --------------------------------------------------------------------------
/// Return a count for any item that supports the count or length methods.
/// Used in various test assert macros.
// --------------------------------------------------------------------------

+ (NSUInteger)genericCount:(id)item
{
	NSUInteger result;
	
	if ([item respondsToSelector:@selector(length)])
	{
		result = [(NSString*)item length]; // NB doesn't have to be a string, the cast is just there to stop xcode complaining about multiple method signatures
	}
	else if ([item respondsToSelector:@selector(count)])
	{
		result = [(NSArray*)item count]; // NB doesn't have to be an array, the cast is kust there to stop xcode complaining about multiple method signatures
	}
	else
	{
		result = 0;
	}
	
	return result;
}


// --------------------------------------------------------------------------
/// Does this string begin with another string?
/// Returns NO when passed the empty string.
// --------------------------------------------------------------------------

+ (BOOL)string:(NSString*)string1 beginsWithString:(NSString *)string2
{
	NSRange range = [string1 rangeOfString:string2];
	
	return range.location == 0;
}

// --------------------------------------------------------------------------
/// Does this string end with another string.
/// Returns NO when passed the empty string.
// --------------------------------------------------------------------------

+ (BOOL)string:(NSString*)string1 endsWithString:(NSString *)string2
{
	NSUInteger length = [string2 length];
	BOOL result = length > 0;
	if (result)
	{
		NSUInteger ourLength = [string1 length];
		result = (length <= ourLength);
		if (result)
		{
			NSString* substring = [string1 substringFromIndex:ourLength - length];
			result = [string2 isEqualToString:substring];
		}
	}
	
	return result;
}

// --------------------------------------------------------------------------
/// Does this string contain another string?
/// Returns NO when passed the empty string.
// --------------------------------------------------------------------------

+ (BOOL)string:(NSString*)string1 containsString:(NSString *)string2
{
	NSRange range = [string1 rangeOfString:string2];
	
	return range.location != NSNotFound;
}

// --------------------------------------------------------------------------
/// Return file path for a bundle which can be used for file tests.
// --------------------------------------------------------------------------

- (NSString*)exampleBundlePath
{
	// find test bundle in our resources
	NSBundle* ourBundle = [NSBundle bundleForClass:[self class]];
	NSString* path = [ourBundle pathForResource:@"Test" ofType:@"bundle"];
	
	return path;
}

// --------------------------------------------------------------------------
/// Return file URL for a bundle which can be used for file tests.
// --------------------------------------------------------------------------

- (NSURL*)exampleBundleURL
{
	NSURL* url = [NSURL fileURLWithPath:[self exampleBundlePath]];
	
	return url;
}

// --------------------------------------------------------------------------
/// Return a bundle which can be used for file tests.
// --------------------------------------------------------------------------

- (NSBundle*)exampleBundle
{
	NSBundle* bundle = [NSBundle bundleWithPath:[self exampleBundlePath]];
	
	return bundle;
}

// --------------------------------------------------------------------------
/// Some tests need the run loop to run for a while, for example
/// to perform an asynchronous network request.
/// This method runs until something external (such as a
/// delegate method) sets the exitRunLoop flag.
// --------------------------------------------------------------------------

- (void)runUntilTimeToExit
{
    self.exitRunLoop = NO;
    while (!self.exitRunLoop)
    {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    }
}

- (void)timeToExitRunLoop
{
    self.exitRunLoop = YES;
}

@end

