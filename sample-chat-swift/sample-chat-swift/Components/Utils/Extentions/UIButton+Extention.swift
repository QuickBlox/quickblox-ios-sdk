//
//  UIButton+Extention.swift
//  sample-chat-swift
//
//  Created by Injoit on 9/26/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

extension UIButton {
    
    func addShadowToButton(color: UIColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1), cornerRadius: CGFloat) {
        self.backgroundColor = .white
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 12)
        self.layer.shadowColor = UIColor(red:0.22, green:0.47, blue:0.99, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 11
        self.layer.cornerRadius = cornerRadius
    }
    
    func removeShadowFromButton() {
        self.backgroundColor = .clear
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowOpacity = 0
        self.layer.shadowRadius = 0
    }
}
