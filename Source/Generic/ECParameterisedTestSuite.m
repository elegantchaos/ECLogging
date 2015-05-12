// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECParameterisedTestSuite.h"
#import "ECParameterisedTestCase.h"

@interface XCTestSuite (ProbeExtensions)
- (void)removeTestsWithNames:(NSArray*)names; // this is private API, but what-the-hell, this code is test only right?
@end


@implementation ECParameterisedTestSuite

- (void)removeTestsWithNames:(NSArray*)names
{
	// the names we're asked to remove may not actually match the parameterised test names,
	// because we mess around with them slightly
	// as a result, we scan the tests and if we find any parameterised ones where the base
	// name is in the names array
	// we explicitly add the test name to the array as well
	NSMutableArray* modifiedNames = nil;
	for (ECParameterisedTestCase* test in self.tests)
	{
		if ([test isKindOfClass:[ECParameterisedTestCase class]])
		{
			if ([names containsObject:test.parameterisedBaseName])
			{
				if (!modifiedNames)
					modifiedNames = [names mutableCopy];
				[modifiedNames addObject:test.name];
				NSLog(@"removed %@ %@ from %@", test.name, test, self);
			}
		}
	}

	[super removeTestsWithNames:modifiedNames ? modifiedNames : names];
}

@end
