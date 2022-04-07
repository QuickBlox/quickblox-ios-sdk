//
//  QBChatMessage+Extension.swift
//  sample-chat-swift
//
//  Created by Injoit on 29.01.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import Foundation

extension QBChatMessage {
    func messageText() -> NSAttributedString {
        guard let text = self.text  else {
            return NSAttributedString(string: "@")
        }
        let currentUserID = Profile().ID
        let textColor = self.senderID == currentUserID ? UIColor.white : .black
        
        let font = UIFont(name: "Helvetica", size: 15)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any]
        if isForwardedMessage,
           let forwardedText = forwardedText() {
            let textForwarded = NSMutableAttributedString(attributedString: forwardedText)
            textForwarded.append(NSAttributedString(string: text, attributes: attributes))
            return textForwarded
        }
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func topLabelText() -> NSAttributedString {
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byClipping
        let color = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)
        let font = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        var topLabelString = ""
        if self.senderID == Profile().ID {
            topLabelString = "You"
        } else {
            if let fullName = ChatManager.instance.storage.user(withID: self.senderID)?.fullName {
                topLabelString = fullName
            }
        }
        
        return NSAttributedString(string: topLabelString, attributes: attributes)
    }
    
    func timeLabelText() -> NSAttributedString {
        let textColor = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byWordWrapping
        let font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        guard let dateSent = self.dateSent else {
            return NSAttributedString(string: "")
        }
        let text = messageTimeDateFormatter.string(from: dateSent)
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func statusImage() -> UIImage {
        //check and add users who read the message
        let currentUserID = Profile().ID
        if let readIDs = self.readIDs?.filter({ $0.uintValue != currentUserID }),
           readIDs.isEmpty == false {
            return #imageLiteral(resourceName: "delivered").withTintColor(#colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1))
        }
        //check and add users to whom the message was delivered
        if let deliveredIDs = self.deliveredIDs?.filter({ $0 != NSNumber(value: currentUserID) }),
           deliveredIDs.isEmpty == false  {
            return #imageLiteral(resourceName: "delivered")
        }
        return UIImage(named: "sent")!
    }
    
    func forwardedText() -> NSAttributedString? {
        let currentUserID = Profile().ID
        guard let originForwardedName = customParameters[Key.forwardedMessage] as? String else {
            return nil
        }
        var forwardedColor = self.senderID == currentUserID ? UIColor.white : .black
        if isAttachmentMessage == true {
            forwardedColor = #colorLiteral(red: 0.4091697037, green: 0.4803909063, blue: 0.5925986171, alpha: 1)
        }
        let fontForwarded = UIFont.systemFont(ofSize: 13, weight: .light)
        let fontForwardedName = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let attributesForwarded: [NSAttributedString.Key: Any] = [.foregroundColor: forwardedColor,
                                                                  .font: fontForwarded as Any]
        let attributesForwardedName: [NSAttributedString.Key: Any] = [.foregroundColor: forwardedColor,
                                                                      .font: fontForwardedName as Any]
        let textForwarded = NSMutableAttributedString(string: ChatViewControllerConstant.forwardedFrom, attributes: attributesForwarded)
        let forwardedName = NSAttributedString(string: originForwardedName + "\n", attributes: attributesForwardedName)
        textForwarded.append(forwardedName)
        return textForwarded
    }
    
    var isViewedBy: Bool {
        let currentUserID = Profile().ID
        guard let readIDs = self.readIDs?.filter({ $0.uintValue != currentUserID }) else {
            return false
        }
        return readIDs.isEmpty == false
    }
    
    var isDeliveredTo: Bool {
        let currentUserID = Profile().ID
        guard let deliveredIDs = self.deliveredIDs?.filter({ $0.uintValue != currentUserID }) else {
            return false
        }
        return deliveredIDs.isEmpty == false
    }
    
    var isAttachmentMessage: Bool {
        return attachments?.isEmpty == false
    }
    
    var isNotificationMessage: Bool {
        return customParameters[Key.notificationType] != nil
    }
    
    var isForwardedMessage: Bool {
        return customParameters[Key.forwardedMessage] != nil
    }
    
    var isDateDividerMessage: Bool {
        return customParameters[Key.dateDividerKey] != nil
    }
    
    var isNotificationMessageTypeCreate: Bool {
        if isNotificationMessage == false {
            return false
        }
        return customParameters[Key.notificationType] as? String == NotificationType.createGroupDialog.rawValue
    }
    
    var isNotificationMessageTypeAdding: Bool {
        if isNotificationMessage == false {
            return false
        }
        return customParameters[Key.notificationType] as? String == NotificationType.addUsersToGroupDialog.rawValue
    }
    
    var isNotificationMessageTypeLeave: Bool {
        if isNotificationMessage == false {
            return false
        }
        return customParameters[Key.notificationType] as? String == NotificationType.leaveGroupDialog.rawValue
    }
    
    func estimateFrame(_ constraintsSize: CGSize) -> CGSize {
        let font = UIFont(name: "Helvetica", size: 15)
        let attributes: [NSAttributedString.Key: Any] = [.font: font as Any]
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let boundingRect = messageText().string.boundingRect(with: constraintsSize, options: options, attributes:attributes, context: nil)
        let size = CGSize(width: boundingRect.width, height: boundingRect.height)
        return size
    }
}
