//
//  OperationTest.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/27/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import XCTest
import Foundation
import SpearSwiftLib

class Operation : BaseOperation
{
    override func main()
    {
        for i in 0..<1
        {
            print(i)
        }
        self.done()
    }
    
}

class OperationTest: XCTestCase {
    
    var que:OperationQueue!
    
    override func setUp() {
        super.setUp()
        que = OperationQueue()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCompletedCalledOnce()
    {
        let readyExpectation = expectation(description: "ready")
        let operation = Operation()
        
        var completedCount = 0
        
        operation.completionBlock = {
            completedCount += 1
            print("completionBlock called")
            readyExpectation.fulfill()
        }
        
        self.que.addOperation(operation)
        
        waitForExpectations(timeout: 10) { (error) -> Void in
            XCTAssertNil(error, "Error")
        }
        
        XCTAssertEqual(1, completedCount)
    }
    
       
}
