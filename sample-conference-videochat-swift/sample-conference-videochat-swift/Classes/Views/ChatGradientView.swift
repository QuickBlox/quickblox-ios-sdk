//
//  ChatGradientView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 5/26/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

class ChatGradientView: UIView {
    
    var isVertical: Bool = true
    
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint.zero
        return layer
    }()
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateGradientFrame()
    }
    
    //MARK: - Public Methods
    func setupGradient(firstColor: UIColor, secondColor: UIColor) {
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        applyGradient()
    }
    
    //MARK: - Internal Methods
    private func applyGradient() {
        updateGradientDirection()
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradientFrame() {
        gradientLayer.frame = bounds
    }
    
    private func updateGradientDirection() {
        gradientLayer.endPoint = isVertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0)
    }
}
