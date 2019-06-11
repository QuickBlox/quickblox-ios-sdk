//
//  ChatOutgoingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatOutgoingCell: ChatCell {
    
    override class func layoutModel() -> ChatCellLayoutModel {
        let containerInsets = UIEdgeInsets(top: 8.0, left: 10.0, bottom: 8.0, right: 18.0)
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.topLabelHeight = 0.0
        defaultLayoutModel.spaceBetweenTextViewAndBottomLabel = 0.0
        defaultLayoutModel.bottomLabelHeight = 14.0
        
        return defaultLayoutModel
    }
}
