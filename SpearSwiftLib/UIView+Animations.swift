//
//  UIView+Animations.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/12/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import UIKit

public extension UIView {
	/**
	Spin a view around for a certain amount of time.
	This animation is continuous.
	- paramter withDuration: The time to spin around 1 time
	*/
	public func animateSpin(withDuration: TimeInterval) {
		
		let animateKey = "rotation"
		let animate = CABasicAnimation(keyPath: "transform.rotation")
		animate.duration = withDuration
		animate.repeatCount = Float.infinity
		animate.fromValue = 0.0
		animate.toValue = Float(.pi * 2.0)
		layer.add(animate, forKey: animateKey)
	}
	
	/**
	Pan an image from the left to right, or the right to left depending on its start position
	
	- paramter withDuration: The time to move from the start to stop position
	*/
	public func animatePan(withDuration: TimeInterval) {
		
		guard let superview = self.superview else {
			return
		}
		
		let animateKey = "pan"
		let animate = CABasicAnimation(keyPath: "position.x")
		animate.duration = withDuration
		
		//Either we are stopping at left or the right depending on which side the item is 
		//orginally placed.
		let stopAt = frame.origin.x > superview.frame.width / 2
			? frame.width / 2
			: superview.frame.width - (frame.width / 2)
		
		animate.toValue = stopAt
		animate.repeatCount = Float.infinity
		animate.autoreverses = true
		layer.add(animate, forKey: animateKey)
	}
}
