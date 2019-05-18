//
//  UIView+Layout.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 9/30/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

public extension UIView {
    func pin(to view: UIView) {
        add(to: view)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        view.layoutIfNeeded()
    }

    func dock(to view: UIView,
              top: CGFloat,
              trailing: CGFloat) {
        add(to: view)
        NSLayoutConstraint.activate([
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing),
            topAnchor.constraint(equalTo: view.topAnchor, constant: top),
        ])
        view.layoutIfNeeded()
    }

    func centerXY(on view: UIView) {
        add(to: view)
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        view.layoutIfNeeded()
    }

    private func add(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false

        if superview == nil {
            view.addSubview(self)
        }
    }

    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
