//
//  SpearSwiftLibTests.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 2/26/15.
//  Copyright (c) 2015 spearware. All rights reserved.
//

import UIKit
import XCTest
import SpearSwiftLib

class SpearSwiftLibTests: XCTestCase
{
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testNetworkOperation()
    {
      let networkOperation = NetworkOperation(urlStr: "http://forecast.weather.gov/MapClick.php")
      
      networkOperation.addParam("lat", value: "42.9612")
      networkOperation.addParam("lon", value: "-85.6557")
      networkOperation.addParam("FcstType", value: "json")
      
      let readyExpectation = expectationWithDescription("ready")

      networkOperation.fetchJSON({ (dictionary) -> Void in
        
        XCTAssertNotNil(dictionary["currentobservation"])
        readyExpectation.fulfill()
        })
        { (error) -> Void in
          XCTAssertTrue(false, "Error calling fetchJSON")
          readyExpectation.fulfill()
        }
      
      waitForExpectationsWithTimeout(10) { (error) -> Void in
        XCTAssertNil(error, "Error")
      }
      
      
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
