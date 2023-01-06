//
//  QBChatDialog+Extension.swift
//  sample-chat-swift
//
//  Created by Injoit on 28.03.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import Foundation
import Quickblox

extension QBChatDialog {
    var isValid: Bool {
        if type.rawValue < 1 {
            debugPrint("[ChatStorage] Chat type is not defined")
            return false
        }
        if id == nil || id?.isEmpty == true {
            debugPrint("[ChatStorage] Chat ID is not defined")
            return false
        }
        return true
    }
    
    var unreadMessagesCounter: String? {
        var trimmedUnreadMessageCount = ""
        if unreadMessagesCount > 0 {
            if unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", unreadMessagesCount)
            }
            return trimmedUnreadMessageCount
        } else {
            return nil
        }
    }
    
    var title: String {
        var text = name ?? "Dialog"
        if type == .private {
            if recipientID == -1 {
                return "Dialog"
            }
            // Getting recipient from users.
            if let recipient = ChatManager.instance.storage.user(withID: UInt(recipientID)) {
                text = recipient.fullName ?? recipient.login!
                return text
            }
        }
        return text
    }
    
    var avatarColor: UIColor {
        return UInt(createdAt!.timeIntervalSince1970).generateColor()
    }
    
    var avatarCharacter: String {
        return String(title.stringByTrimingWhitespace().capitalized.first ?? Character("D"))
    }
    
    func joinWithCompletion(_ completion:@escaping QBChatCompletionBlock) {
        if type != .private, isJoined() {
            completion(nil)
            return
        }
        join { error in
            if let error = error {
                debugPrint("error._code = \(error._code)")
                if error._code == -1006 {
                    completion(nil)
                    return
                }
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
