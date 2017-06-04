//
// Created by Kraig Spear on 6/3/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation


/**
Build a URLRequest.

Logic needed to create a `URLRequest`

This type can be injected into other types to handle the logic of generating the `URLRequest`

- Remark: Example can be found in `JSONNetworkFetcher`
- SeeAlso: `JSONNetworkFetcher`
*/
public protocol RequestBuildable {
	///The URLRequest generated for this RequestBuildable
	var request: URLRequest { get }
}