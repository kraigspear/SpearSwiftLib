//
//  StringBuilderTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/27/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
import SpearSwiftLib

class StringBuilderTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddingStrings() {
        
        let firstStr = "str1"
        let secondStr = "str2"
        let deliminter = "\t"
        
        let sb = StringBuilder(delimiter:deliminter)
        sb.append(firstStr).append(secondStr)
        
        XCTAssertEqual(2, sb.numberOfStrings)
        
        let builtString = sb.build()
        let lastChar = builtString[builtString.endIndex.advancedBy(-1)]
        XCTAssertFalse(lastChar == "\t")
        
        let parts = builtString.componentsSeparatedByString(deliminter)
        XCTAssertEqual(2, parts.count)
        XCTAssertEqual(firstStr, parts[0])
        XCTAssertEqual(secondStr, parts[1])
        
    }

}
