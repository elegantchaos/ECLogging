//  Created by Sam Deane on 17/06/2016.
//  Copyright © 2016 Elegant Chaos. All rights reserved.
//

import XCTest
import ECLogging
import ECUnitTests
import Foundation

class SwiftStringTests: ECTestCase {

	func testStringBySplittingMixedCaps() {
		XCTAssertEqual(("mixedCapTest" as NSString).splittingMixedCaps(), "mixed Cap Test")
		XCTAssertEqual(("alllowercaseoneword" as NSString).splittingMixedCaps(), "alllowercaseoneword")
		XCTAssertEqual(("" as NSString).splittingMixedCaps(), "")
		XCTAssertEqual(("all lower case multiple words" as NSString).splittingMixedCaps(), "all lower case multiple words")
	}

}
