// --------------------------------------------------------------------------
//
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
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
	ECTestAssertStringIsEqual([@"" stringBySplittingMixedCaps], @"");
	ECTestAssertStringIsEqual([@"all lower case multiple words" stringBySplittingMixedCaps], @"all lower case multiple words");
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

	result = [@"AAA" matchesString:@"BBB" divergingAfter:&after atIndex:&index divergentChar:&divergent expectedChar:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(index, 0);
	ECTestAssertIntegerIsEqual(divergent, 'A');
	ECTestAssertIntegerIsEqual(expected, 'B');
}

- (void)testMatchesString2
{
	NSString* test1 = @"This is a\ntest string";
	NSString* test2 = @"This is a\ndifferent string";

	NSString *diverged, *expected;
	NSUInteger line1, line2;
	BOOL result = [test1 matchesString:test2 divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected window:0];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line1, 1);
	ECTestAssertIntegerIsEqual(line2, 1);
	ECTestAssertStringIsEqual(diverged, @"test string");
	ECTestAssertStringIsEqual(expected, @"different string");

	result = [test1 matchesString:test1 divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected];
	ECTestAssertTrue(result);

	result = [@"" matchesString:@"" divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected];
	ECTestAssertTrue(result);

	result = [test1 matchesString:@"" divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line1, 0);
	ECTestAssertIntegerIsEqual(line2, 0);

	result = [@"" matchesString:test1 divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line1, 0);
	ECTestAssertIntegerIsEqual(line2, 0);

	result = [@"" matchesString:nil divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line1, 0);
	ECTestAssertIntegerIsEqual(line2, 0);

	result = [@"AAA" matchesString:@"BBB" divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line1, 0);
	ECTestAssertIntegerIsEqual(line2, 0);
	ECTestAssertStringIsEqual(diverged, @"AAA");
	ECTestAssertStringIsEqual(expected, @"BBB");
}

- (void)testMatchesString3
{
	NSString* test1 = @"This is a\ntest string";
	NSString* test2 = @"This is a\ndifferent string";

	NSString *after, *diverged, *expected;
	NSUInteger line;
	BOOL result = [test1 matchesString:test2 divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line, 1);
	ECTestAssertStringIsEqual(after, @"This is a\n");
	ECTestAssertStringIsEqual(diverged, @"test string");
	ECTestAssertStringIsEqual(expected, @"different string");

	result = [test1 matchesString:test1 divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
	ECTestAssertTrue(result);

	result = [@"" matchesString:@"" divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
	ECTestAssertTrue(result);

	result = [test1 matchesString:@"" divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line, 0);

	result = [@"" matchesString:test1 divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line, 0);

	result = [@"" matchesString:nil divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line, 0);

	result = [@"AAA" matchesString:@"BBB" divergingAtLine:&line after:&after diverged:&diverged expected:&expected];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line, 0);
}

- (void)testMatchesStringWindow
{
	NSString* test1 = @"l1\nl2\nl3\ntest string\nl5\nl6";
	NSString* test2 = @"l1\nl2\nl3\ndifferent string\nl5\nl6";

	NSString *diverged, *expected;
	NSUInteger line1, line2;

	BOOL result = [test1 matchesString:test2 divergingAtLine1:&line1 andLine2:&line2 diverged:&diverged expected:&expected window:1];
	ECTestAssertFalse(result);
	ECTestAssertIntegerIsEqual(line1, 3);
	ECTestAssertIntegerIsEqual(line2, 3);
	ECTestAssertStringIsEqual(diverged, @"l3\ntest string\nl5\n");
	ECTestAssertStringIsEqual(expected, @"l3\ndifferent string\nl5\n");
}

@end