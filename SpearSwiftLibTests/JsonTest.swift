//
//  JsonTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/14/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
import SpearSwiftLib

class JsonTest: XCTestCase {

    var jsonData: JsonKeyValue!
    var json:Json!
    let observation = "observation"
    
    override func setUp() {
        super.setUp()
        loadJSON()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    private func loadJSON() {
        let bundle = NSBundle(forClass: JsonTest.self)
        let path = bundle.pathForResource("Aeris", ofType: "json")!
        let data = NSData(contentsOfFile: path)
        self.jsonData = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! JsonKeyValue
        
        let rootPath = PathElement(name: "response")
        
        rootPath.withChild("responses", childAtIndex: 0)
            .withChild("response")
            .withChild("ob")
        
        print(rootPath)
        
        let observationPath = JsonPath(name: observation, rootPath: rootPath)
        
        self.json = try! Json(jsonData: self.jsonData!, paths: observationPath)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testIntValue() {
        let tempF = try! json.intValue(observation, key: "tempF")
        XCTAssertEqual(37, tempF)
    }
    
    func testFloatValue() {
        let pressreIn = try! json.floatValue(observation, key: "pressureIN")
        XCTAssertEqual(30.06, pressreIn)
    }
    
    func testDateValue() {
        let date = try! json.dateValue(observation, key: "timestamp")
        let expectedDate = NSDate(timeIntervalSince1970: 1449564780)
        XCTAssertEqual(expectedDate, date)
    }
    
    func testFloatPathNotFound() {
        do {
          _ = try json.floatValue("bla", key: "pressureIN")
          XCTFail("Exception not raised")
        } catch JsonError.KeyNotFound( _) {
        } catch {
          XCTFail("Unexpected exception")
        }
    }
    
    func testInvalidFloat() {
        let weatherKey = "weather"
        do {
            _ = try json.floatValue(observation, key: weatherKey)
            XCTFail("Exception not raised")
        } catch JsonError.ConversionError(let key, let value) {
            XCTAssertEqual(weatherKey, key)
            XCTAssertEqual("Cloudy with Mist and Fog", value as? String)
        } catch {
            XCTFail("Unexpected exception")
        }
    }


    
    

    
}
