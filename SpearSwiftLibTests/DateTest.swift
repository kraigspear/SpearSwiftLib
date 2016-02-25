//
//  DateTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 12/29/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
@testable import SpearSwiftLib

class DateTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMDY() {
        let date = NSDate(timeIntervalSince1970: 1445077917)
        
        let mdy = date.toMonthDayYear()
        
        XCTAssertEqual(10, mdy.month)
        XCTAssertEqual(17, mdy.day)
        XCTAssertEqual(2015, mdy.year)
    }
    
    func testMDYHMS() {
        let date = NSDate(timeIntervalSince1970: 1445077917)
        
        let mdy = date.toMonthDayYearHourMinutesSeconds()
        
        XCTAssertEqual(10, mdy.month)
        XCTAssertEqual(17, mdy.day)
        XCTAssertEqual(2015, mdy.year)
        XCTAssertEqual(6, mdy.hour)
        XCTAssertEqual(31, mdy.minutes)
        XCTAssertEqual(57, mdy.seconds)
    }
    
    func testJulianDay() {
        let expected = Double(2457313.6)
        let date = NSDate(timeIntervalSince1970: 1445077917)
        let j = date.toJullianDayNumber()
        XCTAssertEqual(expected, j)
    }
	
	func testAddDays() {
		let oct172015 = NSDate(timeIntervalSince1970: 1445077917)
		let aDayLater = oct172015.addDays(1)
		let mdy = aDayLater.toMonthDayYear()
		XCTAssertEqual(18, mdy.day)
	}
	
	func testIsSameDay() {
		let oct172015 = NSDate(timeIntervalSince1970: 1445077917)
		let laterThatSameDay = NSDate(timeIntervalSince1970: 1445114196)
		XCTAssertTrue(oct172015.isSameDay(laterThatSameDay))
	}

}
