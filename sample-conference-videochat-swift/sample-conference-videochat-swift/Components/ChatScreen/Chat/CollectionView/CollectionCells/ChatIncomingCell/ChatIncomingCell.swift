//
//  ChatIncomingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

/**
 *  Chat message cell typically used for opponent's messages.
 */
class ChatIncomingCell: ChatCell {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let roundingCorners:UIRectCorner = [.topLeft, .topRight, .bottomRight]
        let layer = CAShapeLayer()
        layer.frame = bubbleImageView.layer.bounds
        let bPath = UIBezierPath(roundedRect: bubbleImageView.bounds,
                                 byRoundingCorners: roundingCorners,
                                 cornerRadii: CGSize(width: 20, height: 20))
        layer.path = bPath.cgPath
        bubbleImageView.layer.mask = layer
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        bubbleImageView.backgroundColor = .white
        layer.applyShadow(color: #colorLiteral(red: 0.8452011943, green: 0.8963350058, blue: 1, alpha: 1), alpha: 1.0, y: 3.0, blur: 48.0)
    }
    
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        let containerInsets = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 12.0, right: 16.0)
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.avatarSize = CGSize(width: 40.0, height: 40.0)
        
        return defaultLayoutModel
    }
}
