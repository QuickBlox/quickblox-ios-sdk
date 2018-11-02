//
//  Button.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuartzCore

struct CustomButtonConstants {
    static let animationLength: CGFloat = 0.15
    static let borderColor = UIColor(white: 0.352, alpha: 0.560)
    static let selectedColor = UIColor(white: 1.000, alpha: 0.600)
}

class CustomButton: UIButton {
    //MARK: - Properties
    var iconView: UIImageView? {
        willSet {
            if (newValue != self.iconView) {
                iconView?.isUserInteractionEnabled = false
                self.iconView = newValue
                setNeedsDisplay()
            }
        }
    }
    
    var borderColor = CustomButtonConstants.borderColor
    var selectedColor = CustomButtonConstants.selectedColor
    var pushed = false
    var pressed:Bool = false {
        didSet {
            isHighlighted = pressed
            selectedView.alpha = pressed ? 1.0 : 0.0
        }
    }
    
    lazy private var selectedView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.alpha = 0.0
        view.backgroundColor = selectedColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override var isHighlighted: Bool {
        didSet {
            iconView?.isHighlighted = isHighlighted
        }
    }
    
    //MARK: - Life Cycle
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
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
    
    //MARK: - UIResponder
    override func touchesBegan(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if let touches = touches, let event = event {
            super.touchesBegan(touches, with: event)
        }

        UIView.animate(withDuration: TimeInterval(CustomButtonConstants.animationLength),
                       delay: 0.0,
                       options: .curveEaseIn,
                       animations: { [weak self] in
                        guard let `self` = self else { return }
                        self.isHighlighted = true
                        self.selectedView.alpha = 1.0
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if let touches = touches, let event = event {
            super.touchesEnded(touches, with: event)
        }
        
        UIView.animate(withDuration: TimeInterval(CustomButtonConstants.animationLength),
                       delay: 0.0,
                       options: [.curveEaseIn, .allowUserInteraction],
                       animations: { [weak self] in
                        guard let `self` = self else { return }
                        
                        if self.pushed {
                            self.pressed = !self.pressed
                        } else {
                            self.isHighlighted = false
                            self.selectedView.alpha = 0.0
                        }
        })
    }
    
    //MARK: - Setup
    private func commonInit() {
        pressed = false
        isMultipleTouchEnabled = false
        isExclusiveTouch = true
        backgroundColor = nil
        clipsToBounds = true
    }
    
    //MARK: - Internal Methods
    private func prepareApperance() {
        selectedView.backgroundColor = selectedColor
        layer.borderColor = borderColor.cgColor
    }
    
    private func performLayout() {
        selectedView.frame = CGRect(x: 0.0, y: 0.0, width: frame.size.width, height: frame.size.height)
        addSubview(selectedView)
        
        guard let iconView = iconView else { return }
        let maxFrame: CGFloat = max(frame.size.height, frame.size.width) * 0.5
        let roundedRect = CGRect(x: bounds.midX - (maxFrame / 2.0),
                                 y: bounds.midY - (maxFrame / 2.0),
                                 width: maxFrame,
                                 height: maxFrame)
        iconView.frame = roundedRect
        addSubview(iconView)
        layer.cornerRadius = frame.size.height / 2.0
    }
}
