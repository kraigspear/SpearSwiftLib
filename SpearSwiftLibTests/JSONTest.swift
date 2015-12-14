//
//  JSONTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/12/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
import SpearSwiftLib


class JSONTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIntConversionValid() {
        
        let myDict = ["key1" : "1"]
        
        do {
            let testInt:Int = try myDict.toInt("key1")
            XCTAssertEqual(1, testInt)
        } catch  {
            XCTFail("Exception not expected")
        }
        
    }
    
    func testFloatConversionValid() {
        
        let myDict = ["key1" : "1.5"]
        
        do {
            let testInt:Float = try myDict.toFloat("key1")
            XCTAssertEqual(1.5, testInt)
        } catch  {
            XCTFail("Exception not expected")
        }
        
    }
    
    func testIntConversionNotValidFromString() {
        
        let myDict = ["key1" : "abcd"]
        
        do {
            try myDict.toInt("key1") as Int
            XCTFail("Exception not raised")
        }
        catch DictionaryConvertError.ConversionError {
        }
        catch  {
            XCTFail("Exception not expected")
        }
        
    }
    
    func testFloatConversionNotValidFromString() {
        
        let myDict = ["key1" : "abcd"]
        
        do {
            try myDict.toFloat("key1") as Float
            XCTFail("Exception not raised")
        }
        catch DictionaryConvertError.ConversionError {
        }
        catch  {
            XCTFail("Exception not expected")
        }
        
    }
    
    func testIntConversionFromNSNumber() {
        
        let testValue:Int = 456
        
        let nsNumber = NSNumber(integer: testValue)
        
        let myDict = ["key1" : nsNumber]
        
        do {
            let expectedInt:Int = try myDict.toInt("key1")
            XCTAssertEqual(testValue, expectedInt)
        } catch {
           XCTFail("Exception not expected")
        }
    }
    
    func testFloatConversionFromNSNumber() {
        
        let testValue:Float = 456.11
        
        let nsNumber = NSNumber(float: testValue)
        
        let myDict = ["key1" : nsNumber]
        
        do {
            let expectedInt:Float = try myDict.toFloat("key1")
            XCTAssertEqual(testValue, expectedInt)
        } catch {
            XCTFail("Exception not expected")
        }
    }

}
