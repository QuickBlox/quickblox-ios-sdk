//
//  CornerView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class CornerView: UIView {
    
    var bgColor: UIColor? {
        willSet {
            
            if !(self.bgColor == newValue) {
                self.bgColor = newValue
                setNeedsDisplay()
            }
        }
    }
    
    var title: String = "" {
        willSet {
        if !(self.title == newValue) {
            self.title = newValue
            setNeedsDisplay()
            }
        }
    }
    
    var cornerRadius: CGFloat = 0.0 {
        willSet {
            
            if self.cornerRadius != newValue {
                self.cornerRadius = newValue
                setNeedsDisplay()
            }
        }
    }
    
    var fontSize: CGFloat = 0.0 {
        willSet {
            
            if self.fontSize != newValue {
                self.fontSize = newValue
                setNeedsDisplay()
            }
        }
    }
    
    var touchesEndAction: (() -> Void)?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        
        defaultStyle()
        
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        
        defaultStyle()
        
    }
    
    func defaultStyle() {
        
        contentMode = .redraw
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
        
        bgColor = UIColor.clear
        cornerRadius = 6
        fontSize = 16
    }
    
    func draw(withBgColor bgColor: UIColor?, cornerRadius: CGFloat, rect: CGRect, text: String?, fontSize: CGFloat) {
        
        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        bgColor?.setFill()
        rectanglePath.fill()
        
        let style = NSMutableParagraphStyle.default as? NSMutableParagraphStyle
        style?.alignment = .center
        
        let rectangleFontAttributes = [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: fontSize), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.paragraphStyle: style]
        
        let rectOffset: CGRect = rect.offsetBy(dx: 0, dy: (rect.height - (text?.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, attributes: rectangleFontAttributes as [NSAttributedString.Key : Any], context: nil).size.height ?? 0.0)) / 2)
        text?.draw(in: rectOffset, withAttributes: rectangleFontAttributes as [NSAttributedString.Key : Any])
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        
        draw(withBgColor: bgColor, cornerRadius: cornerRadius, rect: bounds, text: title, fontSize: fontSize)
    }
    
    // MARK: - Action
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?) {
        
        if let aTouches = touches, let anEvent = event {
            super.touchesEnded(aTouches, with: anEvent)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            
        }) { finished in
            
            if (self.touchesEndAction != nil) {
                
                self.touchesEndAction!()
            }
        }
    }
}
