// --------------------------------------------------------------------------
//
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"
#import "NSString+ECLogging.h"

@interface StringTests : ECTestCase
{
}

@end

@implementation StringTests

#pragma mark - Tests

- (void)testStringBySplittingMixedCaps
{
	ECTestAssertStringIsEqual([@"mixedCapTest" stringBySplittingMixedCaps], @"mixed Cap Test");
	ECTestAssertStringIsEqual([@"alllowercaseoneword" stringBySplittingMixedCaps], @"alllowercaseoneword");
	ECTestAssertStringIsEqual([@"all lower case multiple words" stringBySplittingMixedCaps], @"all lower case multiple words");
	ECTestAssertStringIsEqual([@"" stringBySplittingMixedCaps], @"");
}

- (void)testLastLines
{
	NSString* threeLines = [@[@"line1", @"line2", @"line3"] componentsJoinedByString:@"\n"];
	NSString* lastTwoLines = [@[@"line2", @"line3"] componentsJoinedByString:@"\n"];

	ECTestAssertStringIsEqual([threeLines lastLines:0], @"");
	ECTestAssertStringIsEqual([threeLines lastLines:1], @"line3");
	ECTestAssertStringIsEqual([threeLines lastLines:2], lastTwoLines);
	ECTestAssertStringIsEqual([threeLines lastLines:3], threeLines);
	ECTestAssertStringIsEqual([threeLines lastLines:4], threeLines);
}

- (void)testFirstLines
{
	NSString* threeLines = [@[@"line1", @"line2", @"line3"] componentsJoinedByString:@"\n"];
	NSString* firstTwoLines = [@[@"line1", @"line2"] componentsJoinedByString:@"\n"];

	ECTestAssertStringIsEqual([threeLines firstLines:0], @"");
	ECTestAssertStringIsEqual([threeLines firstLines:1], @"line1");
	ECTestAssertStringIsEqual([threeLines firstLines:2], firstTwoLines);
	ECTestAssertStringIsEqual([threeLines firstLines:3], threeLines);
	ECTestAssertStringIsEqual([threeLines firstLines:4], threeLines);
}

- (void)testMatchesString1
{
	NSString* test1 = @"This is a test string";
	NSString* test2 = @"This is a different string";

	NSString* after;
	NSUInteger index;
	UniChar divergent, expected;
	BOOL result = [test1 matchesString:test2 divergingAfter:&after atIndex:&index divergentChar:&divergent expectedChar:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(index, 10);
	ECTestAssertIntegerIsEqual(divergent, 't');
	ECTestAssertIntegerIsEqual(expected, 'd');

	result = [test1 matchesString:test1 divergingAfter:&after atIndex:&index divergentChar:&divergent expectedChar:&expected];
	ECTestAssertTrue(result);

	result = [@"" matchesString:@"" divergingAfter:&after atIndex:&index divergentChar:&divergent expectedChar:&expected];
	ECTestAssertTrue(result);

	result = [test1 matchesString:@"" divergingAfter:&after atIndex:&index divergentChar:&divergent expectedChar:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(index, 0);

	result = [@"" matchesString:test1 divergingAfter:&after atIndex:&index divergentChar:&divergent expectedChar:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(index, 0);

	result = [@"" matchesString:nil divergingAfter:&after atIndex:&index divergentChar:&divergent expectedChar:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(index, 0);
}


#if 0
- (BOOL)matchesString:(NSString *)string divergingAtLine:(NSUInteger*)divergingLine after:(NSString**)after diverged:(NSString**)diverged expected:(NSString**)expected;
- (BOOL)matchesString:(NSString *)string divergingAtLine1:(NSUInteger*)line1 andLine2:(NSUInteger*)line2 diverged:(NSString**)diverged expected:(NSString**)expected;
#endif

@end