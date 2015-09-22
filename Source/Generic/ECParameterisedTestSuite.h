// --------------------------------------------------------------------------
//  Copyright 2015 Sam Deane, Elegant Chaos. All rights reserved.
//  This source code is distributed under the terms of Elegant Chaos's
//  liberal license: http://www.elegantchaos.com/license/liberal
// --------------------------------------------------------------------------

#import "ECTestCase.h"

/**
 Custom XCTestSuite class which knows how to remove parameterised
 tests (which turns out to be essential for Xcode).
 */

@interface ECParameterisedTestSuite : XCTestSuite
@end
