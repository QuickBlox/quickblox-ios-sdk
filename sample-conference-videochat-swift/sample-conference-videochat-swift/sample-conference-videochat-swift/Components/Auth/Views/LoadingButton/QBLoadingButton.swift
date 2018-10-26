//
//  QBLoadingButton.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class QBLoadingButton: UIButton {
    
    var path: UIBezierPath!

    lazy private var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        return shapeLayer
    }()
    lazy private var activity: UIActivityIndicatorView = {
        let activity = UIActivityIndicatorView(style: .white)
        activity.hidesWhenStopped = true
        return activity
    }()
    private var currentText = ""
    
    class func layerClass() -> AnyClass {
        return CAShapeLayer.self
    }
    override var isEnabled: Bool{
        didSet {
            updateEnabled(isEnabled)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isEnabled = false
        setTitle(currentText, for: .normal)
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
        layer.addSublayer(shapeLayer)
    }

    public func showLoading() {
        if activity.isAnimating {
            return
        }
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
        animation.repeatCount = 1
        animation.duration = 0.15
        let r = min(frame.size.height, frame.size.height)
        animation.toValue = (UIBezierPath(roundedRect: CGRect(x: frame.size.width / 2 - r / 2,
                                                              y: 0, width: r, height: r),
                                          cornerRadius: r)).cgPath
        shapeLayer.add(animation, forKey: "shapeAnimation")
        shapeLayer.path = (UIBezierPath(roundedRect: CGRect(x: frame.size.width / 2 - r / 2,
                                                            y: 0, width: r, height: r),
                                        cornerRadius: r)).cgPath
        
        showAtivityIndicator()
        currentText = self.currentTitle ?? "Title"
        self.setTitle("", for: .normal)
        
        let fromColor = UIColor(red: 0.0392, green: 0.3765, blue: 1.0, alpha: 1.0)
        let toColor = UIColor(red: 0.0802, green: 0.616, blue: 0.1214, alpha: 1.0)
        
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = fromColor.cgColor
        colorAnimation.toValue = toColor.cgColor
        colorAnimation.repeatCount = Float(NSIntegerMax)
        colorAnimation.duration = 1.0
        colorAnimation.autoreverses = true
        
        shapeLayer.add(colorAnimation, forKey: "color")
    }
    
    public func hideLoading() {
        if activity.isAnimating == false {
            return
        }
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
        shapeLayer.fillColor = UIColor(red: 0.0392, green: 0.3765, blue: 1.0, alpha: 1.0).cgColor
        
        hideActivityIndicator()
        self.setTitle(currentText, for: .normal)
        currentText = ""
    }
    
    private func showAtivityIndicator() {
        if activity.isAnimating == false {
            isUserInteractionEnabled = false
            activity.isHidden = false
            activity.startAnimating()
            activity.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addSubview(activity)
        }
    }
    
    private func hideActivityIndicator() {
        isUserInteractionEnabled = true
        shapeLayer.removeAllAnimations()
        activity.removeFromSuperview()
    }
    
    private func updateEnabled(_ enabled: Bool) {
        if enabled {
            shapeLayer.fillColor = UIColor(red: 0.0392, green: 0.3765, blue: 1.0, alpha: 1.0).cgColor
        } else {
            shapeLayer.fillColor = UIColor.gray.cgColor
        }
    }
}
