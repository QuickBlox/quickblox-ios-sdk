//
//  ChatCallOutgoingCell.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 5/8/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ChatCallOutgoingCell: ChatCell {
    
    @IBOutlet weak var streamLabel: TTTAttributedLabel!
    @IBOutlet weak var joinButton: UIButton!
    
    /**
     *  Join user to conferense block action.
     */
    var didPressJoinButton: (() -> Void)?
    
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
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        joinButton.setRoundView(cornerRadius: 15.0)
        bubbleImageView.backgroundColor = #colorLiteral(red: 0.2218334079, green: 0.4693790674, blue: 0.9888214469, alpha: 1)
        bubbleImageView.layer.applyShadow(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1), alpha: 0.4, y: 12.0, blur: 12.0)
    }
    
    @IBAction func didTapJoinButton(_ sender: UIButton) {
        didPressJoinButton?()
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
