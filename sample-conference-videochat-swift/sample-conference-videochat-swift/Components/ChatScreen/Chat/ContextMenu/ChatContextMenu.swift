//
//  ContextMenu.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 18.09.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

protocol ChatContextMenu {
    func saveFileAttachment(fromCell cell: ChatAttachmentCell)
}

extension ChatContextMenu {
    func chatContextMenu(forCell cell: ChatAttachmentCell) -> UIMenu {
        let saveAttachmentAction = UIAction(title: "Save Attachment") { action in
            self.saveFileAttachment(fromCell: cell)
        }
        return UIMenu(title: "", children: [saveAttachmentAction])
    }
}
