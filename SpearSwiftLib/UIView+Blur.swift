//
//  UIView+Blur.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/11/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import UIKit


public extension UIView {

	/**
	Apply a standard blur effect to this view.
	
	- parameter style: UIBlurEffectStyle style for the blur effect
	*/
	public func applyBlur(style: UIBlurEffectStyle = .dark) {
		
		backgroundColor = UIColor.clear
		let blurEffect = UIBlurEffect(style: style)
		let blurView = UIVisualEffectView(effect: blurEffect)
		insertSubview(blurView, at: 0)
		
		blurView.translatesAutoresizingMaskIntoConstraints = false
		blurView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
		blurView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
		
		layoutIfNeeded()
	}
}
