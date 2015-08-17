//
//  ScrollViewExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 8/14/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import UIKit

extension UIScrollView {
    /*!
    Scroll this ScrollView to the bottom
    :param: animated Animate the scroll
    */
    public func scrollToBottom(animated:Bool = false) {
        self.layoutIfNeeded()
        let bottomOffset = CGPointMake(0, self.contentSize.height - bounds.size.height)
        self.setContentOffset(bottomOffset, animated: animated)
    }
}

