//
//  UITextField+Extension.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 11.11.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setPadding(left: CGFloat? = nil, right: CGFloat? = nil){
        if let left = left {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        
        if let right = right {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: self.frame.size.height))
            self.rightView = paddingView
            self.rightViewMode = .always
        }
    }
    
    func addShadow(color: UIColor = .gray, cornerRadius: CGFloat) {
        self.backgroundColor = UIColor.white
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 6)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 6
        self.layer.cornerRadius = cornerRadius
    }
}
