//
//  CircularProgressBar.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/8/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

class CircularProgressBar: UIView {
    
    let shapeLayer = CAShapeLayer()
    private var pathCenter: CGPoint{get{ return self.convert(self.center, from:self.superview)}}
    
    //MARK: awakeFromNib
    override func awakeFromNib() {
    super.awakeFromNib()

        let circularPath = UIBezierPath(arcCenter: .zero, radius: 25, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor(named: "AppColor")?.cgColor
        shapeLayer.lineWidth = 6
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        shapeLayer.position = pathCenter
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        layer.insertSublayer(shapeLayer, at:0)
    }

    //MARK: Public
    public func setProgress(to progressConstant: CGFloat) {
        shapeLayer.strokeEnd = progressConstant
    }
}
