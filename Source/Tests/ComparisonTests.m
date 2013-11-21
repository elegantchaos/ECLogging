//
//  ComparisonTests.m
//  ECLogging
//
//  Created by Sam Deane on 21/11/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECUnitTests.h"

@interface ComparisonTests : ECTestCase
@property (strong, nonatomic) NSString* output;
@end

@implementation ComparisonTests

- (BOOL)item:(id)item1 matches:(id)item2
{
	NSMutableString* string = [NSMutableString new];
	BOOL result = [item1 matches:item2 block:^(NSString *context, id i1, id i2) {
		[string appendFormat:@"%@: %@ didn't match %@\n", context, i1, i2];
	}];

	self.output = string;
	
	return result;
}

- (void)testStringsEqual
{
	ECTestAssertTrue([self item:@"abc" matches:@"abc"]);
	ECTestAssertIsEqual(self.output, @"");
}

- (void)testStringsDifferent
{
	ECTestAssertFalse([self item:@"abc" matches:@"def"]);
	ECTestAssertIsEqual(self.output, @"__NSCFConstantString: abc didn't match def\n");
}

- (void)testArraysEqual
{
	NSArray* a1 = @[@"abc", @"def"];
	NSArray* a2 = @[@"abc", @"def"];
	ECTestAssertTrue([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"");
}

- (void)testArraysDifferent
{
	NSArray* a1 = @[@"abc", @"def"];
	NSArray* a2 = @[@"def", @"abc"];
	ECTestAssertFalse([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"__NSArrayI\n\tarray item 0: abc didn't match def\n__NSArrayI\n\tarray item 1: def didn't match abc\n");
}

- (void)testArraysShorter
{
	NSArray* a1 = @[@"abc", @"def"];
	NSArray* a2 = @[@"abc"];
	ECTestAssertFalse([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"__NSArrayI\n\tarray missing item 1: def didn't match (null)\n");
}

- (void)testArraysLonger
{
	NSArray* a1 = @[@"abc"];
	NSArray* a2 = @[@"abc", @"def"];
	ECTestAssertFalse([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"__NSArrayI\n\tarray extra item 1: (null) didn't match def\n");
}

- (void)testArraysDifferentAndLonger
{
	NSArray* a1 = @[@"abc"];
	NSArray* a2 = @[@"def", @"abc"];
	ECTestAssertFalse([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"__NSArrayI\n\tarray item 0: abc didn't match def\n__NSArrayI\n\tarray extra item 1: (null) didn't match abc\n");
}

@end
