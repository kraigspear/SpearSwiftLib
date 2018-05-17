//
//  Logger.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 4/22/18.
//  Copyright © 2018 spearware. All rights reserved.
//

import Foundation

// Enum for showing the type of Log Types
public enum LogEvent: String {
	case error = "[‼️]" // error
	case info = "[ℹ️]" // info
	case debug = "[💬]" // debug
	case verbose = "[🔬]" // verbose
	case warning = "[⚠️]" // warning
	case severe = "[🔥]" // severe
	
	var name: String {
		switch self {
		case .error:
			return "Error"
		case .info:
			return "Info"
		case .debug:
			return "Debug"
		case .verbose:
			return "Verbose"
		case .warning:
			return "Warning"
		case .severe:
			return "Severe"
		}
	}
}

// MARK: - Log

struct Log: CustomStringConvertible {
	let time: Date
	let deviceID: String
	let level: String
	let sourceFile: String
	let lineNumber: Int
	let column: Int
	
	let functionName: String
	let message: String
	
	enum CodingKeys: String, CodingKey {
		case time = "Time"
		case deviceID = "DeviceID"
		case level = "Level"
		case sourceFile = "SourceFile"
		case lineNumber = "LineNumber"
		case column = "Column"
		case functionName = "FunctionName"
		case message = "Message"
	}
	
	var description: String {
		return "\(time.toString()) \(level)[\(sourceFile)]:\(lineNumber) \(column) \(functionName) -> \(message)"
	}
}

extension Log: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		let GMT = TimeZone(abbreviation: "GMT")!
		
		let options: ISO8601DateFormatter.Options = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime, .withTimeZone, .withFractionalSeconds]
		let timeAsJSONString = ISO8601DateFormatter.string(from: time, timeZone: GMT, formatOptions: options)
		try container.encode(timeAsJSONString, forKey: Log.CodingKeys.time)
		
		try container.encode(deviceID, forKey: Log.CodingKeys.deviceID)
		try container.encode(level, forKey: Log.CodingKeys.level)
		try container.encode(sourceFile, forKey: Log.CodingKeys.sourceFile)
		try container.encode(lineNumber, forKey: Log.CodingKeys.lineNumber)
		try container.encode(column, forKey: Log.CodingKeys.column)
		try container.encode(functionName, forKey: Log.CodingKeys.functionName)
		try container.encode(message, forKey: Log.CodingKeys.message)
	}
}

public final class Logger {
	static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
	static var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateFormat = dateFormat
		formatter.locale = Locale.current
		formatter.timeZone = TimeZone.current
		return formatter
	}
	
	public static var deviceID: String?
	
	public static func log(message: String,
	                       event: LogEvent,
	                       fileName: String = #file,
	                       line: Int = #line,
	                       column: Int = #column,
	                       funcName: String = #function) {
		let log = Log(time: Date(),
		              deviceID: Logger.deviceID ?? "undefined",
					  
		              level: event.name,
		              sourceFile: sourceFileName(filePath: fileName),
		              lineNumber: line,
		              column: column,
		              functionName: funcName,
		              message: message)
		
		#if IOS_SIMULATOR
		//Logger.send(log)
		
		#else
		
		Logger.send(log)
		
		#endif
		
		print("\(Date().toString()) \(event.rawValue)[\(sourceFileName(filePath: fileName))]:\(line) \(column) \(funcName) -> \(message)")
	}
	
	private static func sourceFileName(filePath: String) -> String {
		let components = filePath.components(separatedBy: "/")
		return components.isEmpty ? "" : components.last!
	}
	
	private static func send(_ log: Log) {
		let sessionConfig = URLSessionConfiguration.default
		let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

		let baseUrl = URL(string: "https://spearlogger2.azurewebsites.net/api/Logger")!
		var networkPrameters = NetworkParameters()
		_ = networkPrameters.addParam("code", value: "iDDy9fM2AOGccLfsvWXbkkCtQ/FNEfJr5mOxnTXLJW4bzyx6bJjR9w==")
		let url = networkPrameters.NSURLByAppendingQueryParameters(baseUrl)
		var request = URLRequest(url: url)
		request.httpMethod = "POST"
		request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
		
		request.httpBody = try! JSONEncoder().encode(log)
		
		let task = session.dataTask(with: request) { (_, _, _) in
			
		}
		
		task.resume()
		session.finishTasksAndInvalidate()
	}
}

private extension Date {
	func toString() -> String {
		return Logger.dateFormatter.string(from: self as Date)
	}
}
