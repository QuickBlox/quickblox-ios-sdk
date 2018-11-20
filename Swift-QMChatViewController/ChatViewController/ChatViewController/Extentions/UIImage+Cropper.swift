//
//  UIImage+Cropper.swift
//  Swift-QMChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/15/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

extension UIImage {
  
  func withCornerRadius(_ cornerRadius: CGFloat, targetSize: CGSize) -> UIImage? {
    
    guard let scaledImage = byScaleAndCrop(targetSize), let scaledImageCgImage = scaledImage.cgImage,
      let context = UIGraphicsGetCurrentContext()  else {
      return UIImage()
    }
    
    let scaleFactor = Float(UIScreen.main.scale)
    UIGraphicsBeginImageContextWithOptions(scaledImage.size, false, CGFloat(scaleFactor))
    
    // Build a context that's the same dimensions as the new size
    context.translateBy(x: 0.0, y: scaledImage.size.height)
    context.scaleBy(x: 1.0, y: -1.0)
    
    // Create a clipping path with rounded corners
    let path = UIBezierPath(roundedRect: CGRect(x: 0.0, y: 0.0, width: scaledImage.size.width,
                                                height: scaledImage.size.height ),
                            byRoundingCorners: .allCorners,
                            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
    
    context.addPath(path.cgPath)
    context.clip()
    
    let imageRect = CGRect(x: 0.0, y: 0.0, width: scaledImage.size.width, height: scaledImage.size.height)
    context.draw(scaledImageCgImage, in: imageRect)
    
    // Draw the image to the context; the clipping path will make anything outside the rounded rect transparent
    
    // Create a CGImage from the context
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    
    UIGraphicsEndImageContext()
    
    return roundedImage
  }
  
  func image(byScaleAndCrop targetSize: CGSize) -> UIImage? {

    let targetWidth: CGFloat = targetSize.width
    let targetHeight: CGFloat = targetSize.height
    
    var scaleFactor: CGFloat = 0.0
    var scaledWidth: CGFloat = targetWidth
    var scaledHeight: CGFloat = targetHeight
    
    var thumbnailPoint = CGPoint(x: 0.0, y: 0.0)
    
    if size.equalTo(targetSize) == false {
      
      let widthFactor: CGFloat = targetWidth / size.width
      let heightFactor: CGFloat = targetHeight / size.height
      
      if widthFactor > heightFactor {
        scaleFactor = widthFactor
      } else {
        scaleFactor = heightFactor
      }
      
      scaledWidth = size.width * scaleFactor
      scaledHeight = size.height * scaleFactor
      
      // center the image
      
      if widthFactor > heightFactor {
        thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
      } else {
        thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
      }
    }
    // this is actually the interesting part:
    UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
    
    var thumbnailRect = CGRect.zero
    thumbnailRect.origin = thumbnailPoint
    thumbnailRect.size.width = scaledWidth
    thumbnailRect.size.height = scaledHeight
    
    draw(in: thumbnailRect)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  func image(byCircularScaleAndCrop targetSize: CGSize) -> UIImage? {
    var targetSize = targetSize
    //bitmap context properties
    var scaleFactor = CGFloat(UIScreen.main.scale)
    
    if targetSize.equalTo(CGSize.zero) {
      targetSize = size
    }
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(data: nil, width: Int(targetSize.width * CGFloat(scaleFactor)),
                                  height: Int(targetSize.height * CGFloat(scaleFactor)),
                                  bitsPerComponent: 8,
                                  bytesPerRow: Int(targetSize.width * CGFloat(scaleFactor) * 4),
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue),
      let cgImage = self.cgImage else {
                                    return UIImage()
    }
    
    context.scaleBy(x: scaleFactor, y: scaleFactor)
    
    context.beginPath()
    
    context.addArc(center: CGPoint(x: targetSize.width / 2, y: targetSize.height / 2),
                   radius: targetSize.width / 2, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
    
    context.closePath()
    
    let widthFactor: CGFloat = targetSize.width / size.width
    let heightFactor: CGFloat = targetSize.height / size.height
    
    if widthFactor > heightFactor {
      scaleFactor = widthFactor
    } else {
      scaleFactor = heightFactor
    }
    
    let width: CGFloat = size.width * scaleFactor
    let height: CGFloat = size.height * scaleFactor
    
    context.clip()
    //draw image into bitmap context
    
    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
    
    guard let renderedImage = context.makeImage() else {
      return UIImage()
    }
//    CGContextRelease(context)
    
    let image = UIImage(cgImage: renderedImage, scale: 0, orientation: imageOrientation)
//    CGImageRelease(renderedImage)
    
    return image
  }
}
