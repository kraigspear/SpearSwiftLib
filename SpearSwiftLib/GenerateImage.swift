//
//  GenerateImage.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/2/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import UIKit

public typealias GenerateImage = (rect: CGRect) -> UIImage?

public protocol ImageRequestable {
	func imageForSize(size: CGSize) -> (image: UIImage?, refreshed: Bool)
}

public class RequestImage: ImageRequestable {
	
	private var size: CGSize = CGSizeZero
	private var image: UIImage?
	private let generateImage: GenerateImage
	
	public init(generateImage: GenerateImage) {
		self.generateImage = generateImage
	}
	
	public func imageForSize(size: CGSize) -> (image: UIImage?, refreshed: Bool) {
		
		if let image = self.image {
			if CGSizeEqualToSize(size, self.size) {
				print("same size not refreshing")
				return (image: image, refreshed: false)
			}
		}
		
		let rect = CGRectMake(0, 0, size.width, size.height)
		self.size = size
		
		let generated = generateImage(rect: rect)
		self.image = generated
		
		return (image: generated, refreshed: true)
	}
	
}
