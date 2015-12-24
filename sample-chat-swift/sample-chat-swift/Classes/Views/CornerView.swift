//
//  CornerView.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

@IBDesignable
class CornerView: UIView {
    @IBInspectable var title: String = "" { didSet { self.setNeedsDisplay() } }
    @IBInspectable var fontSize: Float = 16 { didSet { self.setNeedsDisplay() } }
    @IBInspectable var cornerRadius:CGFloat = 6 {
        didSet(oldRadius) {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = cornerRadius > 0
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = UIViewContentMode.Redraw
    }
    
    func drawWithRect(rect: CGRect, text:String, fontSize:Float){

        let style = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.alignment = NSTextAlignment.Center
        
        if let fontAttributeName = UIFont(name: "Helvetica", size: CGFloat(fontSize)){
            
            let rectangleFontAttributes: [String: AnyObject] = [NSFontAttributeName: fontAttributeName,
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSParagraphStyleAttributeName: style]
            
            let rectOffset = CGRectOffset(rect, 0, ((CGRectGetHeight(rect) - text.boundingRectWithSize(rect.size, options:.UsesLineFragmentOrigin, attributes:rectangleFontAttributes, context: nil).size.height)/2))
           
            NSString(string: text).drawInRect(rectOffset, withAttributes: rectangleFontAttributes)
        }
    }
    
    override func drawRect(rect: CGRect) {
        self.drawWithRect(self.bounds, text: self.title, fontSize: self.fontSize)
    }
}
