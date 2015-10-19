//
//  EventTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/19/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
import SpearSwiftLib

class EventTest: XCTestCase {

    
    func testEventRaised() {
        
        class ClassWithEvent {
            let myEvent = Event<(String, Int)>()
            
            func somethingHappened(someString:String, someInt:Int) {
                myEvent.raise((someString, someInt))
            }
        }
        
        class ClassReceivingEvent {
            
            var receivedStr:String?
            var receivedInt:Int?
            
            var withEvent:ClassWithEvent? {
                didSet {
                   withEvent?.myEvent.addHandler(self, handler: ClassReceivingEvent.receiveEvent)
                }
            }
            
            func receiveEvent(someStr:String, someInt:Int) {
                self.receivedStr = someStr
                self.receivedInt = someInt
            }
        }
        
        let classWithEvent = ClassWithEvent()
        let classReveivingEvent = ClassReceivingEvent()
        classReveivingEvent.withEvent = classWithEvent
        
        let someStr = "Kraig"
        let someInt = 48
        classWithEvent.somethingHappened(someStr, someInt: someInt)
        
        XCTAssertNotNil(classReveivingEvent.receivedStr)
        XCTAssertNotNil(classReveivingEvent.receivedInt)
        
        XCTAssertEqual(someStr, classReveivingEvent.receivedStr!)
        XCTAssertEqual(someInt, classReveivingEvent.receivedInt!)
        
        
        
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
