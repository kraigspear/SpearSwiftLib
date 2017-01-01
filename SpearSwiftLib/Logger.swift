//
//  Logger.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 1/1/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import Foundation

///Logs events
public final class Logger {
	public static let sharedInstance = Logger()
	
	private let dateFormatter: DateFormatter
	
	private init() {
		dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss.SSS"
	}
	
	public func verbose(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
		print("\(date) 💚 verbose: \(message) called from \(function) in \(file.lastPathComponent):\(line)")
	}
	
	public func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
		print("\(date) 💜 debug: \(message) called from \(function) in \(file.lastPathComponent):\(line)")
	}
	
	public func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
		print("\(date) 💙 info: \(message) called from \(function) in \(file.lastPathComponent):\(line)")
	}
	
	public func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
		print("\(date) 💛 warning: \(message) called from \(function) in \(file.lastPathComponent):\(line)")
	}
	
	public func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
		print("\(date) ♥️ error: \(message) called from \(function) in \(file.lastPathComponent):\(line)")
	}
	
	private var date: String {
		return dateFormatter.string(from: Date())
	}
}
