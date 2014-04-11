// --------------------------------------------------------------------------
//  Copyright 2014 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's 
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"

extern NSString *const DataURLKey;
extern NSString *const IncludesKey;
extern NSString *const SettingsKey;
extern NSString *const TestItemsKey;
extern NSString *const SuiteItemsKey;

/**
 
 This class allows you to define unit tests that have a series of test data items applied in turn.

 This is handy when you've got a test or tests that you want to run multiple times with different parameters.

 The normal tests work great if you want to run each test once, but what if you have a set of test data and you want to run each test multiple times, applying each item of test data to it in turn?

 The naive approach is to define lots of test methods that just call onto another helper method supplying a different argument each time. Something like this:

 - (void)testXWithDataA { [self helperX:@"A"]; }
 - (void)testXWithDataB { [self helperX:@"B"]; }

 That gets tired quickly, and it doesn't allow for a dynamic amount of test data determined at runtime.

 What you really want in this case is to add the following abilities to XCTest:

 - the ability to define parameterised test methods using a similar naming convention to the normal ones
 - the ability to define a class method which returns a dictionary of test data
 - have XCTest make a sub-suite for each parameterised method we found
 - have the sub-suite contain a test for each data item
 - iterate the suites and tests as usual, applying the relevant data item to each test in turn

 This is what ECParameterisedTest gives you.

 # How To Use It

 - inherit from ECParameterisedTest instead of XCTestCase
 - define test methods which are named parameterisedTestXYZ instead of testXYZ (they still take no parameters)
 - either: define a class method called parameterizedTestData which returns a dictionary containing data
 - or: create a plist with the name of your test class, which will contain the data
 - or: create a directory with the extension .testsuite, containing your test data (see below)

 At runtime the data method will be called to obtain the data. The names of each key should be single words which describe the data. The values can be anything you like - whatever the test methods are expecting.

 To simplify the amount of modification to XCTest, the test methods still take no parameters. Instead, to obtain the test data, each test method uses the **parameterisedTestDataItem** property.


 # How It Works

 To make its test suites, XCTestKit calls a class method called defaultTestSuite on each XCTestCase subclass that it finds.

 The default version of this makes a suite based on finding methods called testXYZ, but it's easy enough to do something else.

 Our version calls **parameterisedTestData**, which is a class method which returns a dictionary containing the data
 For each parameterised test method we find, we make a suite.
 For each item in the dictionary, we add a test to this suite.
 Finally we make a master suite, add the other suites to it, and return that.

 To make things simple, we use the existing XCTestKit mechanism to invoke the test methods. Since XCTestKit expects test methods not to have any parameters, we need another way of passing the test data to each method. Each test invocation creates an instance of a our class, and we do this creation at the point we build the test suite, so the simple answer is just to add a property to the test class. We can set this property value when we make the test instance, and the test method can extract the data from the instance when it runs.

 # Obtaining Test Data

 To obtain the test data, we've added a method **parameterisedTestData** that we expect the test class to implement.

 This method returns a dictionary rather than an array, so that we can use the keys as test names, and the values as the actual data. Having names for the data is useful because of the way XCTestKit reports the results.

 Typically it reports each test as [SuiteName testName], taking these names from the class and method. Since we're going to use the name of the test method for each of our suites, we really need another name to use for each test. This is where the dictionary key comes in.

 Where the test data comes from is of course up to you and the kind of tests you are trying to perform.

 There is are a couple of simple scenarios though, which are that we want to load it from a plist that we provide along with the test class, or that we want to load it from a directory of files.

 Since we need a default implementation of the method anyway, we cater for these simple case automatically. We look for a plist with the same name as the test class, or a folder with the name of the test class and the file extension "testsuite".

 # Test Data From A Plist

 The plist can have one of two formats.

 In the simple case, it's just a dictionary, where each entry is a test data item.

 In the slightly more complex case, it contains two keys: ECTestItems and ECTestSuites. The items key contains the data items for this suite. The suites item contains data for any sub-suites (using the same data layout recursively for these sub-suites).

 Using this complex case it's possible to create hierarchies of test suites, to group the results more clearly.

 # Test Data From A Directory

 Instead of a plist, you can store your test data in a recursive directory structure.

 If you provide a directory with the name of the test class, and the extension "testsuite", it will get parsed into a dictionary of test data in the following way:

 Any .testsuite folders inside it will be added as sub-suites

 Any other folders in it will be treated as test data items

 The contents of any files inside each test data item folder will be added to the dictionary for that test as text, if possible. If not, the URL will be added instead.

 A file called testdata.plist in any item will be read as a dictionary, and the keys in it added to the dictionary for the item.

 A file called testdata.plist in any suite folder will be read and added to the data properties for that suite. This can be used to define some items on disk, and others from plists.

 */

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
