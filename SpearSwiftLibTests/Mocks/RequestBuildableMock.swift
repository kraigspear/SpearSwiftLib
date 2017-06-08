//
//  RequestBuildableMock.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/4/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation
@testable import SpearSwiftLib


final class RequestBuildableMock: RequestBuildable {
	
	var requestForRequest: URLRequest!
	
	var request: URLRequest {
		return requestForRequest
	}
}
