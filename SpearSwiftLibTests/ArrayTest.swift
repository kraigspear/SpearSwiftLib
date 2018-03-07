//
//  ArrayTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/17/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import SpearSwiftLib
import XCTest

class ArrayTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAnyFound() {
        let numbers = [1, 5, 3, 2, 8, 9]

        let doesExist = numbers.any { (i) -> Bool in
            return i == 3
        }

        XCTAssertTrue(doesExist)
    }

    func testAnyNotFound() {
        let numbers = [1, 5, 3, 2, 8, 9]

        let doesExist = numbers.any { (i) -> Bool in
            return i == 11
        }

        XCTAssertFalse(doesExist)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
