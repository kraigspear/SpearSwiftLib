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
}
