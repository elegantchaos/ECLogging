// --------------------------------------------------------------------------
//! @author Sam Deane
//
//  Copyright 2012 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <ECUnitTests/ECUnitTests.h>

@interface BasicTests : ECTestCase
{
}

@end

@implementation BasicTests

#pragma mark - Tests

- (void)testTest
{
	ECTestAssertFalse(YES);
}

@end