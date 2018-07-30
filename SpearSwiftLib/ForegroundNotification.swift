//
//  ForegroundNotification.swift
//  FastCast2
//
//  Created by Kraig Spear on 4/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import UIKit

/**
 Protocol to be implemented by a type that wants to know when the App has entered
 the foreground
 */
public protocol ForegroundNotificationDelegate: class {
    /**
     Called when the device has entered the foreground
     */
    func enteredForeground()
}

/**

 Abstracts out the NSNotification foreground notification into a class that can be used in a non-NSObject class
 like a ViewModel.

 You can start and stop listening to the notification, which could be done when the view is active / inactive

 To be implemented by a type that knows how to notify its delegate that the App
 has entered the foreground

 ```swift

 //Declare
 private let foregroundNotification: ForegroundNotifyable

 //Delegate
 self.foregroundNotification.delegate = self

 //If this is the Active ViewModel? Is it visible?

 var active: Bool = false {
 didSet {
 if active {
 foregroundNotification.start()
 } else {
 foregroundNotification.stop()
 }
 }
 }

 //Receiving the event, we can do what we need to do when the App become active,
 //like refresh

 extension SummaryViewModel: ForegroundNotificationDelegate {
 fun enteredForeground() {
 refresh()
 }
 }

 ```

 */
public protocol ForegroundNotifyable: class {
    /**
     Receives the message from NSNotification that the device has entered the
     foreground
     im
     - parameter notification: NSNotification for the Foreground notification
     */
    func foregroundNotification(_ notification: Notification)
    /**
     Start listening for notifications
     */
    func start()
    /**
     Stop listening for notifications
     */
    func stop()
    /**
     Gets / Sets the delegate that gets notified when then the App has entered
     the foreground
     */
    var delegate: ForegroundNotificationDelegate? { get set }
}

/**
 Implementation of ForegroundNotifyable

 ```swift

 private let foregroundNotification: ForegroundNotifyable

 self.foregroundNotification.delegate = self

 //If this is the Active ViewModel? Is it visible?

 var active: Bool = false {
 didSet {
 if active {
 foregroundNotification.start()
 } else {
 foregroundNotification.stop()
 }
 }

 }

 //Receiving the event, we can do what we need to do when the App become active,
 //like refresh

 extension SummaryViewModel: ForegroundNotificationDelegate {
 fun enteredForeground() {
 refresh()
 }
 }

 ```

 */
public final class ForegroundNotification: ForegroundNotifyable {
    public var delegate: ForegroundNotificationDelegate?
    var listening: Bool = false

    public init() {}

    /// Start listening for the notification
    public func start() {
        guard !listening else {
            return
        }
        initNotification()
    }

    /// Stop listening for the notification
    public func stop() {
        guard listening else {
            return
        }
        NotificationCenter.default.removeObserver(self)
        listening = false
    }

    private func initNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ForegroundNotification.foregroundNotification(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)

        listening = true
    }

    @objc public func foregroundNotification(_: Notification) {
        delegate?.enteredForeground()
    }

    deinit {
        stop()
    }
}
