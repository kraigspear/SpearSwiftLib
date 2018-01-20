//
//  BaseNotification.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 3/16/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation

public enum NotificationValue<T> {
	case empty
	case value(value: T)
}

///BaseNotfication, should not create directly. To be dirrived by a child class
open class BaseNotification<NotifiedOf>: NSObject {
	
	///Used to control if we are observing or not the notification
	public var observing = false
	
	///Name of the client that is observing this notification
	open let clientName: String
	
	///Closure that is called when the DataChangedNotification is raised.
	public var onNotification: ((NotificationValue<NotifiedOf>) -> Void)?
	
	public init(clientName: String) {
		self.clientName = clientName
	}
	
	deinit {
		unobserve()
	}
	
	///Name of the notification, needs to be unique between all child classes of BaseNotification
	open class var notificationName: String {preconditionFailure("Should be overriden in a child class")}
	
	///Post that this notification has occured
	public static func post(notifiedValue: NotificationValue<NotifiedOf> = NotificationValue.empty) {
		DispatchQueue.main.async {
			
			switch notifiedValue {
			case .empty:
				NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil)
			case .value(value: let value):
				NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: value)
			}
		}
	}
	
	public func observe()  {
		
		guard observing == false else {
			return
		}
		
		let notificationName = type(of: self).notificationName
		
		NotificationCenter.default.addObserver(self,
		                                       selector: #selector(onNotificationObserved),
		                                       name: NSNotification.Name(rawValue: notificationName),
		                                       object: nil)
		observing = true
	}
	
	///Stop observing for the notification
	public func unobserve() {
		
		guard observing else {return}
		NotificationCenter.default.removeObserver(self)
		observing = false
	}
	
	///Handler for the observer
	@objc func onNotificationObserved(_ notification: Notification) {
		
		guard let onNotification = self.onNotification else {
			return
		}
		
		if NotifiedOf.self == Void.self {
			onNotification(NotificationValue.empty)
			return
		}
		
		if let notificationObject = notification.object as? NotifiedOf {
			onNotification(NotificationValue<NotifiedOf>.value(value: notificationObject))
		}
		else {
			preconditionFailure("Don't have the correct value for this notification type")
		}
	}
}
