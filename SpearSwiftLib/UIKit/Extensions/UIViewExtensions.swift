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
    public func applyBlur(style: UIBlurEffect.Style = .dark) {
        backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurView, at: 0)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        blurView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        layoutIfNeeded()
    }
	
	public func applyShadow() {
		let shadowPath = UIBezierPath(rect: bounds)
		layer.masksToBounds = false
		layer.shadowColor = UIColor.white.cgColor
		layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
		layer.shadowOpacity = 0.5
		layer.shadowPath = shadowPath.cgPath
	}
}
