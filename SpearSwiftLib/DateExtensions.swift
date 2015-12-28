//
//  DateExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/9/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public func -(left:NSDate, right:NSDate) -> (month:Int, day:Int, year:Int, hour:Int, minute:Int, second:Int)
{
    return left.subtractDate(right)
}

public extension NSDate
{
    public func addDays(numberOfDays:Int) -> NSDate
    {
        let dayComponent = NSDateComponents()
        dayComponent.day = numberOfDays
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateByAddingComponents(dayComponent, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    /// Is this day the same day as the other date? Ignoreing time
    /// :param:date The other day to compare this day to.
    public func isSameDay(date:NSDate) -> Bool
    {
        let calendar = NSCalendar.currentCalendar()
        let components1 = calendar.components([.Month, .Day, .Year], fromDate:self)
        let components2 = calendar.components([.Month, .Day, .Year], fromDate:date)
        
        return components1.month == components2.month &&
               components1.day == components2.day &&
               components1.year == components2.year
    }
    
    /// Subtract two dates and return them as a tuple. 
    /// :param: The other date to compare with
    /// :returns: The difference in the two dates.
    public func subtractDate(otherDate:NSDate) -> (month:Int, day:Int, year:Int, hour:Int, minute:Int, second:Int)
    {
        let calendar = NSCalendar.currentCalendar()
        let flags:NSCalendarUnit = [.Month, .Day, .Year, .Hour, .Minute, .Second]
        let components = calendar.components(flags, fromDate: self, toDate: otherDate, options: NSCalendarOptions(rawValue: 0))
        return (month:components.month,
            day:components.day,
            year:components.year,
            hour:components.hour,
            minute:components.minute,
            second:components.second)
    }
    
    /**
     Extract out the m/d/y parts of a date into a Tuple
     - Returns:A tuple as three ints that include month day year
    */
    public func toMonthDayYear() -> (month:Int, day:Int, year:Int) {
        let flags:NSCalendarUnit = [.Month, .Day, .Year]
        let components = NSCalendar.currentCalendar().components(flags, fromDate: self)
        let m = components.month
        let d = components.day
        let y = components.year
        return (month:m, day:d, year:y)
    }
    
}