//
//  BackgroundImageSettable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 9/22/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import Foundation

public protocol BackgroundImageSettable: AnyObject {
    func setImage(_ image: UIImage)
}

extension UIBarButtonItem: BackgroundImageSettable {
    public func setImage(_ image: UIImage) {
        setBackgroundImage(image, for: .normal, barMetrics: .default)
    }
}
