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
    @IBInspectable override var backgroundColor: UIColor? { didSet { self.setNeedsDisplay() } }
    @IBInspectable var title: String = "" { didSet { self.setNeedsDisplay() } }
    @IBInspectable var fontSize: Float = 16 { didSet { self.setNeedsDisplay() } }
    @IBInspectable var cornerRadius:Float = 6 {
        didSet(oldRadius) {
            if oldRadius < 0 {
                cornerRadius = 0
            }
            else {
                self.setNeedsDisplay()
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = UIViewContentMode.Redraw
    }
    
    func drawWithCornerRadius(cornerRadius: CGFloat, rect: CGRect, text:String, fontSize:Float){
        var rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        self.backgroundColor!.setFill()
        rectanglePath.fill()
        
        let style = NSMutableParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.alignment = NSTextAlignment.Center
        
        
        if let fontAttributeName = UIFont(name: "Helvetica", size: CGFloat(fontSize)){
            
            let rectangleFontAttributes: Dictionary<NSString, AnyObject> = [NSFontAttributeName: fontAttributeName,
                NSForegroundColorAttributeName: UIColor.whiteColor(),
                NSParagraphStyleAttributeName: style]
            
            var rectOffset = CGRectOffset(rect, 0, ((CGRectGetHeight(rect) - text.boundingRectWithSize(rect.size, options:.UsesLineFragmentOrigin, attributes:rectangleFontAttributes, context: nil).size.height)/2))
           
            NSString(string: text).drawInRect(rectOffset, withAttributes: rectangleFontAttributes)
        }
    }
    
    override func drawRect(rect: CGRect) {
        self.drawWithCornerRadius(CGFloat(self.cornerRadius), rect: self.bounds, text: self.title, fontSize: self.fontSize)
    }
    
    
}
