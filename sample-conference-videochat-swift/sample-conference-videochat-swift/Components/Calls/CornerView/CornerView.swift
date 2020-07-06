//
//  CornerView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

struct CornerViewConstant {
    static let fontName = "Helvetica"
}

class CornerView: UIView {
    //MARK: - Properties
    var bgColor = UIColor.clear {
        didSet {
            setNeedsDisplay()
        }
    }
    var title: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    var cornerRadius: CGFloat = 6.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var fontSize: CGFloat = 16.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    var touchesEndAction: (() -> Void)?
    
    //MARK: - Life Cycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        defaultStyle()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultStyle()
    }
    
    //MARK: - Overrides
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        draw(withBgColor: bgColor, cornerRadius: cornerRadius, rect: bounds, text: title, fontSize: fontSize)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if let touches = touches, let event = event {
            super.touchesEnded(touches, with: event)
        }
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction],
                       animations: {
        }) { finished in
            guard let touchesEndAction = self.touchesEndAction else {
                return
            }
            touchesEndAction()
        }
    }
    
    //MARK: - Internal Methods
    private func defaultStyle() {
        contentMode = .redraw
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = false
    }
    
    private func draw(withBgColor bgColor: UIColor, cornerRadius: CGFloat, rect: CGRect, text: String,
              fontSize: CGFloat) {
        let rectanglePath = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        bgColor.setFill()
        rectanglePath.fill()
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let rectangleFontAttributes = [NSAttributedString.Key.font: UIFont(name: CornerViewConstant.fontName,
                                                                           size: fontSize),
                                       NSAttributedString.Key.foregroundColor: UIColor.white,
                                       NSAttributedString.Key.paragraphStyle: style]
        let attributes = rectangleFontAttributes as [NSAttributedString.Key : Any]
        let offsetByY = (rect.height - (text.boundingRect(with: rect.size,
                                                          options: .usesLineFragmentOrigin,
                                                          attributes: attributes, context: nil).size.height))
        let rectOffset: CGRect = rect.offsetBy(dx: 0.0, dy: offsetByY / 2)
        text.draw(in: rectOffset, withAttributes: attributes)
    }
}
