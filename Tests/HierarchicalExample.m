// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import <ECUnitTests/ECUnitTests.h>

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

- (void)parameterisedTestExample
{
    NSLog(@"Example test run with data item: %@", self.parameterisedTestDataItem);
}

@end
