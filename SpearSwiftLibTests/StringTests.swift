//
//  StringTests.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/17/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
import SpearSwiftLib

class StringTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testContains()
    {
      let myStr = "here is some text ya all"
      XCTAssertTrue(myStr.contains("ya"))
      XCTAssertFalse(myStr.contains("kraig"))
    }
  
    func testAny()
    {
      let myStr = "here is some text ya all"
      XCTAssertTrue(myStr.any("bla", "crap", "text"))
      XCTAssertFalse(myStr.any("abc", "def", "hijk"))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
