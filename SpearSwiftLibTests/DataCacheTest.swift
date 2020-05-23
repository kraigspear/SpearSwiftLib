//
//  DataCacheTest.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 2/19/20.
//  Copyright © 2020 spearware. All rights reserved.
//

@testable import SpearSwiftLib
import XCTest

final class DataCacheTest: XCTestCase {
    private var fileManager: FileManageableMock!
    private var sut: DataCache!

    override func setUp() {
        fileManager = FileManageableMock()
        sut = DataCache(fileManager: fileManager)
    }

    func testItemsAreRemovedOlderThan() {
        let file1 = "user/cache/file1.date"
        let file2 = "user/cache/file2.date"
        let file3 = "user/cache/file3.date"

        fileManager.numberOfMinutesSinceCreatedValue = 100
        fileManager.cachFilesValue = [file1, file2, file3]

        let expect = expectation(description: "completed")

        sut.removeItemsOlderThan(minutes: 5) {
            expect.fulfill()
        }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 1))

        XCTAssertEqual(3, fileManager.removeItemCalled)
    }

    func testItemsAreNotRemovedYoungerThan() {
        let file1 = "user/cache/file1.date"
        let file2 = "user/cache/file2.date"
        let file3 = "user/cache/file3.date"

        fileManager.numberOfMinutesSinceCreatedValue = 1
        fileManager.cachFilesValue = [file1, file2, file3]

        let expect = expectation(description: "completed")

        sut.removeItemsOlderThan(minutes: 5) {
            expect.fulfill()
        }

        XCTAssertEqual(.completed, XCTWaiter().wait(for: [expect], timeout: 1))

        XCTAssertEqual(0, fileManager.removeItemCalled)
    }
}
