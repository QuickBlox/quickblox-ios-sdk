//
//  UIViewController+InfoScreen.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addInfoButton() {
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
        infoButtonItem.imageInsets = UIEdgeInsets(top: 2.0, left: 4.0, bottom: -4.0, right: -4.0)
        infoButtonItem.tintColor = .white

        if navigationItem.rightBarButtonItems?.count == nil {
            navigationItem.rightBarButtonItem = infoButtonItem
        } else {
            var rightBarButtonItems = navigationItem.rightBarButtonItems
            rightBarButtonItems?.append(infoButtonItem)
            navigationItem.rightBarButtonItems = rightBarButtonItems;
            
        }
    }
    
    @objc private func didTapInfoButton(sender: UIBarButtonItem) {
        guard let infoController = Screen.infoTableViewController() else {
            return
        }
        navigationController?.pushViewController(infoController, animated: true)
    }
}
