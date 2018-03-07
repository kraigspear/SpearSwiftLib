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
    public func scrollToBottom(_ animated: Bool = false) {
        layoutIfNeeded()
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        setContentOffset(bottomOffset, animated: animated)
    }
}
