//
//  ForegroundNotification.swift
//  FastCast2
//
//  Created by Kraig Spear on 4/19/16.
//  Copyright © 2016 spearware. All rights reserved.
//


import UIKit

public protocol ForegroundNotificationDelegate: class {
    func enteredForeground()
}

public protocol ForegroundNotifyable: class {
    func foregroundNotification(notification: NSNotification)
    func start()
    func stop()
	var delegate: ForegroundNotificationDelegate? {get set}
}

public final class ForegroundNotification: ForegroundNotifyable {
    
    public var delegate: ForegroundNotificationDelegate?
    private var listening: Bool = false
	
	public init() {
		
	}
	
    public func start() {
        guard !listening else {
            return
        }
        initNotification()
    }
    
    public func stop() {
        guard listening else {
            return
        }
        NSNotificationCenter.defaultCenter().removeObserver(self)
        listening = false
    }
    
    private func initNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ForegroundNotification.foregroundNotification(_:)), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        listening = true
    }
    
    @objc public func foregroundNotification(notification: NSNotification) {
        delegate?.enteredForeground()
    }
    
    deinit {
        stop()
    }
}