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
        self.contentMode = UIViewContentMode.redraw
    }
    
    func drawWithRect(rect: CGRect, text:String, fontSize:Float){

        let style = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = NSTextAlignment.center
        
		guard let fontAttributeName = UIFont(name: "Helvetica", size: CGFloat(fontSize)) else {
			return
		}
			
		let rectangleFontAttributes: [String: Any] = [NSFontAttributeName: fontAttributeName,
			NSForegroundColorAttributeName: UIColor.white,
			NSParagraphStyleAttributeName: style]
		
		let rectOffset = rect.offsetBy(dx: 0, dy: ((rect.height - text.boundingRect(with: rect.size, options:.usesLineFragmentOrigin, attributes:rectangleFontAttributes, context: nil).size.height)/2))
		
		NSString(string: text).draw(in: rectOffset, withAttributes: rectangleFontAttributes)
    }
	
    override func draw(_ rect: CGRect) {
        self.drawWithRect(rect: self.bounds, text: self.title, fontSize: self.fontSize)
    }
}
