//
//  LocalExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 6/25/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

extension NSLocale
{
  /// Is this device setup for metric
  public var isMetric:Bool
  {
    return self.objectForKey(NSLocaleUsesMetricSystem)!.boolValue
  }
}