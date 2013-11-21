// --------------------------------------------------------------------------
///  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
///  This source code is distributed under the terms of Elegant Chaos's
///  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"
#import "ECParameterisedTestCase.h"
#import "ECTestComparisons.h"
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

- (NSURL*)URLForTemporaryFolder
{
	NSURL* url = nil;
	NSError* error;
	NSUInteger length = [self.name length];
	if (length > 2)
	{
		NSString* name = [self.name substringWithRange:NSMakeRange(2, length - 3)];
		url = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:name];
		[[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error];
	}
	
	return url;
}

- (NSURL*)URLForTemporaryFileNamed:(NSString *)name
{
	NSURL* url = [[self URLForTemporaryFolder] URLByAppendingPathComponent:name];

	return url;
}

- (NSURL*)URLForTemporaryFileNamed:(NSString *)name withExtension:(NSString *)ext
{
	NSURL* url = [[[self URLForTemporaryFolder] URLByAppendingPathComponent:name] URLByAppendingPathExtension:ext];

	return url;
}

- (BOOL)assertString:(NSString*)string1 matchesString:(NSString*)string2
{
	return [self assertString:string1 matchesString:string2 mode:ECAssertStringTestShowLinesIgnoreWhitespace];
}

- (BOOL)assertCharactersOfString:(NSString*)string1 matchesString:(NSString*)string2
{
	NSUInteger divergence;
	UniChar divergentChar;
	UniChar expectedChar;
	NSString* prefix;
    BOOL result = [string1 matchesString:string2 divergingAfter:&prefix atIndex:&divergence divergentChar:&divergentChar expectedChar:&expectedChar];
	if (!result)
    {
        ECTestFail(@"strings diverge at character %d ('%lc' instead of '%lc')\n\nwe expected:\n%@\n\nwe got:\n%@\n\nthe bit that matched:\n%@\n\nthe bit that didn't:\n%@", (int)divergence, divergentChar, expectedChar, string2, string1, prefix, [string1 substringFromIndex:divergence]);
    }

	return result;
}

- (BOOL)assertCollection:(id)collection1 matchesCollection:(id)collection2
{
	BOOL result = [collection1 matches:collection2 block:^(NSString *context, NSUInteger level, id i1, id i2) {
		ECTestFail(@"%@: %@ didn't match %@\n", context, i1, i2);
	}];

	return result;
}

- (BOOL)assertLinesOfString:(NSString *)string1 matchesString:(NSString *)string2
{
	NSString* after, *diverged, *expected;
	NSUInteger line;
	BOOL result = [string1 matchesString:string2 divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
    if (!result)
	{
		ECTestFail(@"strings diverge around line %ld:\n%@\n\nwe expected:'%@'\n\nwe got:'%@'\n\nfull string was:\n%@", (long)line, after, expected, diverged, string1);
	}

	return result;
}

- (BOOL)assertCollection:(id)collection1 matchesCollection:(id)collection2 mode:(ECAssertStringTestMode)mode
{
	// NB if the collections dont match, we convert them to strings and try again - so [collection1 isEqual:collection2] may
	//       return NO, but as long as the string descriptions match, we don't assert
	BOOL collectionsMatch = [collection1 isEqual:collection2];
	NSString* string1;
	NSString* string2;
	if (!collectionsMatch)
	{
		string1 = [collection1 description];
		string2 = [collection2 description];
		collectionsMatch = [string1 isEqualToString:string2];
	}


	if (!collectionsMatch)
	{
		if ((mode == ECAssertStringDiff) || (mode == ECAssertStringDiffNoJSON))
		{
			NSURL* temp1 = [self URLForTemporaryFileNamed:@"collection1"];
			NSURL* temp2 = [self URLForTemporaryFileNamed:@"collection2"];

			if (mode == ECAssertStringDiffNoJSON)
			{
				[self diffAsTextString1:string1 string2:string2 temp1:temp1 temp2:temp2];
			}
			else
			{
				// try to write as JSON - might not work but it'll produce nicer output
				@try {
					[self diffAsJSONCollection:collection1 collection2:collection2 temp1:temp1 temp2:temp2];
				}
				@catch (NSException *exception) {
					[self diffAsTextString1:string1 string2:string2 temp1:temp1 temp2:temp2];
				}
			}

			ECTestFail(@"collections failed to match");
		}
		else
		{
			collectionsMatch = [self assertString:string1 matchesString:string2 mode:mode];
		}
	}

	return collectionsMatch;
}

- (void)diffAsJSONCollection:(id)collection1 collection2:(id)collection2 temp1:(NSURL*)temp1 temp2:(NSURL*)temp2
{
	NSError* error = nil;
	NSData* data1 = [NSJSONSerialization dataWithJSONObject:collection1 options:NSJSONWritingPrettyPrinted error:&error];
	NSData* data2 = [NSJSONSerialization dataWithJSONObject:collection2 options:NSJSONWritingPrettyPrinted error:&error];
	[data1 writeToURL:temp1 atomically:YES];
	[data2 writeToURL:temp2 atomically:YES];
	[self diffURL:temp1 againstURL:temp2];
}

- (void)diffAsTextString1:(id)string1 string2:(id)string2 temp1:(NSURL*)temp1 temp2:(NSURL*)temp2
{
	NSError* error = nil;
	[string1 writeToURL:temp1 atomically:YES encoding:NSUTF8StringEncoding error:&error];
	[string2 writeToURL:temp2 atomically:YES encoding:NSUTF8StringEncoding error:&error];
	[self diffURL:temp1 againstURL:temp2];
}

- (BOOL)assertLinesIgnoringWhitespaceOfString:(NSString *)string1 matchesString:(NSString *)string2
{
	NSString* diverged;
	NSString* expected;
	NSUInteger line1, line2;
	BOOL result = [string1 matchesString:string2 divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected];
    if (!result)
	{
		ECTestFail(@"strings diverge at lines %ld/%ld:\nwe expected:'%@'\n\nwe got:'%@'\n\n", (long)line1, (long)line2, expected, diverged);
		if ([string1 length] < 1000)
			NSLog(@"full string was %@", string1);
	}

	return result;
}

- (BOOL)assertString:(NSString*)string1 matchesString:(NSString*)string2 mode:(ECAssertStringTestMode)mode
{
	BOOL result = YES;
	ECTestAssertNotNil(string1);
	ECTestAssertNotNil(string2);
	if (string1 && string2)
	{
		switch (mode)
		{
			case ECAssertStringTestShowChars:
				result = [self assertCharactersOfString:string1 matchesString:string2];
				break;

			case ECAssertStringTestShowLines:
				result = [self assertLinesOfString:string1 matchesString:string2];
				break;

			case ECAssertStringTestShowLinesIgnoreWhitespace:
			default:
				result = [self assertLinesIgnoringWhitespaceOfString:string1 matchesString:string2];
				break;
		}
	}
}

- (BOOL)assertCollection:(id)collection matchesContentsOfURL:(NSURL*)url mode:(ECAssertStringTestMode)mode
{
	BOOL result = YES;
	NSError* error;
	NSString* kind = [url pathExtension];
	if ([kind isEqualToString:@"json"])
	{
		id expected = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:url] options:0 error:&error];
		if (![collection isEqual:expected])
		{
			NSData* data = [NSJSONSerialization dataWithJSONObject:collection options:NSJSONWritingPrettyPrinted error:&error];

			NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			ECTestAssertNotNil(string);
			result = [self assertString:string matchesContentsOfURL:url mode:mode];
		}
	}
	else if ([kind isEqualToString:@"plist"])
	{
		NSData* data = [NSData dataWithContentsOfURL:url];
		ECTestAssertNotNil(data);
		id expected = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:nil error:&error];
		result = [self assertCollection:collection matchesCollection:expected mode:mode];
	}

	return result;
}

- (BOOL)assertString:(NSString*)string matchesContentsOfURL:(NSURL*)url mode:(ECAssertStringTestMode)mode
{
	BOOL result = YES;
	NSError* error;
	NSString* expected = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
	if (expected)
	{
		#if !TARGET_OS_IPHONE
		if (mode == ECAssertStringDiff)
		{
			if (![string isEqualToString:expected])
			{
				NSString* name = [url lastPathComponent];
				NSURL* temp = [self URLForTemporaryFileNamed:[@"Actual-" stringByAppendingString:name]];
				ECTestAssertTrueFormat([string writeToURL:temp atomically:YES encoding:NSUTF8StringEncoding error:&error], @"failed to write temporary text file %@", error);
				[self diffURL:temp againstURL:url];
				ECTestFail(@"String failed to match contents of %@", name);
				result = NO;
			}
		}
		else
		#endif
		{
			result = [self assertString:string matchesString:expected mode:mode];
		}
	}
	else
	{
		ECTestFail(@"Couldn't load string from %@", url);
		result = NO;
	}

	return result;
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

- (NSURL *)URLForTestResource:(NSString *)name withExtension:(NSString *)ext
{
	NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	return [bundle URLForResource:name withExtension:ext];
}

- (NSURL *)URLForTestResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath
{
	NSBundle* bundle = [NSBundle bundleForClass:[self class]];
	return [bundle URLForResource:name withExtension:ext subdirectory:subpath];
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

- (void)diffAsPlistObject:(id)object1 againstObject:(id)object2
{
	NSURL* temp1 = [self URLForTemporaryFileNamed:@"object1"];
	NSURL* temp2 = [self URLForTemporaryFileNamed:@"object2"];

	NSMutableData* data1 = [NSMutableData data];
	NSKeyedArchiver* archiver1 = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data1];
	[archiver1 setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[archiver1 encodeObject:object1 forKey:@"root"];
	[archiver1 finishEncoding];

	NSMutableData* data2 = [NSMutableData data];
	NSKeyedArchiver* archiver2 = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data2];
	[archiver2 setOutputFormat:NSPropertyListXMLFormat_v1_0];
	[archiver2 encodeObject:object2 forKey:@"root"];
	[archiver2 finishEncoding];

	[data1 writeToURL:temp1 atomically:YES];
	[data2 writeToURL:temp2 atomically:YES];
	[self diffURL:temp1 againstURL:temp2];

}
- (void)diffURL:(NSURL*)url1 againstURL:(NSURL*)url2
{
#if !TARGET_OS_IPHONE // this doesn't make a lot of sense on iOS
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	// To use a different diff tool, do, eg:
    //         defaults write otest DiffTool "/usr/local/bin/ksdiff"
	//
	// or uncomment below:
//	[defaults setObject:@"/usr/local/bin/ksdiff" forKey:@"DiffTool"];
//	[defaults synchronize];

	NSString* diff = [defaults stringForKey:@"DiffTool"];
    if (!diff)
        diff = @"/usr/bin/diff";

	NSTask *task;
	task = [[NSTask alloc] init];
	[task setLaunchPath: diff];
	[task setArguments: @[[url1 path], [url2 path]]];
	[task launch];
#endif
}

@end

