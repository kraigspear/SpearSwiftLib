//
//  DateFormatters.swift
//  FastCast2
//
//  Created by Kraig Spear on 12/17/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

public enum DateFormat: String {
    case hmm_a = "h:mm a"
    case ha
    case hmm = "h:mm"
    case dayOfWeek = "EEEE"

    func createFormatter(inTimeZone: TimeZone) -> DateFormatter {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = rawValue
        dateFormatter.timeZone = inTimeZone

        return dateFormatter
    }
}

/// Central place to contain all DateFormatters to be reused.
public final class DateFormatters {
    public static let instance = DateFormatters()

    private init() {}

    public lazy var zulu: [DateFormatter] = {
        let utcTimeZone = TimeZone(secondsFromGMT: 0)

        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter1.timeZone = utcTimeZone

        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter2.timeZone = utcTimeZone

        return [dateFormatter1, dateFormatter2]
    }()

    public lazy var dayOfWeekFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dayOfWeek.rawValue
        return dateFormatter
    }()
	
	public lazy var shortTime: DateFormatter = {
        let dateFormatter = DateFormatter()
		dateFormatter.timeStyle = .short
        return dateFormatter
	}()
	
	public lazy var shortDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .short
        return dateFormatter
	}()

	
	
}
