//
//  ChatContainerView.swift
//  Swift-ChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/12/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

/**
 *  Customisable chat container view.
 */
class ChatContainerView: UIView {
  
  @IBInspectable var bgColor: UIColor = UIColor.white {
    didSet {
      if let bubleImg = ChatContainerView.bubleImage(withArrowSize: arrowSize, fill: bgColor,
                                                       cornerRadius: Int(cornerRadius),
                                                       leftArrow: leftArrow) {
        preview.image = bubleImg
      }
    }
  }
  
  @IBInspectable var highlightColor: UIColor = .white {
    didSet {
      if let bubleImg = ChatContainerView.bubleImage(withArrowSize: arrowSize, fill: highlightColor,
                                                       cornerRadius: Int(cornerRadius),
                                                       leftArrow: leftArrow) {
        preview.highlightedImage = bubleImg
      }
    }
  }
  
  @IBInspectable var cornerRadius: CGFloat = 0.0
  @IBInspectable var arrow = false
  @IBInspectable var leftArrow = false
  @IBInspectable var arrowSize = CGSize.zero
  
  var highlighted = false {
    didSet {
      preview.alpha = highlighted ? 0.6 : 1
    }
  }
  
  private var backgroundImage: UIImage {
    get {
      guard let previewImage = preview.image else {
        return UIImage()
        
      }
      return previewImage
    }
  }
  
  lazy private var preview: UIImageView = {
    let preview = UIImageView()
    return preview
  }()
  lazy private var maskPath: UIBezierPath = {
    let maskPath = UIBezierPath()
    return maskPath
  }()
  
  static var images: [String: UIImage] = [:]
  
  class func bubleImage(withArrowSize arrowSize: CGSize, fill fillColor: UIColor,
                        cornerRadius: Int, leftArrow: Bool) -> UIImage? {
    var cornerRadius = cornerRadius
    
    let identifier = String(format: "%@_%tu_%tu_%d", NSCoder.string(for: arrowSize),
                            fillColor.hash,
                            cornerRadius, leftArrow)
    
    var img = images[identifier]
    cornerRadius = min(cornerRadius, 10)
    let space = Int(leftArrow ? arrowSize.width : 0)
    let leftCap = Float(space + cornerRadius + 1)
    let topCap = Float(cornerRadius)
    
    let size = CGSize(width: arrowSize.width + CGFloat((space + cornerRadius * 2)) + 2,
                      height: CGFloat(cornerRadius * 2) + arrowSize.height)
    
    if img != nil {
      return img
    }
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    
    fillColor.setFill()
    
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    let arrow = (arrowSize.width + arrowSize.height) == 0.0 ? false : true
    
    var rectanglePath = UIBezierPath()
    if !arrow {
      
      rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: CGFloat(cornerRadius))
    } else {
      
      let x: CGFloat = leftArrow ? arrowSize.width : rect.minX
      let y = rect.minY
      let w = rect.width
      let h = rect.height
      //// Subframes
      let arrowRect = CGRect(x: leftArrow ? 0 : x + w - arrowSize.width,
                             y: y + h - arrowSize.height, width: arrowSize.width, height: arrowSize.height)
      //// Rectangle Drawing
      let bottomRoundedCorner = leftArrow ? UIRectCorner.bottomRight : UIRectCorner.bottomLeft
      let roundedRect = CGRect(x: x, y: y, width: w - arrowSize.width, height: h)
      let roundingCorners = UIRectCorner.topLeft.union(.topRight).union(bottomRoundedCorner)
      let cornerRadii = CGSize(width: CGFloat(cornerRadius), height: CGFloat(cornerRadius))
      rectanglePath = UIBezierPath(roundedRect: roundedRect,
                                   byRoundingCorners: roundingCorners,
                                   cornerRadii: cornerRadii)
      
      rectanglePath.move(to: CGPoint(x: arrowRect.maxX + arrowSize.width, y: arrowRect.maxY))
      rectanglePath.addLine(to: CGPoint(x: arrowRect.maxX, y: arrowRect.maxY))
    }
    rectanglePath.fill()
    img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    if let img = img?.stretchableImage(withLeftCapWidth: Int(leftCap), topCapHeight: Int(topCap)) {
      images[identifier] = img
    }
    return img
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    isOpaque = true
    preview = UIImageView(frame: bounds)
    preview.isUserInteractionEnabled = true
    preview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    let bubleImg = ChatContainerView.bubleImage(withArrowSize: arrowSize, fill: bgColor,
                                                  cornerRadius: Int(cornerRadius), leftArrow: leftArrow)
    preview.image = bubleImg
    preview.highlightedImage = bubleImg
    insertSubview(preview, at: 0)
  }
}
