//
//  UIViewController+Extention.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 2/10/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UIViewController {
    
    func showAlertView(_ title : String?, message : String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel,
                                      handler: nil))
        self.present(alert, animated: true, completion:{
            SVProgressHUD.dismiss()
        })
    }
}
