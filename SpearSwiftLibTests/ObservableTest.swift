//
//  ObservableTest.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 3/17/18.
//  Copyright © 2018 spearware. All rights reserved.
//

@testable import SpearSwiftLib
import XCTest

final class ObservableTest: XCTestCase {
    final class HasObservable {
        let myObserver = Observable(value: "someString")
    }

    final class UsesObserable {
        let hasObservable = HasObservable()

        var onCalled: (() -> Void)?

        init() {
            wireUp()
        }

        private func wireUp() {
            hasObservable.myObserver.subscribe { [unowned self] in
                print("Observed \($0)")
                self.onCalled?()
            }
        }
    }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_when_class_is_out_scope_then_observable_is_unsubscribed() {
        var usesObservable: UsesObserable? = UsesObserable()

        let expect = expectation(description: "called")

        usesObservable!.onCalled = {
            expect.fulfill()
        }

        usesObservable!.hasObservable.myObserver.value = "other string"

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 1))

        usesObservable = nil
    }
}
