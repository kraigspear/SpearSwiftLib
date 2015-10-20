//
//  Timer.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/20/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation


public protocol TimerProtocol {
    func start()
    func stop()
    var fired:Event<Void> {get}
    var isRunning:Bool {get}
}

///Simplified timer. TimerProtocol can be used in unit test.
public class Timer : TimerProtocol  {
    
    private var timer:NSTimer?
    private let interval:NSTimeInterval
    
    public init(interval:NSTimeInterval) {
        self.interval = interval
    }
    
    public func start() {
        
        guard self.timer == nil else {
            return
        }
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(interval, target:self, selector:Selector("timerFired"), userInfo:nil, repeats:true)
    }
    
    @objc func timerFired() {
        fired.raise()
    }
    
    public var isRunning:Bool {
        return self.timer != nil
    }
    
    public func stop() {
        guard let timer = self.timer else {
            return
        }
        timer.invalidate()
        self.timer = nil
    }
    
    public let fired:Event<Void> = Event<Void>()
}