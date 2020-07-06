//
//  UILabel+Extention.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.01.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

extension UILabel {
    func setRoundedBorderEdgeLabel(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layer.borderWidth = borderWidth
        layer.cornerRadius = cornerRadius
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    func setRoundedLabel(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }
}
