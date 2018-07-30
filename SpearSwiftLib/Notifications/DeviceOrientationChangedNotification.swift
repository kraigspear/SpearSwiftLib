//
//  DeviceOrientationChangedNotification.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/4/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

public final class DeviceOrientationChangedNotification: BaseNotification<Void> {
    public override init(clientName: String) {
        super.init(clientName: clientName)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDeviceOrientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc public func onDeviceOrientationChanged(_: Notification) {
        DeviceOrientationChangedNotification.post()
    }

    /// Identifier for the notification
    public override class var notificationName: String { return "deviceOrientationChanged" }
}
