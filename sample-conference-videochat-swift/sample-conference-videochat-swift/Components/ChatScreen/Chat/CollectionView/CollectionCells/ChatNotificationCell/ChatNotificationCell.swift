//
//  ChatNotificationCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatNotificationCell: ChatCell {
    @IBOutlet weak var notificationLabel: UILabel!
    
    override class func layoutModel() -> ChatCellLayoutModel {
        let containerInsets = UIEdgeInsets(top: 4.0, left: 10.0, bottom: 4.0, right: 10.0)
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.containerInsets = containerInsets
        defaultLayoutModel.avatarSize = .zero
        defaultLayoutModel.timeLabelHeight = 0.0
        
        return defaultLayoutModel
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notificationLabel.backgroundColor = .clear
    }
}
