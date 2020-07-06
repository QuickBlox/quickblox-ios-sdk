//
//  LoadingButton.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct LoadingButtonColorConstant {
    static let blueColor = UIColor(red:0.22, green:0.47, blue:0.99, alpha:1)
    static let greenColor = UIColor(red: 0.0802, green: 0.616, blue: 0.1214, alpha: 1.0)
    static let grayColor = #colorLiteral(red: 0.6628920436, green: 0.7223827243, blue: 0.8180354238, alpha: 1)
}

class LoadingButton: UIButton {
    
    //MARK: - Properties
    lazy private var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        return shapeLayer
    }()
    
    lazy private var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .white)
        activity.hidesWhenStopped = true
        return activity
    }()
    
    var isAnimating: Bool {
        return activity.isAnimating
    }
    
    private var currentText = "Login"
    
    override var isEnabled: Bool{
        didSet {
            if isEnabled == true {
                shapeLayer.fillColor = LoadingButtonColorConstant.blueColor.cgColor
                addShadowToButton(cornerRadius: 4)
            } else {
                shapeLayer.fillColor = LoadingButtonColorConstant.grayColor.cgColor
                removeShadowFromButton()
            }
        }
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isEnabled = false
        setTitle(currentText, for: .normal)
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
        layer.addSublayer(shapeLayer)
        activity.stopAnimating()
    }
    
    // MARK: - Public Methods
    func showLoading() {
        
        guard activity.isAnimating == false else {
            return
        }
        
        removeShadowFromButton()
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
        animation.repeatCount = 1
        animation.duration = 0.15
        let cornerRadius = min(frame.size.height, frame.size.height)
        let roundedRect = CGRect(x: frame.size.width / 2.0 - cornerRadius / 2.0,
                                 y: 0.0, width: cornerRadius, height: cornerRadius)
        let path = (UIBezierPath(roundedRect: roundedRect,
                                 cornerRadius: cornerRadius)).cgPath
        animation.toValue = path
        shapeLayer.add(animation, forKey: "shapeAnimation")
        shapeLayer.path = path
        
        isUserInteractionEnabled = false
        activity.isHidden = false
        activity.startAnimating()
        activity.center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        addSubview(activity)
        
        currentText = currentTitle ?? "Title"
        setTitle("", for: .normal)
        
        let fromColor = LoadingButtonColorConstant.blueColor
        let toColor = LoadingButtonColorConstant.greenColor
        
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = fromColor.cgColor
        colorAnimation.toValue = toColor.cgColor
        colorAnimation.repeatCount = Float(NSIntegerMax)
        colorAnimation.duration = 1.0
        colorAnimation.autoreverses = true
        
        shapeLayer.add(colorAnimation, forKey: "color")
    }
    
    func hideLoading() {
        guard activity.isAnimating == true else {
            return
        }
        activity.stopAnimating()
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5.0).cgPath
        shapeLayer.fillColor = LoadingButtonColorConstant.blueColor.cgColor
        
        isUserInteractionEnabled = true
        shapeLayer.removeAllAnimations()
        activity.removeFromSuperview()
        
        setTitle(currentText, for: .normal)
        currentText = ""
    }
}
