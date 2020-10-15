//
//  ChatOutgoingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatOutgoingCell: ChatCell {
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        previewContainer.backgroundColor = #colorLiteral(red: 0.2218334079, green: 0.4693790674, blue: 0.9888214469, alpha: 1)
        layer.applyShadow(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1), alpha: 0.4, y: 12.0, blur: 12.0)
    }
    
    override class func layoutModel() -> ChatCellLayoutModel {
        let containerInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 12.0, right: 16.0)
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.timeLabelHeight = 15.0
        defaultLayoutModel.spaceBetweenTopLabelAndTextView = 12.0
        
        return defaultLayoutModel
    }
    
    override func layoutSubviews() {
        let roundingCorners:UIRectCorner = [.bottomLeft, .topLeft, .topRight]
        let layer = CAShapeLayer()
        layer.frame = previewContainer.layer.bounds
        let bPath = UIBezierPath(roundedRect: previewContainer.bounds,
                                 byRoundingCorners: roundingCorners,
                                 cornerRadii: CGSize(width: 20, height: 20))
        layer.path = bPath.cgPath
        previewContainer.layer.mask = layer
    }
    
    func setupStatusImage(_ image: UIImage) {
        statusImageView.image = image
    }
}
