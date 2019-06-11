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
  
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        let containerInsets = UIEdgeInsets(top: 8.0, left: 18.0, bottom: 8.0, right: 10.0)
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.avatarSize = CGSize(width: 44.0, height: 45.0)
        return defaultLayoutModel
    }
}
