//
//  CALayer+Blur.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 9/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension CALayer {
    func applyShadow(color: UIColor = #colorLiteral(red: 0.2796378732, green: 0.5632485747, blue: 0.9918597341, alpha: 1),
                     alpha: Float = 0.33,
                     x: CGFloat = 0,
                     y: CGFloat = 6,
                     blur: CGFloat = 9,
                     spread: CGFloat = 0,
                     path: UIBezierPath? = nil) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowRadius = blur / 2
        if let path = path {
            if spread == 0 {
                shadowOffset = CGSize(width: x, height: y)
            } else {
                let scaleX = (path.bounds.width + (spread * 2)) / path.bounds.width
                let scaleY = (path.bounds.height + (spread * 2)) / path.bounds.height
                
                path.apply(CGAffineTransform(translationX: x + -spread, y: y + -spread).scaledBy(x: scaleX, y: scaleY))
                shadowPath = path.cgPath
            }
        } else {
            shadowOffset = CGSize(width: x, height: y)
            if spread == 0 {
                shadowPath = nil
            } else {
                let dx = -spread
                let rect = bounds.insetBy(dx: dx, dy: dx)
                shadowPath = UIBezierPath(rect: rect).cgPath
            }
        }
        shouldRasterize = true
        rasterizationScale = UIScreen.main.scale
    }
}
