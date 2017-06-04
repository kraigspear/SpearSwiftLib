//
//  NetworkDownloadableMock.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/3/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation


final class  NetworkDownloadableMock: NetworkDownloadable {
	var downloadResult: NetworkResult<Data>!
	var downloadCalled = 0
	func download(from: RequestBuildable, completed: @escaping (NetworkResult<Data>) -> Void) {
		downloadCalled += 1
		completed(downloadResult)
	}
}
