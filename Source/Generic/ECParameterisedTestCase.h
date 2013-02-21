// --------------------------------------------------------------------------
//  Copyright 2013 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"

extern NSString *const DataURLKey;
extern NSString *const IncludesKey;
extern NSString *const SettingsKey;
extern NSString *const TestItemsKey;
extern NSString *const SuiteItemsKey;

// --------------------------------------------------------------------------
///This subclass has some extra support to help with
/// constructing parameterised test suites at runtime.
///
/// This is handy when you've got a test or tests that you want
/// to run multiple times with different parameters.
// --------------------------------------------------------------------------

@interface ECParameterisedTestCase : ECTestCase
{
@private
	id parameterisedTestDataItem;
	NSString* parameterisedTestName;
}

@property (strong, nonatomic) id parameterisedTestDataItem;
@property (strong, nonatomic) NSString* parameterisedTestName;

+ (id)testCaseWithSelector:(SEL)selector param:(id)param;
+ (id)testCaseWithSelector:(SEL)selector param:(id)param name:(NSString*)name;

+ (NSDictionary*)parameterisedTestData;
+ (NSDictionary*)parameterisedTestDataFromFolder:(NSURL*)folder settings:(NSDictionary*)settings;
+ (NSDictionary*)mergeTestData:(NSDictionary*)data1 withTestData:(NSDictionary*)data2;

@end
