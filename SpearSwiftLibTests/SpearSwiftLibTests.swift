//
//  SpearSwiftLibTests.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 2/26/15.
//  Copyright (c) 2015 spearware. All rights reserved.
//

import UIKit
import XCTest
@testable import SpearSwiftLib

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
		
      networkOperation.parameters.addParam("lat", value: "42.9612")
      networkOperation.parameters.addParam("lon", value: "-85.6557")
      networkOperation.parameters.addParam("FcstType", value: "json")
      
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
    
    func testAddDay()
    {
        let date = NSDate(timeIntervalSince1970: 1444441866) //Oct 9, 2015
        let dayPlus1 = date.addDays(1)
        let day = NSCalendar.currentCalendar().component(NSCalendarUnit.Day, fromDate: dayPlus1)
        XCTAssertEqual(10, day)
    }
    
    func testIsSameDay()
    {
        let date1 = NSDate()
        let date2 = NSDate()
        
        XCTAssertTrue(date1.isSameDay(date2))
        
        let date3 = date1.addDays(5)
        
        XCTAssertFalse(date1.isSameDay(date3))
    }
    
    func testSubtractDates()
    {
        let date1 = NSDate()
        let date2 = date1.addDays(2)
        
        let diff = date1.subtractDate(date2)
        
        XCTAssertEqual(2, diff.day)
        
    }
    
    func testSubtractDateOperator()
    {
        let date1 = NSDate()
        let date2 = date1.addDays(4)
        
        let diff = date1 - date2
        
        XCTAssertEqual(4, diff.day)
    }
    
    func testDateComponets() {
        let date = NSDate(timeIntervalSince1970: 1444441866) //Oct 9, 2015
        let mdy = date.toMonthDayYear()
        XCTAssertEqual(10, mdy.month)
        XCTAssertEqual(9, mdy.day)
        XCTAssertEqual(2015, mdy.year)
    }
    
   
    func testDegreesToRadians() {
        let degrees = 90.0
        let radians = degrees.toRadians()
        XCTAssertTrue( (1.5707963267949 - radians) < 0.00001 )
        let convertedDegrees = radians.toDegrees()
        XCTAssertEqual(degrees, convertedDegrees)
    }
    
}
