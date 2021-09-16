//
//  UITextField+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 9/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setPadding(left: CGFloat? = nil, right: CGFloat? = nil){
        if let left = left {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: frame.size.height))
            leftView = paddingView
            leftViewMode = .always
        }
        
        if let right = right {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: frame.size.height))
            rightView = paddingView
            rightViewMode = .always
        }
    }
    
    func addShadow(color: UIColor = .gray, cornerRadius: CGFloat) {
        backgroundColor = UIColor.white
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowOpacity = 1
        layer.shadowRadius = 6
        layer.cornerRadius = cornerRadius
    }
}
