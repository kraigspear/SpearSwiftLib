//
// Created by Kraig Spear on 6/3/17.
// Copyright (c) 2017 spearware. All rights reserved.
//

import Foundation

///Type that downloads JSON from the network.
public protocol JSONDownloadable {

	//MARK: - Methods
	/**
	Download JSON data from a network location.

	- parameter from: The `RequestBuildable` which contains the URL parameters ext.. about what to download
	- parameter completed: Called with the result of the network call

	- SeeAlso: `RequestBuildable`
	- note: Code Example from WeatherExtractor

	```swift

	let jsonDownloader = JsonDownloader()

	//JSONDownloadable knows what to download from the `RequestBuildable` where the URL parameters body ext..
	//is set.
	fileprivate extension WeatherLocationType {
		func createRequest() -> RequestBuildable {
			return LocationRequest(locationId: locationId)
		}
	}

	func fetch(forLocation: WeatherLocationType, success: @escaping (WeatherLocationType) -> Void) {
		self.location = forLocation

		jsonDownloadable.download(from: forLocation.createRequest()) {[weak self] (result) in
			guard let this = self else {return}
			switch result {
			case .success(result: let json):
				let fetchedLocation = this.extract(json: json, for: forLocation)
				DispatchQueue.main.async {
					success(fetchedLocation)
				}
			default:
				break
			}
		}
	}
	```
	*/
	func download(from: RequestBuildable, completed: @escaping (NetworkResult<JsonKeyValue>) -> Void)
}