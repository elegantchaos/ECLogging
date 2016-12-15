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
import Foundation

class SwiftTests: ECTestCase {

	func testStringBySplittingMixedCaps() {
		XCTAssertEqual("mixedCapTest".splittingMixedCaps(), "mixed Cap Test")
		XCTAssertEqual("alllowercaseoneword".splittingMixedCaps(), "alllowercaseoneword")
		XCTAssertEqual("".splittingMixedCaps(), "")
		XCTAssertEqual("all lower case multiple words".splittingMixedCaps(), "all lower case multiple words")
	}

}
