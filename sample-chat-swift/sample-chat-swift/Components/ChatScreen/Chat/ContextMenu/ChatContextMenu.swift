//
//  ContextMenu.swift
//  sample-chat-swift
//
//  Created by Injoit on 18.09.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation

protocol ChatContextMenu {
    func forwardAction()
    func deliveredToAction()
    func viewedByAction()
    func saveFileAttachment(fromCell cell: ChatAttachmentCell)
}

extension ChatContextMenu {
    func chatContextMenu(forSender isSender: Bool, forCell cell: ChatAttachmentCell? = nil) -> UIMenu {
        if let chatAttachmentCell = cell {
            let saveAttachmentAction = UIAction(title: "Save Attachment") { action in
                self.saveFileAttachment(fromCell: chatAttachmentCell)
            }
            return UIMenu(title: "", children: [saveAttachmentAction])
        }
        
        let forwardAction = UIAction(title: "Forward") { action in
            self.forwardAction()
        }
        let deliveredToAction = UIAction(title: "Delivered to...") { action in
            self.deliveredToAction()
        }
        let viewedByAction = UIAction(title: "Viewed by...") { action in
            self.viewedByAction()
        }
        
        let children = isSender == true ? [forwardAction, deliveredToAction, viewedByAction] : [forwardAction]
        
        return UIMenu(title: "", children: children)
    }
}
