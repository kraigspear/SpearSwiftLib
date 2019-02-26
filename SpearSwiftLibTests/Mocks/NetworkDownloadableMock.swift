//
//  NetworkDownloadableMock.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/3/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation
@testable import SpearSwiftLib

final class NetworkDownloadableMock: NetworkDownloadable {
	private(set) var cancellCalled = 0
	func cancel() {
		cancellCalled += 1
	}

	var downloadCalled = 0
	var downloadResult: NetworkResult<Data>!
	func download(from: RequestBuildable,
	              pinningCertTo: Data?,
	              completed: @escaping (NetworkResult<Data>) -> Void) {
		downloadCalled += 1
		completed(downloadResult)
	}
}
