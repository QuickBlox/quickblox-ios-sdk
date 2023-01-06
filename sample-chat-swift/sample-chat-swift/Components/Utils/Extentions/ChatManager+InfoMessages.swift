//
//  ChatManager+InfoMessages.swift
//  sample-chat-swift
//
//  Created by Injoit on 17.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

extension ChatManager {
    /// Sending an info message to dialog about leaving.
    /// - Parameter dialog: The dialog to which the info to be sent.
    func sendLeave(_ dialog: QBChatDialog, completion: SendMessageCompletion?) {
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        let chatMessage = configureChatMessage("\(currentUser.fullName) " + "has left",
                                               dialog: dialog,
                                               notification: .leaveGroupDialog,
                                               currentUser: currentUser)
        if dialog.type == .private {
            chatMessage.customParameters[Key.saveToHistory] = false
        }
        send(chatMessage, toDialog: dialog) { error in
            if let error = error {
                debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
            }
            completion?(error)
        }
    }
    
    /// Sending an info message to the dialog about creation and sending system messages to participants.
    /// - Parameters:
    ///   - dialog: The dialog to which the info to be sent.
    ///   - completion: The closure to execute when the send operation is complete.
    ///   - error: On success, the value of this parameter is nil. If an error occurred, this parameter contains the error object indicating what happened.
    func sendCreate(to dialog: QBChatDialog, completion: SendMessageCompletion?) {
        let currentUser = Profile()
        guard currentUser.isFull == true,
              let dialogName = dialog.name,
              let usersIDs = dialog.occupantIDs else {
            return
        }
        let chatMessage = configureChatMessage(messageText(withChatName: dialogName),
                                               dialog: dialog,
                                               notification: .createGroupDialog,
                                               currentUser: currentUser)
        let systemMessage = configureSystemMessage(messageText(withChatName: dialogName),
                                                   dialog: dialog,
                                                   notification: .createGroupDialog,
                                                   currentUser: currentUser)
        send(chatMessage, toDialog: dialog) { error in
            if let error = error {
                debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
            }
            completion?(error)
            self.send(systemMessage, to: usersIDs)
        }
    }
    
    /// Sending an info message to the Private dialog about creation for carbon user.
    /// - Parameters:
    ///   - dialog: The dialog to which the info to be sent.
    func sendCreate(to privateDialog: QBChatDialog) {
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        let infoMessage = QBChatMessage()
        infoMessage.senderID = currentUser.ID
        infoMessage.dialogID = privateDialog.id
        infoMessage.dateSent = Date()
        infoMessage.customParameters[Key.saveToHistory] = false
        infoMessage.customParameters[Key.notificationType] = NotificationType.createGroupDialog.rawValue
        send(infoMessage, toDialog: privateDialog) { error in
            if let error = error {
                debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Sending an info message to the dialog about added new members and sending system messages to new members.
    /// - Parameters:
    ///   - usersIDs: The new participants IDs.
    ///   - dialog: The dialog to which the info to be sent.
    func sendAdd(_ usersIDs: [NSNumber], to dialog: QBChatDialog, completion: SendMessageCompletion?) {
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        let users = storage.users(withIDs: usersIDs)
        let IDs = usersIDs.map({ $0.stringValue }).joined(separator: ",")
        let chatMessage = configureChatMessage(messageText(withUsers: users),
                                               dialog: dialog,
                                               notification: .addUsersToGroupDialog,
                                               currentUser: currentUser)
        chatMessage.customParameters[Key.newOccupantsIds] = IDs
        let systemMessage = configureSystemMessage(messageText(withUsers: users),
                                                   dialog: dialog,
                                                   notification: .addUsersToGroupDialog,
                                                   currentUser: currentUser)
        send(chatMessage, toDialog: dialog) { error in
            if let error = error {
                debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
            }
            completion?(error)
            self.send(systemMessage, to: usersIDs)
        }
    }
    
    /// Resent unsent info messages.
    func sendDraftMessages() {
        if draftMessages.isEmpty { return }
        let messages = Array(draftMessages)
        for message in messages {
            if let dialogID = message.dialogID, let dialog = storage.dialog(withID: dialogID) {
                dialog.send(message) { [weak self] (error) in
                    if let error = error {
                        debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
                        return
                    }
                    self?.draftMessages.remove(message)
                }
                continue
            }
            QBChat.instance.sendSystemMessage(message) { [weak self] error in
                if let error = error {
                    debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
                    return
                }
                self?.draftMessages.remove(message)
            }
        }
    }
    
    // MARK: - Internal Methods
    private func messageText(withUsers users: [QBUUser]) -> String {
        let actionMessage = "added"
        guard let current = QBSession.current.currentUser,
              let fullName = current.fullName else {
                  return ""
              }
        var message = "\(fullName) \(actionMessage)"
        for user in users {
            guard let userFullName = user.fullName else {
                continue
            }
            message += " \(userFullName),"
        }
        message = String(message.dropLast())
        return message
    }
    
    private func messageText(withChatName chatName: String) -> String {
        let actionMessage = "created the group chat"
        guard let current = QBSession.current.currentUser,
              let fullName = current.fullName else {
                  return ""
              }
        return "\(fullName) \(actionMessage) \"\(chatName)\""
    }
    
    private func configureChatMessage(_ text: String,
                                      dialog: QBChatDialog,
                                      notification: NotificationType,
                                      currentUser: Profile) -> QBChatMessage {
        let chatMessage = QBChatMessage()
        chatMessage.senderID = currentUser.ID
        chatMessage.dialogID = dialog.id
        chatMessage.deliveredIDs = [(NSNumber(value: currentUser.ID))]
        chatMessage.readIDs = [(NSNumber(value: currentUser.ID))]
        chatMessage.text = text
        chatMessage.markable = true
        chatMessage.dateSent = Date()
        chatMessage.customParameters[Key.saveToHistory] = true
        chatMessage.customParameters[Key.notificationType] = notification.rawValue
        return chatMessage
    }
    
    private func configureSystemMessage(_ text: String,
                                        dialog: QBChatDialog,
                                        notification: NotificationType,
                                        currentUser: Profile) -> QBChatMessage {
        let systemMessage = QBChatMessage()
        systemMessage.senderID = currentUser.ID
        systemMessage.markable = false
        systemMessage.text = text
        systemMessage.dateSent = Date()
        systemMessage.customParameters[Key.dialogId] = dialog.id
        systemMessage.customParameters[Key.notificationType] = notification.rawValue
        return systemMessage
    }
    
    private func send(_ chatMessage: QBChatMessage,
                      toDialog dialog: QBChatDialog, completion:@escaping SendMessageCompletion) {
        dialog.send(chatMessage, completionBlock: { error in
            if let error = error {
                debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
                self.draftMessages.insert(chatMessage)
            }
            completion(error)
        })
    }
    
    private func send(_ systemMessage: QBChatMessage, to users: [NSNumber]) {
        for occupantID in users {
            systemMessage.recipientID = occupantID.uintValue
            QBChat.instance.sendSystemMessage(systemMessage) { error in
                if let error = error {
                    debugPrint("[ChatManager] \(#function) error: \(error.localizedDescription)")
                    self.draftMessages.insert(systemMessage)
                }
            }
        }
    }
}
