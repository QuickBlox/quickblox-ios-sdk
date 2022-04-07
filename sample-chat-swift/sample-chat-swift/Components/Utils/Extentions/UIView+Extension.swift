//
//  UIView+Extension.swift
//  sample-chat-swift
//
//  Created by Injoit on 04.01.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation

extension UIView {
    class func loadNib<T: UIView>(_ viewType: T.Type) -> T {
        let className = String.className(viewType)
        return Bundle(for: viewType).loadNibNamed(className, owner: nil, options: nil)!.first as! T
    }
    
    class func loadNib() -> Self {
        return loadNib(self)
    }
    
    func rounded(cornerRadius: CGFloat) {
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
}
