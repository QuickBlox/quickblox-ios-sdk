//
//  ChatOutgoingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatOutgoingCell: ChatCell {
//    @IBOutlet weak var shadowView: UILabel!
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let roundingCorners:UIRectCorner = [.bottomLeft, .topLeft, .topRight]
        let layer = CAShapeLayer()
        layer.frame = bubbleImageView.layer.bounds
        let bPath = UIBezierPath(roundedRect: bubbleImageView.bounds,
                                 byRoundingCorners: roundingCorners,
                                 cornerRadii: CGSize(width: 20, height: 20))
        layer.path = bPath.cgPath
        bubbleImageView.layer.mask = layer
//
        bubbleImageView.clipsToBounds = false
        bubbleImageView.layer.masksToBounds = false
//        let shadowView = UILabel()
//        shadowView.backgroundColor = .clear
//        containerView.addSubview(shadowView)
//        containerView.bringSubviewToFront(bubbleImageView)
//        shadowView.translatesAutoresizingMaskIntoConstraints = false
//        shadowView.leftAnchor.constraint(equalTo: bubbleImageView.leftAnchor).isActive = true
//        shadowView.topAnchor.constraint(equalTo: bubbleImageView.topAnchor).isActive = true
//        shadowView.rightAnchor.constraint(equalTo: bubbleImageView.rightAnchor).isActive = true
//        shadowView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor).isActive = true
//        shadowView.backgroundColor = .white
        
//        shadowView.setRoundedLabel(cornerRadius: 20.0)
        bubbleImageView.layer.applyShadow(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1), alpha: 0.4, y: 12.0, blur: 12.0)
//        let shadowPath = UIBezierPath()
//        shadowPath.move(to: CGPoint(x: bubbleImageView.bounds.origin.x, y: bubbleImageView.frame.size.height))
//        shadowPath.addLine(to: CGPoint(x: bubbleImageView.bounds.width / 2, y: bubbleImageView.bounds.height + 7.0))
//        shadowPath.addLine(to: CGPoint(x: bubbleImageView.bounds.width, y: bubbleImageView.bounds.height))
//        shadowPath.close()
//
//        bubbleImageView.clipsToBounds = false
//        bubbleImageView.layer.shadowColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1).cgColor
//        bubbleImageView.layer.shadowOpacity = 0.4
//        bubbleImageView.layer.masksToBounds = false
//        bubbleImageView.layer.shadowPath = shadowPath.cgPath
//        bubbleImageView.layer.shadowRadius = 5
//      let path = UIBezierPath(rect: layer.frame)
//        bubbleImageView.layer.applyShadow(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1), alpha: 0.4, y: 12.0, blur: 12.0, path: bPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        bubbleImageView.backgroundColor = #colorLiteral(red: 0.2218334079, green: 0.4693790674, blue: 0.9888214469, alpha: 1)
//        let shadowView = UILabel()
//        bubbleImageView.addSubview(shadowView)
//        shadowView.translatesAutoresizingMaskIntoConstraints = false
//        shadowView.leftAnchor.constraint(equalTo: bubbleImageView.leftAnchor).isActive = true
//        shadowView.topAnchor.constraint(equalTo: bubbleImageView.topAnchor).isActive = true
//        shadowView.rightAnchor.constraint(equalTo: bubbleImageView.rightAnchor).isActive = true
//        shadowView.bottomAnchor.constraint(equalTo: bubbleImageView.bottomAnchor).isActive = true
//        shadowView.backgroundColor = .white
//
//        shadowView.setRoundedLabel(cornerRadius: 20.0)
//        shadowView.layer.applyShadow(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1), alpha: 0.4, y: 12.0, blur: 12.0)
    }
    
    override class func layoutModel() -> ChatCellLayoutModel {
        let containerInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 12.0, right: 14.0)
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.timeLabelHeight = 15.0
        defaultLayoutModel.spaceBetweenTopLabelAndTextView = 12.0
        
        return defaultLayoutModel
    }
}
