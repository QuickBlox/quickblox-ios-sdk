//
//  ReplaceSegue.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/18/16.
//  Copyright © 2016 quickblox. All rights reserved.
//

import Foundation

class ReplaceSegue : UIStoryboardSegue {
	
	override func perform() {
		let sourceViewController = self.source
		let destinationViewController = self.destination
		
		let navigationController = sourceViewController.navigationController
		
		navigationController?.pushViewController(destinationViewController, animated: false)
        
		guard var mutableVC = navigationController?.viewControllers else {
			print("Error: no view controllers")
			return
		}
		
		guard let sourceViewControllerIndex = mutableVC.index(of: sourceViewController) else {
			print("Error: no index for source view controller")
			return
		}

		mutableVC.remove(at: sourceViewControllerIndex)
		
		navigationController?.setViewControllers(mutableVC, animated: true)
	}
	
}
