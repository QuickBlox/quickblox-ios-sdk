//
//  Button.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
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
    
    lazy private var actionButtonLabel: UILabel = {
        let actionButtonLabel = UILabel()
        actionButtonLabel.textColor = .white
        actionButtonLabel.textAlignment = .center
        actionButtonLabel.font = .systemFont(ofSize: 10)
        return actionButtonLabel
    }()
    
    var borderColor = CustomButtonConstants.borderColor
    var selectedColor = CustomButtonConstants.selectedColor
    var unSelectedColor = UIColor.clear
    var selectedTitle = ""
    var unSelectedTitle = "" {
        didSet {
            self.actionButtonLabel.text = unSelectedTitle
        }
    }
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
    
    lazy private var backgroundSelectedView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.alpha = 1.0
        view.backgroundColor = unSelectedColor
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override var isHighlighted: Bool {
        didSet {
            iconView?.isHighlighted = isHighlighted
            self.actionButtonLabel.text = isHighlighted == true ? selectedTitle : unSelectedTitle
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
                        guard let self = self else { return }
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
                        guard let self = self else { return }
                        
                        if self.pushed {
                            self.pressed = !self.pressed
                            self.isHighlighted = self.pressed
                        } else {
                            self.selectedView.alpha = 1.0
                            self.isHighlighted = false
                            self.isHighlighted = self.pressed
                        }
        })
    }
    
    //MARK: - Setup
    private func commonInit() {
        pressed = false
        isMultipleTouchEnabled = false
        isExclusiveTouch = true
        backgroundColor = .clear
    }
    
    //MARK: - Internal Methods
    private func prepareApperance() {
        selectedView.backgroundColor = selectedColor
    }
    
    private func performLayout() {
        let buttonWidth: CGFloat = 56.0
        let maxFrame: CGFloat = buttonWidth / 2.0
        
        addSubview(backgroundSelectedView)
        backgroundSelectedView.translatesAutoresizingMaskIntoConstraints = false
        backgroundSelectedView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        backgroundSelectedView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundSelectedView.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        backgroundSelectedView.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
        backgroundSelectedView.layer.cornerRadius = maxFrame
        
        addSubview(selectedView)
        selectedView.translatesAutoresizingMaskIntoConstraints = false
        selectedView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        selectedView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        selectedView.heightAnchor.constraint(equalToConstant: 56.0).isActive = true
        selectedView.widthAnchor.constraint(equalToConstant: 56.0).isActive = true
        selectedView.layer.cornerRadius = maxFrame
        
        guard let iconView = iconView else { return }
        addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.centerXAnchor.constraint(equalTo: selectedView.centerXAnchor).isActive = true
        iconView.centerYAnchor.constraint(equalTo: selectedView.centerYAnchor).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 28.0).isActive = true
        iconView.widthAnchor.constraint(equalToConstant: 28.0).isActive = true
        
        addSubview(actionButtonLabel)
        actionButtonLabel.translatesAutoresizingMaskIntoConstraints = false
        actionButtonLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        actionButtonLabel.topAnchor.constraint(equalTo: selectedView.bottomAnchor, constant: 8.0).isActive = true
        actionButtonLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        actionButtonLabel.heightAnchor.constraint(equalToConstant: 12.0).isActive = true
    }
}
