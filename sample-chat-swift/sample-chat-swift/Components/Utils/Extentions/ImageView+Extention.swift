//
//  ImageView+Extention.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setRoundedView(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }
}

extension UIView {
    func setRoundBorderEdgeView(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
    }
}
