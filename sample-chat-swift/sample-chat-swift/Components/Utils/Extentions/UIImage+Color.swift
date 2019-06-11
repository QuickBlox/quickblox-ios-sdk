//
//  UIImage+Color.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

extension UIImage {
  func imageMasked(color: UIColor) -> UIImage? {
    let rect = CGRect(origin: .zero, size: size)
    UIGraphicsBeginImageContextWithOptions(size, false, scale)
    guard let context = UIGraphicsGetCurrentContext(), let cgImage = cgImage else {
      UIGraphicsEndImageContext()
      return nil
    }
    context.scaleBy(x: 1.0, y: -1.0)
    context.translateBy(x: 0.0, y: -size.height)
    context.clip(to: rect, mask: cgImage)
    context.setFillColor(color.cgColor)
    context.fill(rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return image
  }
}
