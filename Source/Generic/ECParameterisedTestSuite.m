// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECParameterisedTestSuite.h"
#import "ECParameterisedTestCase.h"

NSString* const ParameterisedTestMethodPrefix = @"parameterisedTest";
NSString* const ParameterisedTestShortPrefix = @"test";
NSString* const ParameterisedTestSeparator = @"__";


static NSMutableDictionary* dataIndex;

@interface XCTestSuite (ProbeExtensions)
- (void)removeTestsWithNames:(NSArray*)names; // this is private API, but what-the-hell, this code is test only right?
@end


@implementation ECParameterisedTestSuite

+(void)initialize {
	if (self == [ECParameterisedTestSuite class]) {
		dataIndex = [NSMutableDictionary new];
	}
}


// --------------------------------------------------------------------------
//! Make a test case with a given selector, parameter and a custom name.
// --------------------------------------------------------------------------

+ (ECParameterisedTestCase*)testCaseWithSelector:(SEL)selector class:(Class)class param:(id)param name:(NSString*)name
{
	NSString* originalSelector = NSStringFromSelector(selector);
	NSString* stub = [originalSelector substringFromIndex:[ParameterisedTestMethodPrefix length]];
	NSString* newSelectorName = [NSString stringWithFormat:@"%@%@%@%@", ParameterisedTestShortPrefix, stub, ParameterisedTestSeparator, name];
	SEL newSelector = NSSelectorFromString(newSelectorName);
	ECParameterisedTestCase* tc = [class testCaseWithSelector:newSelector];
	tc.parameterisedTestDataItem = param;
	tc.parameterisedTestName = name;
	tc.parameterisedBaseName = [NSString stringWithFormat:@"-[%@ %@]", [self class], originalSelector];

	return tc;
}

// --------------------------------------------------------------------------
//! Return a cleaned up version of the name, as a CamelCase string.
// --------------------------------------------------------------------------

+ (NSString*)cleanedName:(NSString*)name
{
	NSMutableCharacterSet* separators = [NSMutableCharacterSet whitespaceCharacterSet];
	[separators formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	NSString* result = name;
	NSArray* words = [result componentsSeparatedByCharactersInSet:separators];
	if ([words count] > 1)
	{
		NSMutableString* cleaned = [NSMutableString stringWithCapacity:[result length]];
		for (NSString* word in words)
		{
			if ([word length] > 0)
			{
				[cleaned appendString:[[word uppercaseString] substringToIndex:1]];
				[cleaned appendString:[word substringFromIndex:1]];
			}
		}
		result = cleaned;
	}

	return result;
}


// --------------------------------------------------------------------------
//! Build a test suite for a given selector and data set.
//! The data set can contain individual data items, and also
//! sub-suites of items.
// --------------------------------------------------------------------------

+ (instancetype)suiteForSelector:(SEL)selector class:(Class)class name:(NSString*)name data:(NSDictionary*)data
{
	ECParameterisedTestSuite* result = [[ECParameterisedTestSuite alloc] initWithName:name];
	result.testClass = class;
	result.testSelector = selector;
	if (!data) {
		[result addTestsForData:data];
	}

	return result;
}

- (void)addTestsForData:(NSDictionary*)data {

	// add items to the suite as tests
	NSDictionary* items = data[TestItemsKey];
	for (NSString* testName in items)
	{
		NSString* cleanName = [[self class] cleanedName:testName];
		NSDictionary* testData = items[testName];
		[self addTest:[[self class] testCaseWithSelector:self.testSelector class:self.testClass param:testData name:cleanName]];
	}

	// add child suites to the test
	NSDictionary* suites = data[SuiteItemsKey];
	for (NSString* suiteName in suites)
	{
		NSDictionary* suiteData = suites[suiteName];
		ECParameterisedTestSuite* suite = [[self class] suiteForSelector:self.testSelector class:self.testClass name:suiteName data:suiteData];
		[self addTest:suite];
	}
}

- (NSDictionary*)data {
	NSString* key = [self.testClass className];
	NSDictionary* data = dataIndex[key];
	if (!data) {
		data = [self.testClass parameterisedTestData];
		dataIndex[key] = data;
		NSLog(@"initialised data for %@", key);
	}

	return data;
}

- (void)removeTestsWithNames:(NSArray*)names
{
	NSDictionary* data = [self data];
	[self addTestsForData:data];

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
