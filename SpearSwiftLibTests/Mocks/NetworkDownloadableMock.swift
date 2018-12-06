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
	
	func download(from: RequestBuildable,
				  pinningCertTo: Data?,
				  completed: @escaping (NetworkResult<Data>) -> Void) {
		
	}
	
    var downloadResult: NetworkResult<Data>!
    var downloadCalled = 0
    func download(from _: RequestBuildable, completed: @escaping (NetworkResult<Data>) -> Void) {
        downloadCalled += 1
        completed(downloadResult)
    }
}
