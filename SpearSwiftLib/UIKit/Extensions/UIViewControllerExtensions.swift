//
//  UIViewControllerExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/16/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import UIKit

public extension UIViewController {
	/**
	 Show an error message alert
	 */
	public func showErrorMessage(_ message: String) {
		let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		
		let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
		alertController.addAction(action)
		
		present(alertController, animated: true, completion: nil)
	}
	
	/**
	Prompt using an ActionSheet for a series of options
	- parameter title: Title for the Alert
	- parameter message: Message to display
	- parameter options: Options
	- parameter completed: Result of the Alert, nil if an option wasn't selected
	*/
	public func promptForOptions(title: String,
	                             message: String,
	                             options: [String],
	                             completed: @escaping (String?) -> Void) {
		let alertController = UIAlertController(title: title,
		                                        message: message,
		                                        preferredStyle: .actionSheet)
		
		options.forEach {
			let action = UIAlertAction(title: $0,
			                           style: .default) { action in
				completed(action.title)
			}
			
			alertController.addAction(action)
		}
		
		let cancelText = NSLocalizedString("Cancel", comment: "Cancel")
		
		let cancelAction = UIAlertAction(title: cancelText,
		                                 style: .cancel) { _ in
			
			completed(nil)
		}
		
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}
}
