// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"

extern NSString* const ParameterisedTestMethodPrefix;
extern NSString* const ParameterisedTestShortPrefix;
extern NSString* const ParameterisedTestSeparator;

/**
 Custom XCTestSuite class which knows how to remove parameterised
 tests (which turns out to be essential for Xcode).
 */

@interface ECParameterisedTestSuite : XCTestSuite
@property (assign, nonatomic) Class testClass;
@property (assign, nonatomic) SEL testSelector;

+ (instancetype)suiteForSelector:(SEL)selector class:(Class)class name:(NSString*)name data:(NSDictionary*)data;
@end
