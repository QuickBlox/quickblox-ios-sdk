//
//  QBButton.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuartzCore

struct QBButtonConstants {
    static let kAnimationLength: CGFloat = 0.15
}

class QBButton: UIButton {
    
    var iconView: UIImageView? {
        willSet {
            if (newValue != self.iconView) {
                iconView?.isUserInteractionEnabled = false
                self.iconView = newValue
                setNeedsDisplay()
            }
        }
        didSet {
           debugPrint("iconView did set")
        }
    }
    
    var pushed = false
    var pressed:Bool = false {
        didSet {
            isHighlighted = pressed
            selectedView.alpha = pressed ? 1.0 : 0.0
        }
    }
    
    var borderColor: UIColor?
    var selectedColor: UIColor?
    var textColor: UIColor?
    
    lazy private var selectedView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.alpha = 0.0
        view.backgroundColor = selectedColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    func commonInit() {
        pressed = false
        isMultipleTouchEnabled = false
        isExclusiveTouch = true
        backgroundColor = nil
        
        setDefaultStyles()
        
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func setDefaultStyles() {
        
        borderColor = UIColor(white: 0.352, alpha: 0.560)
        selectedColor = UIColor(white: 1.000, alpha: 0.600)
        textColor = UIColor.white
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        prepareApperance()
        performLayout()
    }
    
    override func draw(_ rect: CGRect) {
        
        super.draw(rect)
        prepareApperance()
    }
    
    func prepareApperance() {
        
        selectedView.backgroundColor = selectedColor
        layer.borderColor = borderColor?.cgColor
    }
    
    func performLayout() {
        
        selectedView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        addSubview(selectedView)
        
        let maxFrame: CGFloat = max(frame.size.height, frame.size.width) * 0.5
        iconView?.frame = CGRect(x: bounds.midX - (maxFrame / 2.0), y: bounds.midY - (maxFrame / 2.0), width: maxFrame, height: maxFrame)
        
        if iconView != nil {
            addSubview(iconView!)
        }
        layer.cornerRadius = frame.size.height / 2.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>?, with event: UIEvent?) {
        
        if let aTouches = touches, let anEvent = event {
            super.touchesBegan(aTouches, with: anEvent)
        }
        
        weak var weakSelf = self
        UIView.animate(withDuration: TimeInterval(QBButtonConstants.kAnimationLength), delay: 0.0, options: .curveEaseIn, animations: {
            
            weakSelf?.isHighlighted = true
            weakSelf?.selectedView.alpha = 1
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?) {
        
        if let aTouches = touches, let anEvent = event {
            super.touchesEnded(aTouches, with: anEvent)
        }
        weak var weakSelf = self
        
        UIView.animate(withDuration: TimeInterval(QBButtonConstants.kAnimationLength), delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            
            if self.pushed {
                self.pressed = true
            } else {
                
                weakSelf?.isHighlighted = false
                weakSelf?.selectedView.alpha = 0
            }
        })
    }
    
    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                iconView?.isHighlighted = newValue
                iconView?.isHighlighted = newValue
            }
        }
    }

    // MARK: - Default View Methods
    func standardLabel() -> UILabel? {
        
        let label = UILabel(frame: CGRect.zero)
        label.textColor = UIColor.white
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.minimumScaleFactor = 1.0
        
        return label
    }
}
