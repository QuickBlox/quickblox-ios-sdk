//
//  UIViewController+Alert.swift
//  sample-chat-swift
//
//  Created by Injoit on 05.10.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlertView(_ title : String?, message : String?, handler: ((UIAlertAction) -> Void)?) {
        if presentedViewController is UIAlertController {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel,
                                      handler: handler))
        present(alert, animated: true)
    }
    
    func showNoInternetAlert(handler: ((UIAlertAction) -> Void)?) {
        if presentedViewController is UIAlertController {
            return
        }
        let alert = UIAlertController(title: nil,
                                      message: ConnectionConstant.noInternetConnection,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel,
                                      handler: handler))
        present(alert, animated: true)
    }
    
    func showUnAuthorizeAlert(message: String, logoutAction: ((UIAlertAction) -> Void)?, tryAgainAction: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: nil,
                                      message: message,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Logout", style: .cancel,
                                      handler: logoutAction))
        alert.addAction(UIAlertAction(title: "Try Again", style: .default,
                                      handler: tryAgainAction))
        present(alert, animated: true)
    }
    
    func showAnimatedAlertView(_ title : String?, message : String?) {
        if presentedViewController is UIAlertController {
            return
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        present(alert, animated: false, completion:{
            UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn) {
                alert.view.alpha = 0.0
            } completion: { finished in
                DispatchQueue.main.async {
                    alert.dismiss(animated: false)
                }
            }
        })
    }
    
    func hideAlertView() {
        guard let alert = presentedViewController as? UIAlertController else {
            return
        }
        alert.dismiss(animated: false)
    }
}
