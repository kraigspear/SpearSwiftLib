//
//  TimerTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/20/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
import SpearSwiftLib

class TimerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    var firedExpitation:XCTestExpectation?
    func testTimerFired() {
        
        firedExpitation = expectationWithDescription("fired")
        
        let timer = Timer(interval: 1)
        
        timer.fired.addHandler(self, handler: TimerTest.timerFired)
        
        timer.start()
        
        XCTAssertTrue(timer.isRunning)
        
        waitForExpectationsWithTimeout(5) { (error) -> Void in
            XCTAssertNil(error, "Error")
        }
        
        timer.stop()
        
        XCTAssertFalse(timer.isRunning)
        
    }
    
    var timerFiredCount:Int = 0
    
    func timerFired() {
        timerFiredCount++
        if timerFiredCount >= 3 {
            firedExpitation!.fulfill()
        }
    }
    
   
}
