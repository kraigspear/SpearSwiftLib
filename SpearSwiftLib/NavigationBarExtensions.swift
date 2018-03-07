//
//  NavigationBarExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/5/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import UIKit

public extension UINavigationItem {
    func removeBackbuttonTitle() {
        backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

public extension UIViewController {
    func removeBackBarTitle() {
        navigationItem.removeBackbuttonTitle()
    }
}
