//
//  DateExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 10/9/15.
//  Copyright © 2015 spearware. All rights reserved.
//

import Foundation

public func - (left: Date, right: Date) -> (month: Int, day: Int, year: Int, hour: Int, minute: Int, second: Int) {
    return left.subtractDate(right)
}

public extension Date {
    /**
     Adds a certain number of days to this date

     - Parameter numberOfDays: The number of days to add

     - Returns: A new date with numberOfDays added

     ```swift
     let oct172015 = NSDate(timeIntervalSince1970: 1445077917)
     let aDayLater = oct172015.addDays(1)
     let mdy = aDayLater.toMonthDayYear()
     XCTAssertEqual(18, mdy.day)
     ```

     */
    func addDays(_ numberOfDays: Int) -> Date {
        var dayComponent = DateComponents()
        dayComponent.day = numberOfDays
        let calendar = Calendar.current
        return calendar.date(byAdding: dayComponent, to: self)!
    }

    func addMinutes(_ numberOfMinutes: Int) -> Date {
        var dayComponent = DateComponents()
        dayComponent.minute = numberOfMinutes
        let calendar = Calendar.current
        return calendar.date(byAdding: dayComponent, to: self)!
    }

    func addHours(_ numberOfHours: Int) -> Date {
        var dayComponent = DateComponents()
        dayComponent.hour = numberOfHours
        let calendar = Calendar.current
        return calendar.date(byAdding: dayComponent, to: self)!
    }

    /**
     Is this day the same day as the other date? Ignoreing time

     - Parameter date: The date to compare this time with

     - Returns: true if the two days occure on the same day
     */
    func isSameDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.month, .day, .year], from: self)
        let components2 = calendar.dateComponents([.month, .day, .year], from: date)

        return components1.month == components2.month &&
            components1.day == components2.day &&
            components1.year == components2.year
    }

    /// Subtract two dates and return them as a tuple.
    ///
    /// - Parameter otherDate: The other date to compare with
    ///
    /// - Returns: The difference in the two dates as m/d/y/h/m/s
    func subtractDate(_ otherDate: Date) -> (month: Int, day: Int, year: Int, hour: Int, minute: Int, second: Int) {
        let calendar = Calendar.current

        let types: Set<Calendar.Component> = [
            Calendar.Component.month,
            Calendar.Component.day,
            Calendar.Component.year,
            Calendar.Component.hour,
            Calendar.Component.minute,
            Calendar.Component.second,
        ]

        let dateComponents = calendar.dateComponents(types, from: self, to: otherDate)

        return (month: dateComponents.month!,
                day: dateComponents.day!,
                year: dateComponents.year!,
                hour: dateComponents.hour!,
                minute: dateComponents.minute!,
                second: dateComponents.second!)
    }

    func toMonthDayYearHourMinutesSeconds() -> (month: Int, day: Int, year: Int, hour: Int, minutes: Int, seconds: Int) {
        let flags: Set<Calendar.Component> = [.month, .day, .year, .hour, .minute, .second]
        let components = Calendar.current.dateComponents(flags, from: self)

        let m = components.month!
        let d = components.day!
        let y = components.year!
        let h = components.hour!
        let min = components.minute!
        let s = components.second!

        return (month: m, day: d, year: y, hour: h, minutes: min, seconds: s)
    }

    /**
     Extract out the m/d/y parts of a date into a Tuple

     - Returns: A tuple as three ints that include month day year
     */
    func toMonthDayYear() -> (month: Int, day: Int, year: Int) {
        let flags: Set<Calendar.Component> = [
            Calendar.Component.month,
            Calendar.Component.day,
            Calendar.Component.year,
        ]

        let components = Calendar.current.dateComponents(flags, from: self)
        let m = components.month!
        let d = components.day!
        let y = components.year!
        return (month: m, day: d, year: y)
    }

    func toJullianDayNumber() -> Double {
        let components = toMonthDayYear()

        let a = floor(Double((14 - components.month) / 12))
        let y = Double(components.year) + 4800.0 - a
        let m = Double(components.month) + 12.0 * a - 3.0

        var f: Double = (153.0 * m + 2.0) / 5.0
        f += 365.0 * y
        f += floor(y / 4.0)
        f -= floor(y / 100.0)
        f += floor(y / 400.0)
        f -= 32045

        let jdn: Double = Double(components.day) + f

        return jdn
    }

    static func fromMonth(_ month: Int, day: Int, year: Int) -> Date? {
        var components = DateComponents()
        components.month = month
        components.day = day
        components.year = year
        return Calendar.current.date(from: components)
    }

    func fromDay(_ percentage: Double) -> Date? {
        let secondsInDay = Double(24 * 60 * 60)

        let secondsPct = Double(percentage * secondsInDay)

        let totalMinutes = secondsPct / 60.0
        let h = totalMinutes / 60
        let m = totalMinutes.truncatingRemainder(dividingBy: 60)
        let s = secondsPct.truncatingRemainder(dividingBy: 60.0)

        var gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        gregorian.timeZone = TimeZone(abbreviation: "GMT")!
        var components = DateComponents()

        let mdy = toMonthDayYear()

        components.month = mdy.month
        components.day = mdy.day
        components.year = mdy.year
        components.hour = Int(h)
        components.minute = Int(m)
        components.second = Int(s)

        return gregorian.date(from: components)
    }

    /**
     Is this date between startDate and endDate
     */
    func isBetween(_ startDate: Date, endDate: Date) -> Bool {
        return timeIntervalSinceReferenceDate >= startDate.timeIntervalSinceReferenceDate &&
            timeIntervalSinceReferenceDate <= endDate.timeIntervalSinceReferenceDate
    }

    func numberOfMinutesBetween(_ otherDate: Date, absolute: Bool = true) -> Int {
        let calendarUnit: Set<Calendar.Component> = [Calendar.Component.minute]
        let difference = Calendar.current.dateComponents(calendarUnit, from: self, to: otherDate)
        return absolute ? abs(difference.minute!) : difference.minute!
    }

    func numberOfMinutesBetweenNow(absolute: Bool = true) -> Int {
        return numberOfMinutesBetween(Date(), absolute: absolute)
    }

    /**
     Convert this date to a string formatted as zulu date

     - returns: Date formattted as a zule date
     - seealso: String.toDateFromZulu()
     */
    func toZuluFormattedString() -> String {
        assert(DateFormatters.instance.zulu.count > 0, "We expect to have at least one Zulu formatter")
        let firstFormatter = DateFormatters.instance.zulu.first!
        return firstFormatter.string(from: self)
    }

    /// Midnight on this date
    var firstHourOfDay: Date {
        let flags: Set<Calendar.Component> = [
            Calendar.Component.month,
            Calendar.Component.day,
            Calendar.Component.year,
        ]

        var components = Calendar.current.dateComponents(flags, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0

        return Calendar.current.date(from: components)!
    }

    /// The last hour, minute, second of this day
    var lastHourOfDay: Date {
        let flags: Set<Calendar.Component> = [
            Calendar.Component.month,
            Calendar.Component.day,
            Calendar.Component.year,
        ]

        var components = Calendar.current.dateComponents(flags, from: self)
        components.hour = 23
        components.minute = 59
        components.second = 59

        return Calendar.current.date(from: components)!
    }

    /// Convience property for readability to encourage one way to get epoch. `timeIntervalSince1970`
    var epoch: TimeInterval { timeIntervalSince1970 }
}
