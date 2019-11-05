//
//  IsHideable.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 9/22/19.
//  Copyright © 2019 spearware. All rights reserved.
//

import UIKit

extension UIView: IsHideable {}

/// Can this type be hidden
/// Used to decouple UIView's
public protocol IsHideable: AnyObject {
    var isHidden: Bool { get set }
}
