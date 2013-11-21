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
	BOOL result = [item1 matches:item2 block:^(NSString *context, NSUInteger level, id i1, id i2) {
		[string appendFormat:@"%@: %@ didn't match %@\n", context, i1, i2];
	}];

	self.output = string;
	NSLog(@"Output:\n%@", string);
	
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
	ECTestAssertIsEqual(self.output, @"__NSArrayI[0]: abc didn't match def\n__NSArrayI[1]: def didn't match abc\n");
}

- (void)testArraysShorter
{
	NSArray* a1 = @[@"abc", @"def"];
	NSArray* a2 = @[@"abc"];
	ECTestAssertFalse([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"__NSArrayI[1] missing item: def didn't match (null)\n");
}

- (void)testArraysLonger
{
	NSArray* a1 = @[@"abc"];
	NSArray* a2 = @[@"abc", @"def"];
	ECTestAssertFalse([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"__NSArrayI[1] extra item: (null) didn't match def\n");
}

- (void)testArraysDifferentAndLonger
{
	NSArray* a1 = @[@"abc"];
	NSArray* a2 = @[@"def", @"abc"];
	ECTestAssertFalse([self item:a1 matches:a2]);
	ECTestAssertIsEqual(self.output, @"__NSArrayI[0]: abc didn't match def\n__NSArrayI[1] extra item: (null) didn't match abc\n");
}

- (void)testDictionariesEqual
{
	NSDictionary* d1 = @{@"k1":@"abc", @"k2":@"def"};
	NSDictionary* d2 = @{@"k1":@"abc", @"k2":@"def"};
	ECTestAssertTrue([self item:d1 matches:d2]);
	ECTestAssertIsEqual(self.output, @"");
}

- (void)testDictionariesDifferent
{
	NSDictionary* d1 = @{@"k1":@"abc", @"k2":@"def"};
	NSDictionary* d2 = @{@"k1":@"def", @"k2":@"abc"};
	ECTestAssertFalse([self item:d1 matches:d2]);
	ECTestAssertIsEqual(self.output, @"__NSDictionaryI[@\"k2\"]: def didn't match abc\n__NSDictionaryI[@\"k1\"]: abc didn't match def\n");
}

- (void)testDictionariesShorter
{
	NSDictionary* d1 = @{@"k1":@"abc", @"k2":@"def"};
	NSDictionary* d2 = @{@"k1":@"abc"};
	ECTestAssertFalse([self item:d1 matches:d2]);
	ECTestAssertIsEqual(self.output, @"__NSDictionaryI[@\"k2\"] missing key: def didn't match (null)\n");
}

- (void)testDictionariesLonger
{
	NSDictionary* d1 = @{@"k1":@"abc"};
	NSDictionary* d2 = @{@"k1":@"abc", @"k2":@"def"};
	ECTestAssertFalse([self item:d1 matches:d2]);
	ECTestAssertIsEqual(self.output, @"__NSDictionaryI[@\"k2\"] extra key: (null) didn't match def\n");
}

- (void)testDictionariesDifferentAndLonger
{
	NSDictionary* d1 = @{@"k1":@"abc"};
	NSDictionary* d2 = @{@"k1":@"def", @"k2":@"abc"};
	ECTestAssertFalse([self item:d1 matches:d2]);
	ECTestAssertIsEqual(self.output, @"__NSDictionaryI[@\"k1\"]: abc didn't match def\n__NSDictionaryI[@\"k2\"] extra key: (null) didn't match abc\n");
}

- (void)testCompound
{
	id item1 = @{@"k1":@[@"abc", @{@"k2" : @"def"}]};
	id item2 = @{@"k1":@[@"def", @{@"k3" : @"def"}]};
	ECTestAssertFalse([self item:item1 matches:item2]);
	ECTestAssertIsEqual(self.output, @"__NSDictionaryI[@\"k1\"][0]: abc didn't match def\n__NSDictionaryI[@\"k1\"][1][@\"k2\"] missing key: def didn't match (null)\n__NSDictionaryI[@\"k1\"][1][@\"k3\"] extra key: (null) didn't match def\n");
}

@end
