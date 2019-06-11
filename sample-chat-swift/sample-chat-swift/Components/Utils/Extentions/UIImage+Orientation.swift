//
//  UIImage+Orientation.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 quickblox. All rights reserved.
//

import UIKit

extension UIImage {
    func fixOrientation() -> UIImage {
        var transformOrientation: CGAffineTransform = .identity
        let width = size.width
        let height = size.height
        if imageOrientation == .up {
            return self
        }
        
        if imageOrientation == .down || imageOrientation == .downMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: height)
            transformOrientation = transformOrientation.rotated(by: .pi)
        } else if imageOrientation == .left || imageOrientation == .leftMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: 0)
            transformOrientation = transformOrientation.rotated(by: .pi/2)
        } else if imageOrientation == .right || imageOrientation == .rightMirrored {
            transformOrientation = transformOrientation.translatedBy(x: 0, y: height)
            transformOrientation = transformOrientation.rotated(by: -(.pi/2))
        }
        
        if imageOrientation == .upMirrored || imageOrientation == .downMirrored {
            transformOrientation = transformOrientation.translatedBy(x: width, y: 0)
            transformOrientation = transformOrientation.scaledBy(x: -1, y: 1)
        } else if imageOrientation == .leftMirrored || imageOrientation == .rightMirrored {
            transformOrientation = transformOrientation.translatedBy(x: height, y: 0)
            transformOrientation = transformOrientation.scaledBy(x: -1, y: 1)
        }
        
        guard let cgImage = self.cgImage, let space = cgImage.colorSpace,
            let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: space, bitmapInfo: cgImage.bitmapInfo.rawValue)  else {
                return UIImage()
        }
        context.concatenate(transformOrientation)
        
        if imageOrientation == .left ||
            imageOrientation == .leftMirrored ||
            imageOrientation == .right ||
            imageOrientation == .rightMirrored {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        } else {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        
        guard let newCGImage = context.makeImage() else {
            return UIImage()
        }
        let image = UIImage(cgImage: newCGImage)

        return image
    }
}
