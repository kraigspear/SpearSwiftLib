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
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
