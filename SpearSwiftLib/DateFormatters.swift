//
//  DateFormatters.swift
//  FastCast2
//
//  Created by Kraig Spear on 12/17/16.
//  Copyright © 2016 spearware. All rights reserved.
//

import Foundation

///Central place to contain all DateFormatters to be reused.
public final class DateFormatters {
	
	public static let instance = DateFormatters()
	
	private init() {}
	
	public lazy var hmm_a: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "h:mm a"
		return dateFormatter
	}()
	
	public lazy var ha: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "ha"
		return dateFormatter
	}()
	
	public lazy var hmm: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "h:mm"
		return dateFormatter
	}()
}

