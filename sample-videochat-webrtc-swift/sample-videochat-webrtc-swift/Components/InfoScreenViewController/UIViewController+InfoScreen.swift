//
//  UIViewController+InfoScreen.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/3/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showInfoButton() {
        var needAdd = true
        if let rightBarButtonItems = navigationItem.rightBarButtonItems {
            for barButton in rightBarButtonItems {
                if barButton.action == #selector(didTapInfoButton){
                    needAdd = false
                }
            }
        }
        
        if needAdd == false {
            return
        }
        let infoButtonItem = UIBarButtonItem(image: UIImage(named: "icon-info"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapInfoButton))
        if navigationItem.rightBarButtonItems?.count == nil {
            navigationItem.rightBarButtonItem = infoButtonItem
        } else {
            var rightBarButtonItems = navigationItem.rightBarButtonItems
            rightBarButtonItems?.append(infoButtonItem)
            navigationItem.rightBarButtonItems = rightBarButtonItems 
        }
    }
    
    @objc private func didTapInfoButton(sender: UIBarButtonItem) {
        let infoStoryboard =  UIStoryboard(name: "InfoScreen", bundle: nil)
        let infoController = infoStoryboard.instantiateViewController(withIdentifier: "InfoTableViewController")
        navigationController?.pushViewController(infoController, animated: true)
    }
}
