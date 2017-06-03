//
// Created by Kraig Spear on 6/1/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation


/**
Fetch JSON from a source, such as a file or network operation
*/
public protocol JSONFetchable {

	///  fetchJSON: Fetches JSON calling success with the JSON on success, or failure if there was an error getting the JSON
	///
	///  - parameter completed: Called when completed with the result.
	func fetchJSON(completed: @escaping (NetworkResult<JsonKeyValue>) -> Void)
}

