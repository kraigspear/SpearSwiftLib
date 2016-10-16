//
//  GenerateImage.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/2/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import UIKit

public typealias GenerateImage = (_ rect: CGRect) -> UIImage?

public protocol ImageRequestable {
	func imageForSize(_ size: CGSize) -> (image: UIImage?, refreshed: Bool)
}

public class RequestImage: ImageRequestable {
	
	private var size: CGSize = CGSize.zero
	private var image: UIImage?
	private let generateImage: GenerateImage
	
	public init(generateImage: @escaping GenerateImage) {
		self.generateImage = generateImage
	}
	
	public func imageForSize(_ size: CGSize) -> (image: UIImage?, refreshed: Bool) {
		
		if let image = self.image {
			if size.equalTo(self.size) {
				print("same size not refreshing")
				return (image: image, refreshed: false)
			}
		}
		
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		self.size = size
		
		let generated = generateImage(rect)
		self.image = generated
		
		return (image: generated, refreshed: true)
	}
	
}
