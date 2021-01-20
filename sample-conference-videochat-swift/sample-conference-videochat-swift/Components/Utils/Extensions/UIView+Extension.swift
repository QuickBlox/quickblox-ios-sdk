//
//  UIView+Extension.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.01.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }

    func setRoundView(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    func setRoundBorderEdgeColorView(cornerRadius: CGFloat, borderWidth: CGFloat, color: UIColor? = nil, borderColor: UIColor) {
        if let color = color {
            backgroundColor = color
        }
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    func roundTopCorners(radius: Int = 14) {
        layer.cornerRadius = CGFloat(radius)
        clipsToBounds = true
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    func roundCorners(radius: Int = 6, isIncoming: Bool) {
        layer.cornerRadius = CGFloat(radius)
        clipsToBounds = true
        if isIncoming == true {
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        } else {
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    func addShadowToView(color: UIColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)) {
        self.backgroundColor = .white
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 12)
        self.layer.shadowColor = UIColor(red:0.22, green:0.47, blue:0.99, alpha:0.5).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 11
    }
}
