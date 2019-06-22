//
//  UIViewControllerExtensions.swift
//  SpearSwiftLib
//
//  Created by Kraig Spear on 7/16/17.
//  Copyright © 2017 spearware. All rights reserved.
//

import UIKit

public protocol ErrorMessageRetrying {
	func showErrorMessageRetry(_ message: String,
	                           completed: @escaping (Bool) -> Void)
}

public extension ErrorMessageRetrying where Self: UIViewController {
	func showErrorMessageRetry(_ message: String,
	                           completed: @escaping (Bool) -> Void) {
		let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
			completed(false)
		}

		let retryAction = UIAlertAction(title: "Retry", style: .default) { _ in
			completed(true)
		}

		alertController.addAction(cancelAction)
		alertController.addAction(retryAction)

		present(alertController, animated: true, completion: nil)
	}
}

public protocol AlertShowing {
	func showMessage(_ message: String,
	                 title: String,
	                 completed: VoidBlock?)
}

public extension AlertShowing where Self: UIViewController {
	/**
	Show a standard alert
	*/
	func showMessage(_ message: String,
					 title: String,
					 completed: (() -> Void)? = nil) {
		let alertController = UIAlertController(title: title,
												message: message,
												preferredStyle: .alert)
		
		let alertTitle = NSLocalizedString("OK", comment: "")
		
		let action = UIAlertAction(title: alertTitle, style: .default) { _ in
			completed?()
		}
		
		alertController.addAction(action)
		
		present(alertController, animated: true, completion: nil)
	}
}

public extension UIViewController {
	/**
	 Show an error message alert
	 */
	func showErrorMessage(_ message: String,
	                      completed: (() -> Void)? = nil) {
		let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)

		let action = UIAlertAction(title: "OK", style: .cancel) { _ in
			completed?()
		}

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
	func promptForOptions(title: String,
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
