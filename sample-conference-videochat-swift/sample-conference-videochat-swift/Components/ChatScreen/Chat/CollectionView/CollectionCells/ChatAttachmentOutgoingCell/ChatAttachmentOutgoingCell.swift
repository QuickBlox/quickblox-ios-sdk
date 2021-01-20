//
//  ChatAttachmentOutgoingCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class ChatAttachmentOutgoingCell: ChatAttachmentCell {
    override func awakeFromNib() {
        super.awakeFromNib()

        previewContainer.roundCorners(radius: 6, isIncoming: false)
    }
}
