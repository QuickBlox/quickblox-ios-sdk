//
//  ChatStorage.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

class ChatStorage {
    //MARK: - Properties
    var dialogs: [QBChatDialog] = []
    var users: [QBUUser] = []
    
    // MARK: - Public Methods
    func clear() {
        self.dialogs = []
        self.users = []
    }
    
    func privateDialog(opponentID: UInt) -> QBChatDialog? {
        let dialogs = self.dialogs.filter({
            guard let occupantIDs = $0.occupantIDs else {
                return false
            }
            let isPrivate = $0.type == .private
            let withOpponent = occupantIDs.contains(NSNumber(value: opponentID))
            return isPrivate && withOpponent
        })
        return dialogs.first
    }
    
    func dialog(withID dialogID: String) -> QBChatDialog? {
        guard let dialog = dialogs.filter({ $0.id == dialogID }).first else {
            return nil
        }
        return dialog
    }
    
    func dialogsSortByUpdatedAt() -> [QBChatDialog] {
        return dialogs.sorted(by: {
            guard let firstUpdateAt = $0.updatedAt, let lastUpdate = $1.updatedAt else {
                return false
            }
            return firstUpdateAt > lastUpdate
        })
    }
    
    func update(dialogs: [QBChatDialog]) {
        for chatDialog in dialogs {
            assert(chatDialog.type.rawValue != 0, "Chat type is not defined")
            
            let dialog = update(dialog:chatDialog)
            
            // Autojoin to the group chat
            if dialog.isJoined() == true {
                continue
            }
            dialog.join(completionBlock: { error in
                guard let error = error else {
                    return
                }
                debugPrint("[ChatStorage] dialog.join error: \(error.localizedDescription)")
            })
        }
    }
    
    func deleteDialog(withID ID: String) {
        guard let index = dialogs.index(where: { $0.id == ID }) else {
            return
        }
        dialogs.remove(at: index)
    }
    
    func user(withID ID: UInt) -> QBUUser? {
        guard let user = users.filter({ $0.id == ID }).first else {
            return nil
        }
        return user
    }
    
    func update(users: [QBUUser]) {
        for chatUser in users {
            update(user:chatUser)
        }
    }
    
    func users(with dialogID: String) -> [QBUUser] {
        var users: [QBUUser] = []
        guard let dialog = dialog(withID: dialogID), let occupantIDs = dialog.occupantIDs  else {
            return users
        }
        for ID in occupantIDs {
            if let user = self.user(withID: ID.uintValue) {
                users.append(user)
            }
        }
        return sorted(users: users)
    }
    
    func sortedAllUsers() -> [QBUUser] {
        let sortedUsers = users.sorted(by: {
            guard let firstUpdatedAt = $0.updatedAt, let secondUpdatedAt = $1.updatedAt else {
                return false
            }
            return firstUpdatedAt > secondUpdatedAt
        })
        return sortedUsers
    }
    
    //MARK: - Internal Methods
    private func update(dialog: QBChatDialog) -> QBChatDialog {
        assert(dialog.type.rawValue != 0, "Chat type is not defined")
        if let localDialog = self.dialog(withID: dialog.id! ) {
            localDialog.updatedAt = dialog.updatedAt
            localDialog.createdAt = dialog.createdAt
            localDialog.name = dialog.name
            localDialog.photo = dialog.photo
            localDialog.lastMessageDate = dialog.lastMessageDate
            localDialog.lastMessageUserID = dialog.lastMessageUserID
            localDialog.lastMessageText = dialog.lastMessageText
            localDialog.occupantIDs = dialog.occupantIDs
            localDialog.data = dialog.data
            localDialog.userID = dialog.userID
            localDialog.unreadMessagesCount = dialog.unreadMessagesCount
            return localDialog
        }
        dialogs.append(dialog)
        
        return dialog
    }
    
    private func sorted(users: [QBUUser]) -> [QBUUser] {
        let sortedUsers = users.sorted(by: {
            guard let firstUpdatedAt = $0.updatedAt, let secondUpdatedAt = $1.updatedAt else {
                return false
            }
            return firstUpdatedAt < secondUpdatedAt
        })
        return sortedUsers
    }
    
    private func update(user: QBUUser) {
        if let localUser = users.filter({ $0.id == user.id }).first {
            //Update local User
            localUser.fullName = user.fullName
            localUser.updatedAt = user.updatedAt
            return
        }
        users.append(user)
    }
}
