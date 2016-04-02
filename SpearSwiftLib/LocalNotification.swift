//
//  LocalNotification.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 11/6/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public protocol LocationNotificationProtocol {
    var body:String? {get set}
    var action:String? {get set}
    var date:NSDate? {get set}
    var category:String? {get set}
    func schedule()
    func register()
}

public class LocationNotificationMock : LocationNotificationProtocol {
    public var body:String?
    public var action:String?
    public var date:NSDate?
    public var category:String?

    var scheduled:Int = 0
    public func schedule() {
        scheduled+=1
    }
    
    var registered:Int = 0
    public func register() {
        registered+=1
    }
}

public class LocalNotification : LocationNotificationProtocol {
    
    public var body:String?
    public var action:String?
    public var date:NSDate?
    public var category:String?
    
    public init() {}
    
    public func schedule() {
        let notification = UILocalNotification()
        notification.alertBody = body
        notification.alertAction = action
        notification.fireDate = date
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    public func register() {
        let types:UIUserNotificationType = ([UIUserNotificationType.Alert, UIUserNotificationType.Badge,  UIUserNotificationType.Sound])
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
}