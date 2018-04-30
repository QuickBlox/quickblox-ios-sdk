//
//  ToolbarButton.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vitaliy Gorbachov on 4/23/18.
//  Copyright © 2018 Quickblox. All rights reserved.
//

import UIKit
import QuartzCore

class ToolbarButton: UIButton {
    
    let kAnimationLength = 0.15
    
    var borderColor: UIColor!
    var selectedColor: UIColor!
    var textColor: UIColor!
    
    var isPushed: Bool?
    var pressed: Bool = false {
        didSet {
            self.isHighlighted = self.pressed
            self.iconView?.isHighlighted = self.pressed
            self.selectedView.alpha = CGFloat(truncating: NSNumber(value: self.pressed))
        }
    }
    
    var iconView: UIImageView? {
        didSet {
            self.iconView?.isUserInteractionEnabled = false
            self.setNeedsDisplay()
        }
    }
    
    private var selectedView: UIView!

    func commonInit() {
        self.isMultipleTouchEnabled = false
        self.isExclusiveTouch = true
        self.backgroundColor = nil
        
        self.borderColor = UIColor.init(white: 0.352, alpha: 0.560)
        self.selectedColor = UIColor.init(white: 1.000, alpha: 0.600)
        self.textColor = UIColor.white
        
        self.clipsToBounds = true
        
        self.selectedView = UIView.init(frame: CGRect.zero)
        self.selectedView.alpha = 0.0
        self.selectedView.backgroundColor = self.selectedColor
        self.selectedView.isUserInteractionEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.prepareAppearance()
        self.performLayout()
    }
    
    func prepareAppearance() {
        self.selectedView.backgroundColor = self.selectedColor
        self.layer.borderColor = self.borderColor.cgColor
    }
    
    func performLayout() {
        
        self.selectedView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        self.addSubview(self.selectedView)
        
        let maxV = max(self.frame.size.height, self.frame.size.width) * 0.5
        self.iconView?.frame = CGRect.init(x: self.bounds.midX - (maxV / 2.0), y: self.bounds.midY - (maxV / 2.0), width: maxV, height: maxV)
        if self.iconView != nil {
            self.addSubview(self.iconView!)
        }
        
        self.layer.cornerRadius = self.frame.size.height / 2.0;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: kAnimationLength, delay: 0, options: .curveEaseIn, animations: {
            self.isHighlighted = true
            self.iconView?.isHighlighted = true
            self.selectedView.alpha = 1
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: kAnimationLength, delay: 0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            if self.isPushed! {
                
                self.pressed = !self.pressed
            }
            else {
                self.isHighlighted = false
                self.iconView?.isHighlighted = false
                self.selectedView.alpha = 0
            }
        })
    }
}
