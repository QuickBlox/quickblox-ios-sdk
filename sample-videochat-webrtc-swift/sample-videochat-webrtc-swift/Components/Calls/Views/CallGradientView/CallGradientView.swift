//
//  CallGradientView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 5/26/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

class CallGradientView: UIView {
    //MARK: - Properties
    lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.startPoint = CGPoint.zero
        layer.endPoint = CGPoint(x: 0, y: 1)
        return layer
    }()
    
    //MARK: - Life Cycle
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
    
    //MARK: - Private Methods
    private func applyGradient() {
        gradientLayer.frame = bounds
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func updateGradientFrame() {
        gradientLayer.frame = bounds
    }
}
