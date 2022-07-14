//
//  UIViewController+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 2/10/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertView(_ title : String?, message : String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
    
    func showAnimatedAlertView(_ title : String?, message : String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        present(alert, animated: false, completion:{
            UIView.animate(withDuration: 1.5, delay: 2.0, options: .curveEaseIn) {
                alert.view.alpha = 0.0
            } completion: { finished in
                DispatchQueue.main.async {
                    alert.dismiss(animated: false)
                }
            }
        })
    }
    
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
