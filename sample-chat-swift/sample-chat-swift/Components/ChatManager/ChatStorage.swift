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
    
    func users(_ usersIDs: [NSNumber], completion: DownloadUsersCompletion?) {
        var members: [UInt: QBUUser] = [:]
        var newUsersIDs: [String] = []
        usersIDs.forEach { (userID) in
            if let user = users.first(where: { $0.id == userID.uintValue }) {
                members[userID.uintValue] = user
            } else {
                newUsersIDs.append(userID.stringValue)
            }
        }
        if newUsersIDs.isEmpty {
            completion?(Array(members.values), nil)
            return
        }
        let page = QBGeneralResponsePage(currentPage: 1, perPage: ChatManagerConstant.usersLimit)
        QBRequest.users(withIDs: newUsersIDs, page: page, successBlock: { [weak self] (response, page, users) in
            guard let self = self else {
                completion?(Array(members.values), nil)
                return
            }
            self.users.append(contentsOf: users)
            completion?(Array(members.values) + users, nil)
        }, errorBlock: { (response) in
            completion?(Array(members.values), response.error?.error)
        })
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
    
    func dialogsSortByLastMessage() -> [QBChatDialog] {
        return dialogs.sorted(by: {
            guard let firstUpdateAt = $0.lastMessageDate, let lastUpdate = $1.lastMessageDate else {
                return false
            }
            return firstUpdateAt > lastUpdate
        })
    }
    
    func update(_ dialogs: [QBChatDialog], completion: (() -> Void)? = nil) {
        for chatDialog in dialogs {
            if chatDialog.isValid == false {
                debugPrint("[ChatStorage] Chat Dialog is not valid")
                continue
            }
            
            let dialog = update(dialog:chatDialog)
            
            // Autojoin to the group chat
            if dialog.type == .private {
                continue
            }
            if dialog.isJoined() {
                continue
            }
            dialog.join(completionBlock: { error in
                if let error = error {
                    debugPrint("[ChatStorage] dialog.join error: \(error.localizedDescription)")
                }
            })
        }
        completion?()
    }
    
    func deleteDialog(withID ID: String, completion: (() -> Void)? = nil) {
        guard let index = dialogs.firstIndex(where: { $0.id == ID }) else {
            completion?()
            return
        }
        dialogs.remove(at: index)
        completion?()
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
    
    func updateSearch(users: [QBUUser]) {
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
    
    func users(withIDs userIDs: [NSNumber]) -> [QBUUser] {
        var users: [QBUUser] = []
        for ID in userIDs {
            if let user = self.user(withID: ID.uintValue) {
                users.append(user)
            }
        }
        return sorted(users: users)
    }
    
    func sortedAllUsers() -> [QBUUser] {
        let sortedUsers = users.sorted(by: {
            guard let firstUpdatedAt = $0.lastRequestAt, let secondUpdatedAt = $1.lastRequestAt else {
                return false
            }
            return firstUpdatedAt > secondUpdatedAt
        })
        return sortedUsers
    }
    
    func existingUsersIDs() -> Set<NSNumber> {
        if users.isEmpty == true {
            return Set()
        }
        let usersIDs = users.map({ NSNumber(value: $0.id) })
        return Set(usersIDs)
    }
    
    //MARK: - Internal Methods
    private func markMessagesAsDelivered(forDialogID dialogID: String) {
        QBRequest.markMessages(asDelivered: nil, dialogID: dialogID, successBlock: { response in
            debugPrint("[ChatStorage] dialog.markMessages as Delivered success!!!")
        }, errorBlock: { response in
            if let error = response.error?.error {
                debugPrint("[ChatStorage] dialog.markMessages as Delivered error: \(error.localizedDescription)")
            }
        })
    }
    
    private func update(dialog: QBChatDialog) -> QBChatDialog {
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
            guard let firstUpdatedAt = $0.lastRequestAt, let secondUpdatedAt = $1.lastRequestAt else {
                return false
            }
            return firstUpdatedAt > secondUpdatedAt
        })
        return sortedUsers
    }
    
    private func update(user: QBUUser) {
        if let localUser = users.filter({ $0.id == user.id }).first {
            //Update local User
            localUser.fullName = user.fullName
            localUser.lastRequestAt = user.lastRequestAt
            return
        }
        users.append(user)
    }
}
