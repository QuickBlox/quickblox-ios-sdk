//
//  CornerView.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class CornerView: UIView {
    var title: String = ""
    private var fontSize: Float = 16
    var cornerRadius:CGFloat = 6
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func drawWithRect(rect: CGRect, text:String, fontSize:Float){

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        
		guard let fontAttributeName = UIFont(name: "Helvetica", size: CGFloat(fontSize)) else {
			return
		}
			
        let rectangleFontAttributes: [NSAttributedString.Key: Any] = [.font: fontAttributeName,
                                                                      .foregroundColor: UIColor.white,
                                                                      .paragraphStyle: style]
		
		let rectOffset = rect.offsetBy(dx: 0, dy: ((rect.height - text.boundingRect(with: rect.size, options:.usesLineFragmentOrigin, attributes:rectangleFontAttributes, context: nil).size.height)/2))
		
		NSString(string: text).draw(in: rectOffset, withAttributes: rectangleFontAttributes)
    }
	
    override func draw(_ rect: CGRect) {
        drawWithRect(rect: bounds, text: title, fontSize: fontSize)
    }
}
