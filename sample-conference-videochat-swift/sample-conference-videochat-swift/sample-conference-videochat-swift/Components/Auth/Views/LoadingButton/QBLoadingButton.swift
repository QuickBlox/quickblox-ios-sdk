//
//  QBLoadingButton.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class QBLoadingButton: UIButton {

    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    private var activity: UIActivityIndicatorView?
    private var currentText = ""
    
    class func layerClass() -> AnyClass {
        
        return CAShapeLayer.self
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        shapeLayer.fillColor = UIColor(red: 0.0392, green: 0.3765, blue: 1.0, alpha: 1.0).cgColor
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
    }
    
    public func showLoading() {
        
        if activity != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "path")
        
        animation.fromValue = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
        
        animation.repeatCount = 1
        animation.duration = 0.15
        
        let r = min(frame.size.height, frame.size.height)
        animation.toValue = (UIBezierPath(roundedRect: CGRect(x: frame.size.width / 2 - r / 2, y: 0, width: r, height: r), cornerRadius: r)).cgPath
        
        shapeLayer.add(animation, forKey: "shapeAnimation")
        
        shapeLayer.path = (UIBezierPath(roundedRect: CGRect(x: frame.size.width / 2 - r / 2, y: 0, width: r, height: r), cornerRadius: r)).cgPath
        
        showAtivityIndicator()
        currentText = currentTitle ?? "Title"
        setTitle("", for: .normal)
        
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
        
        if !(activity != nil) {
            return
        }
        
        shapeLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 5).cgPath
        shapeLayer.fillColor = UIColor(red: 0.0392, green: 0.3765, blue: 1.0, alpha: 1.0).cgColor
        
        hideActivityIndicator()
        setTitle(currentText, for: .normal)
        currentText = ""
    }
    
    private func showAtivityIndicator() {
        
        if !(activity != nil) {
            
            isUserInteractionEnabled = false
            self.activity = UIActivityIndicatorView(style: .white)
            activity?.isHidden = false
            activity?.startAnimating()
            activity?.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addSubview(activity!)
        }
    }
    
    private func hideActivityIndicator() {
        
        isUserInteractionEnabled = true
        shapeLayer.removeAllAnimations()
        activity?.removeFromSuperview()
        activity = nil
    }
    
    private func setEnabled(_ enabled: Bool) {

        if enabled {
            
            shapeLayer.fillColor = UIColor(red: 0.0392, green: 0.3765, blue: 1.0, alpha: 1.0).cgColor
        } else {
            
            shapeLayer.fillColor = UIColor.gray.cgColor
        }
    }

}
