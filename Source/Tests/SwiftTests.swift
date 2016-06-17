//
//  SwiftTests.swift
//  ECLogging
//
//  Created by Sam Deane on 17/06/2016.
//  Copyright © 2016 Elegant Chaos. All rights reserved.
//

import XCTest
import ECUnitTests
import ECLogging

class SwiftTests: ECTestCase {

	func testStringBySplittingMixedCaps() {
		XCTAssertEqual("mixedCapTest".stringBySplittingMixedCaps(), "mixed Cap Test")
		XCTAssertEqual("alllowercaseoneword".stringBySplittingMixedCaps(), "alllowercaseoneword")
		XCTAssertEqual("".stringBySplittingMixedCaps(), "")
		XCTAssertEqual("all lower case multiple words".stringBySplittingMixedCaps(), "all lower case multiple words")
	}

}
