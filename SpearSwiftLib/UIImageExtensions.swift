//
//  UIImageExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/29/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation


public extension UIImage {
	public func applyAlpha(_ alpha: CGFloat) -> UIImage {
		UIGraphicsBeginImageContext(size)
		
		guard let context = UIGraphicsGetCurrentContext() else {return self}
		let area = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		
		context.scaleBy(x: 1, y: -1)
		context.translateBy(x: 0, y: -area.size.height)
		
		context.setBlendMode(.multiply)
		context.setAlpha(alpha)
		
		context.draw(in: area, image: cgImage!)
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage!
	}
}