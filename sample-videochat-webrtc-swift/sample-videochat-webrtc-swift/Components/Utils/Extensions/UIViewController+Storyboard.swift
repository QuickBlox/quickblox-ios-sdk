//
//  UIViewController+Storyboard.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 2/10/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

extension UIViewController {
    private class func instantiateControllerInStoryboard<T: UIViewController>(_ storyboard: UIStoryboard, identifier: String) -> T {
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    private class func controllerInStoryboard(_ storyboard: UIStoryboard, identifier: String) -> Self {
        return instantiateControllerInStoryboard(storyboard, identifier: identifier)
    }
    
    class func controllerFromStoryboard(_ storyboard: Storyboards) -> Self {
        return controllerInStoryboard(UIStoryboard(name: storyboard.rawValue, bundle: nil), identifier: className)
    }
}
