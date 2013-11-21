//
//  ComparisonTests.m
//  ECLogging
//
//  Created by Sam Deane on 21/11/2013.
//  Copyright (c) 2013 Elegant Chaos. All rights reserved.
//

#import "ECUnitTests.h"

@interface ComparisonTests : ECTestCase

@end

@implementation ComparisonTests

- (void)testStringsEqual
{
	__block BOOL called = NO;
	BOOL b = [@"abc" matches:@"abc" block:^(id item1, id item2) {
		called = YES;
	}];
	
	ECTestAssertTrue(b);
	ECTestAssertFalse(called);
}

- (void)testStringsDifferent
{
	__block id item1called = nil;
	__block id item2called = nil;
	
	BOOL b = [@"abc" matches:@"def" block:^(id item1, id item2) {
		item1called = item1;
		item2called = item2;
	}];
	
	ECTestAssertFalse(b);
	ECTestAssertIsEqual(item1called, @"abc");
	ECTestAssertIsEqual(item2called, @"def");
}

@end
