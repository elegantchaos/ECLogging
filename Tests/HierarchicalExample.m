// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

@interface HierarchicalExample : ECParameterisedTestCase

@end

@implementation HierarchicalExample

- (void)setUp
{
	[super setUp];

	// Set-up code here.
}

- (void)tearDown
{
	// Tear-down code here.

	[super tearDown];
}

- (void)parameterisedTestHierarchicalExample
{
	NSLog(@"Example test run with data item: %@", self.parameterisedTestDataItem);
}

@end
