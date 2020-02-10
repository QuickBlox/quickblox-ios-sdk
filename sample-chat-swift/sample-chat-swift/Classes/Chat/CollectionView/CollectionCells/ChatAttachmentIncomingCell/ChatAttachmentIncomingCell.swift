//
//  ChatAttachmentIncomingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatAttachmentIncomingCell: ChatAttachmentCell {
    
    override class func layoutModel() -> ChatCellLayoutModel {
           var defaultLayoutModel = super.layoutModel()
           let containerInsets = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
           defaultLayoutModel.containerInsets = containerInsets
           defaultLayoutModel.avatarSize = CGSize(width: 40.0, height: 40.0)
           
           return defaultLayoutModel
       }
}
