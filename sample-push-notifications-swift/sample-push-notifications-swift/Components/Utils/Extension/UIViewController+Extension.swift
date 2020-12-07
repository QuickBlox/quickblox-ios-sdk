//
//  UIViewController+Extension.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 11.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlertView(_ title : String?, message : String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true, completion:{
        })
    }
}
