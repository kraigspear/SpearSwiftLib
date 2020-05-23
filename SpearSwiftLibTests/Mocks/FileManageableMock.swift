//
//  FileManageableMock.swift
//  SpearSwiftLibTests
//
//  Created by Kraig Spear on 2/19/20.
//  Copyright © 2020 spearware. All rights reserved.
//

import Foundation
@testable import SpearSwiftLib

final class FileManageableMock: FileManageable {
    var cachFilesValue: [String] = []
    func cacheFiles() -> [String] {
        cachFilesValue
    }

    var numberOfMinutesSinceCreatedValue = 0
    func numberOfMinutesSinceCreated(_: String) -> Int {
        numberOfMinutesSinceCreatedValue
    }

    func removeItem(atPath _: String) throws {
        removeItemCalled += 1

        if let removeItemError = self.removeItemError {
            throw removeItemError
        }
    }

    var removeItemError: Error?
    private(set) var removeItemCalled = 0
    func removeItem(at _: URL) throws {
        removeItemCalled += 1

        if let removeItemError = self.removeItemError {
            throw removeItemError
        }
    }

    var cachePathValue: String!
    var cachePath: String {
        cachePathValue
    }

    var cachePathFileValue: String!
    func cachePathFile(_: String) -> String {
        cachePathValue
    }

    var fileDateTimeValue: Date?
    func fileDateTime(_: String) -> Date? {
        fileDateTimeValue
    }

    func numberOfMinutesSinceCreated(_: URL) -> Int {
        numberOfMinutesSinceCreatedValue
    }

    var urlsReturn: [URL]! // If not set we want to crash to make it odvious that this needs to be done.
    func urls(for _: FileManager.SearchPathDirectory, in _: FileManager.SearchPathDomainMask) -> [URL] {
        urlsReturn
    }
}
