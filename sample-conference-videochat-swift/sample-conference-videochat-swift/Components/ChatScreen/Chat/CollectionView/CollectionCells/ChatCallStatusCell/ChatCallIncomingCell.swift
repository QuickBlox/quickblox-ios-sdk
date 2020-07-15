//
//  ChatCallIncomingCell.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 5/8/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class ChatCallIncomingCell: ChatCell {
    
    @IBOutlet weak var streamLabel: TTTAttributedLabel!
    @IBOutlet weak var joinButton: UIButton!
    
    /**
     *  Join user to conferense block action.
     */
    var didPressJoinButton: (() -> Void)?
    
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

        joinButton.setRoundView(cornerRadius: 15.0)
        bubbleImageView.backgroundColor = .white
        layer.applyShadow(color: #colorLiteral(red: 0.8452011943, green: 0.8963350058, blue: 1, alpha: 1), alpha: 1.0, y: 3.0, blur: 48.0)
    }
    
    @IBAction func didTapJoinButton(_ sender: UIButton) {
        didPressJoinButton?()
    }
    
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        let containerInsets = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 12.0, right: 16.0)
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.avatarSize = CGSize(width: 40.0, height: 40.0)
        
        return defaultLayoutModel
    }
}
