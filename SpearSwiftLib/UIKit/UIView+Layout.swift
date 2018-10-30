//
//  UIView+Layout.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 9/30/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

public extension UIView {
    public func pin(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false

        if superview == nil {
            view.addSubview(self)
        }

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        view.layoutIfNeeded()
    }

    public func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
