//
//  UIView+Blur.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/11/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import UIKit

/// Parameters to make a shadown on a view
/// - SeeAlso: `UIView.apply(shadow: Shadow)`
public struct Shadow {
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let borderColor: UIColor
    let shadowColor: UIColor
    let offset: CGSize
    let opacity: Float
    let shadowRadius: CGFloat

    public init(cornerRadius: CGFloat,
                borderWidth: CGFloat,
                borderColor: UIColor,
                shadowColor: UIColor,
                offset: CGSize,
                opacity: Float,
                shadowRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.shadowColor = shadowColor
        self.offset = offset
        self.opacity = opacity
        self.shadowRadius = shadowRadius
    }
}

public extension UIView {
    /**
      Apply a standard blur effect to this view.

      - parameter style: UIBlurEffectStyle style for the blur effect

     ```swift

     @IBOutlet private var titleView: UIView!
     titleView.applyBlur()

     ```

     */
    func applyBlur(style: UIBlurEffect.Style = .dark) {
        backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        insertSubview(blurView, at: 0)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1).isActive = true
        blurView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true

        layoutIfNeeded()
    }

    /**
     Apply a shadow using the paramters of `shadow`
     - parameter shadow: Paramters that make up the shadow
     */
    func applyShadow(_ shadow: Shadow) {
        // corner radius
        layer.cornerRadius = shadow.cornerRadius
        // Border
        layer.borderWidth = shadow.borderWidth
        layer.borderColor = shadow.borderColor.cgColor
        // shadow
        layer.shadowColor = shadow.shadowColor.cgColor
        layer.shadowOffset = shadow.offset
        layer.shadowOpacity = shadow.opacity
        layer.shadowRadius = shadow.shadowRadius
    }
}
