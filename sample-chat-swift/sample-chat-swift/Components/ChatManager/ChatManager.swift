//
//  ChatManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

enum MessageType : String {
    case createGroupDialog = "1"
    case addUsersToGroupDialog = "2"
    case leaveGroupDialog = "3"
}

struct ChatManagerConstant {
    static let messagesLimitPerDialog = 30
    static let chatServiceDomain = "com.q-municate.chatservice"
    static let errorDomaimCode = -1000
    static let notFound = "SA_STR_DIALOG_REMOVED".localized
}

protocol ChatManagerDelegate: class {
    func chatManagerWillUpdateStorage(_ chatManager: ChatManager)
    func chatManager(_ chatManager: ChatManager, didFailUpdateStorage message: String)
    func chatManager(_ chatManager: ChatManager, didUpdateStorage message: String)
    func chatManager(_ chatManager: ChatManager, didUpdateChatDialog chatDialog: QBChatDialog)
}

typealias DialogsIterationHandler = (_ response: QBResponse?,
    _ objects: [QBChatDialog]?,
    _ usersIDs: Set<NSNumber>?,
    _ stop: Bool?) -> Void
typealias DialogsPage = (_ page: QBResponsePage) -> Void
typealias DialogCompletion = (_ response: QBResponse?, _ dialog: QBChatDialog?) -> Void

typealias UsersIterationHandler = (_ response: QBResponse?, _ objects: [QBUUser]?, _ stop: Bool?) -> Void
typealias UsersPage = (_ page: QBGeneralResponsePage) -> Void

typealias MessagesCompletion = ( _ messages: [QBChatMessage],
    _ isLast: Bool) -> Void

typealias MessagesErrorHandler = (_ error: String?) -> Void

class ChatManager: NSObject {
    
    //MARK: - Properties
    
    weak var delegate: ChatManagerDelegate?
    
    var storage = ChatStorage()
    
    //MARK: - Life Cycle
    //Shared Instance
    static let instance: ChatManager = {
        let instance = ChatManager()
        return instance
    }()
    
    //MARK: - Public Methods
    func updateStorage() {
        
        self.delegate?.chatManagerWillUpdateStorage(self)
        
        let loadGroup = DispatchGroup()
        
        if QBChat.instance.isConnected == false {
            self.delegate?.chatManager(self, didFailUpdateStorage: "SA_STR_NETWORK_ERROR".localized)
            return
        }
        
        var message = ""
        
        loadGroup.enter()
        
        updateUsers(completion: { (response) in
            if let response = response {
                message = self.errorMessage(response: response) ?? ""
            }
            loadGroup.leave()
        })
        
        loadGroup.enter()
        updateAllDialogs(withPageLimit: DialogsConstant.dialogsPageLimit,
                         completion: { (response: QBResponse?) -> Void in
                            if let response = response {
                                message = self.errorMessage(response: response) ?? ""
                            }
                            loadGroup.leave()
        })
        
        loadGroup.notify(queue: DispatchQueue.main) {
            if message.isEmpty {
                self.delegate?.chatManager(self, didUpdateStorage: "SA_STR_COMPLETED".localized)
            } else {
                self.delegate?.chatManager(self, didFailUpdateStorage: message)
            }
        }
    }
    
    //MARK: - Users
    func loadUser(_ id: UInt, completion: ((QBUUser?) -> Void)? = nil) {
        QBRequest.user(withID: id, successBlock: { (response, user) in
            self.storage.update(users: [user])
            completion?(user)
        }) { (response) in
            debugPrint("[ChatManager] loadUser error: \(self.errorMessage(response: response) ?? "")")
            completion?(nil)
        }
    }
    
    
    func sendLeaveMessage(_ text: String,
                          to dialog: QBChatDialog,
                          completion: @escaping QBChatCompletionBlock) {
        
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        
        let message = QBChatMessage()
        message.senderID = currentUser.ID
        message.text = text
        message.markable = true
        message.deliveredIDs = [(NSNumber(value: currentUser.ID))]
        message.readIDs = [(NSNumber(value: currentUser.ID))]
        message.customParameters["save_to_history"] = true
        message.customParameters["notification_type"] = MessageType.leaveGroupDialog.rawValue
        
        let systemMessage = QBChatMessage()
        systemMessage.senderID = currentUser.ID
        systemMessage.markable = false
        systemMessage.text = text
        systemMessage.deliveredIDs = [(NSNumber(value: currentUser.ID))]
        systemMessage.readIDs = [(NSNumber(value: currentUser.ID))]
        systemMessage.customParameters["notification_type"] = MessageType.leaveGroupDialog.rawValue
        systemMessage.customParameters["dialog_id"] = dialog.id
        
        guard let occupantIDs = dialog.occupantIDs else {
            return
        }
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = occupantIDs.count
        let completionOperation = BlockOperation {
            dialog.send(message, completionBlock: { error in
                completion(error)
            })
        }
        
        let systemMessagesOperation = BlockOperation {
            for occupantID in occupantIDs {
                if currentUser.ID == occupantID.intValue {
                    continue
                }
                systemMessage.recipientID = occupantID.uintValue
                QBChat.instance.sendSystemMessage(systemMessage)
            }
        }
        completionOperation.addDependency(systemMessagesOperation)
        operationQueue.addOperations([systemMessagesOperation, completionOperation], waitUntilFinished: false)
    }
    
    func sendAddingMessage(_ text: String,
                           action: DialogAction,
                           withUsers usersIDs: [NSNumber],
                           to dialog: QBChatDialog,
                           completion: @escaping QBChatCompletionBlock) {
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        
        let IDs = usersIDs.map({ $0.stringValue }).joined(separator: ",")
        
        guard let occupantIDs = dialog.occupantIDs else {
            return
        }
        
        let chatMessage = QBChatMessage()
        chatMessage.senderID = currentUser.ID
        chatMessage.dialogID = dialog.id
        chatMessage.deliveredIDs = [(NSNumber(value: currentUser.ID))]
        chatMessage.readIDs = [(NSNumber(value: currentUser.ID))]
        chatMessage.text = text
        chatMessage.markable = true
        chatMessage.customParameters["save_to_history"] = true
        if action == .create {
            chatMessage.customParameters["notification_type"] = MessageType.createGroupDialog.rawValue
        } else if action == .add {
            chatMessage.customParameters["notification_type"] = MessageType.addUsersToGroupDialog.rawValue
            chatMessage.customParameters["new_occupants_ids"] = IDs
        }
        
        let systemMessage = QBChatMessage()
        systemMessage.senderID = currentUser.ID
        systemMessage.markable = false
        systemMessage.text = text
        systemMessage.deliveredIDs = [(NSNumber(value: currentUser.ID))]
        systemMessage.readIDs = [(NSNumber(value: currentUser.ID))]
        if action == .create {
            systemMessage.customParameters["notification_type"] = MessageType.createGroupDialog.rawValue
        } else if action == .add {
            systemMessage.customParameters["notification_type"] = MessageType.addUsersToGroupDialog.rawValue
        }
        systemMessage.customParameters["dialog_id"] = dialog.id
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = usersIDs.count
        let completionOperation = BlockOperation {
            dialog.send(chatMessage, completionBlock: { error in
                completion(error)
            })
        }
        let systemMessagesOperation = BlockOperation {
            if action == .create {
                
                for occupantID in usersIDs {
                    if currentUser.ID == occupantID.intValue {
                        continue
                    }
                    systemMessage.recipientID = occupantID.uintValue
                    QBChat.instance.sendSystemMessage(systemMessage)
                }

            } else if action == .add {
                for occupantID in occupantIDs {
                    if currentUser.ID == occupantID.intValue {
                        continue
                    }
                    systemMessage.recipientID = occupantID.uintValue
                    QBChat.instance.sendSystemMessage(systemMessage)
                }
            }
        }
        completionOperation.addDependency(systemMessagesOperation)
        operationQueue.addOperations([systemMessagesOperation, completionOperation], waitUntilFinished: false)
    }
    
    
    // MARK: - Dialogs
    func createGroupDialog(withName name: String,
                           photo: String?,
                           occupants: [QBUUser],
                           completion: DialogCompletion? = nil) {
        
        let chatDialog = QBChatDialog(dialogID: nil, type: .group)
        
        chatDialog.name = name
        chatDialog.occupantIDs = occupants.map({ NSNumber(value: $0.id) })
        
        QBRequest.createDialog(chatDialog, successBlock: { response, dialog in
            dialog.join(completionBlock: { (error) in
                if error != nil {
                    completion?(response, nil)
                    return
                }
                self.storage.update(dialogs:[dialog])
                //Notify about create new dialog
                let dialogName = dialog.name ?? ""
                self.delegate?.chatManager(self, didUpdateStorage: "SA_STR_CREATE_NEW".localized + dialogName)
                completion?(response, dialog)
            })
        }, errorBlock: { response in
            debugPrint("[ChatManager] createGroupDialog error: \(self.errorMessage(response: response) ?? "")")
            completion?(response, nil)
        })
    }
    
    func createPrivateDialog(withOpponent opponent: QBUUser,
                             completion: DialogCompletion? = nil) {
        assert(opponent.id > 0, "Incorrect user ID")
        if let dialog = storage.privateDialog(opponentID: opponent.id) {
            completion?(nil, dialog)
        } else {
            let currentUser = Profile()
            guard currentUser.isFull == true else {
                return
            }
            let dialog = QBChatDialog(dialogID: nil, type: .private)
            dialog.occupantIDs = [NSNumber(value: opponent.id), NSNumber(value:currentUser.ID)]
            QBRequest.createDialog(dialog, successBlock: { response, createdDialog in
                self.storage.update(dialogs:[createdDialog])
                //Notify about create new dialog
                let dialogName = createdDialog.name ?? ""
                self.delegate?.chatManager(self, didUpdateStorage: "SA_STR_CREATE_NEW".localized + dialogName)
                completion?(response, createdDialog)
            }, errorBlock: { response in
                debugPrint("[ChatManager] createPrivateDialog error: \(self.errorMessage(response: response) ?? "")")
                completion?(response, nil)
            })
        }
    }
    
    func deleteDialog(withID dialogId: String, completion: ((QBResponse?) -> Void)? = nil) {
        guard let dialog = storage.dialog(withID: dialogId) else {
            return
        }
        
        QBRequest.deleteDialogs(withIDs: Set([dialogId]),
                                forAllUsers: false,
                                successBlock: {
                                    response,
                                    deletedObjectsIDs, notFoundObjectsIDs, wrongPermissionsObjectsIDs in
                                    
                                    self.storage.deleteDialog(withID: dialogId)
                                    self.delegate?.chatManager(self, didUpdateStorage: "SA_STR_COMPLETED".localized)
                                    
        }, errorBlock: { response in
            if (response.status == .notFound || response.status == .forbidden), dialog.type != .publicGroup {
                self.storage.deleteDialog(withID: dialogId)
            }
            let errorMessage = self.errorMessage(response: response)
            self.delegate?.chatManager(self, didFailUpdateStorage: errorMessage ?? "")
        })
    }
    
    func loadDialog(withID dialogID: String, completion: @escaping (_ loadedDialog: QBChatDialog?) -> Void) {
        let responsePage = QBResponsePage(limit: 1, skip: 0)
        let extendedRequest = ["_id": dialogID]
        QBRequest.dialogs(for: responsePage, extendedRequest: extendedRequest,
                          successBlock: { response, dialogs, dialogsUsersIDs, page in
                            guard let chatDialog = dialogs.first else {
                                completion(nil)
                                return
                            }
                            self.storage.update(dialogs:[chatDialog])
                            completion(chatDialog)
        }, errorBlock: { response in
            completion(nil)
            debugPrint("[ChatManager] loadDialog error: \(self.errorMessage(response: response) ?? "")")
        })
    }
    
    private func prepareDialog(with dialogID: String, with message: QBChatMessage) {
        let currentUser = Profile()
        if let dialog = storage.dialog(withID: dialogID) {
            dialog.updatedAt = message.dateSent
            dialog.lastMessageText = message.text
            if currentUser.isFull == true,
                message.senderID != currentUser.ID {
                dialog.unreadMessagesCount = dialog.unreadMessagesCount + 1
            }
            
            if message.attachments?.isEmpty == false {
                dialog.lastMessageText = "[Attachment]"
            }
            if let notificationType = message.customParameters["notification_type"] as? String {
                
                switch(notificationType) {
                case MessageType.createGroupDialog.rawValue: break
                case MessageType.addUsersToGroupDialog.rawValue:
                    if let occupantIDs = dialog.occupantIDs,
                        let strIDs = message.customParameters["new_occupants_ids"] as? String {
                        let strArray: [String] = strIDs.components(separatedBy: ",")
                        
                        var newOccupantIDs: [NSNumber] = []
                        var missingOccupantIDs: [NSNumber] = []
                        for strID in strArray {
                            if let uintID = UInt(strID) {
                                if occupantIDs.contains(NSNumber(value: uintID)) == true {
                                    continue
                                } else {
                                    newOccupantIDs.append(NSNumber(value: uintID))
                                    if storage.user(withID: uintID) == nil {
                                        missingOccupantIDs.append(NSNumber(value: uintID))
                                    }
                                }
                            }
                        }
                        
                        if missingOccupantIDs.isEmpty == false {
                            let missingOccupantIDStrArray = missingOccupantIDs.map({ $0.stringValue })
                            QBRequest.users(withIDs: missingOccupantIDStrArray, page: nil, successBlock: { (response, page, newUsers) in
                                self.storage.update(users: newUsers)
                                dialog.occupantIDs = occupantIDs + newOccupantIDs
                                self.storage.update(dialogs:[dialog])
                                self.delegate?.chatManager(self, didUpdateChatDialog: dialog)
                                
                            }, errorBlock: { response in
                                debugPrint("[ChatManager] loadUsers error: \(self.errorMessage(response: response) ?? "")")
                            })
                        } else {
                            dialog.occupantIDs = occupantIDs + newOccupantIDs
                            self.storage.update(dialogs:[dialog])
                            self.delegate?.chatManager(self, didUpdateChatDialog: dialog)
                        }
                    }
                case MessageType.leaveGroupDialog.rawValue:
                    if var occupantIDs = dialog.occupantIDs,
                        occupantIDs.contains(NSNumber(value: message.senderID)) == true {
                        occupantIDs = occupantIDs.filter({ $0.uintValue != message.senderID })
                        dialog.occupantIDs = occupantIDs
                        self.storage.update(dialogs:[dialog])
                        self.delegate?.chatManager(self, didUpdateChatDialog: dialog)
                    }
                default: break
                    
                }
            } else {
                self.storage.update(dialogs:[dialog])
                self.delegate?.chatManager(self, didUpdateChatDialog: dialog)
            }
        } else {
            loadDialog(withID: dialogID, completion: { dialog in
                guard let dialog = dialog else {
                    return
                }
                dialog.lastMessageText = message.text
                dialog.updatedAt = Date()
                if let notificationType = message.customParameters["notification_type"] as? String {
                    switch(notificationType) {
                    case MessageType.createGroupDialog.rawValue: dialog.unreadMessagesCount = 1
                    case MessageType.addUsersToGroupDialog.rawValue:break
                    case MessageType.leaveGroupDialog.rawValue:break
                       
                    default: break
                    }
                }
                self.storage.update(dialogs:[dialog])
                self.delegate?.chatManager(self, didUpdateChatDialog: dialog)
            })
        }
    }
    
    func updateDialog(with dialogID: String, with message: QBChatMessage) {
       let userSender = storage.user(withID: message.senderID)
        if userSender == nil {
            QBRequest.user(withID: message.senderID, successBlock: { response, user in
                self.storage.update(users:[user])
                self.prepareDialog(with: dialogID, with: message)
            }, errorBlock: { response in
                debugPrint("[ChatManager] updateDialog error: \(self.errorMessage(response: response) ?? "")")
            })
        } else {
            prepareDialog(with: dialogID, with: message)
        }
    }
    
    //MARK: - Messages
    func messages(withID dialogID: String,
                  extendedRequest extendedParameters: [String: String]? = nil,
                  skip: Int,
                  successCompletion: MessagesCompletion? = nil,
                  errorHandler: MessagesErrorHandler? = nil ) {
        
        let page = QBResponsePage(limit: ChatManagerConstant.messagesLimitPerDialog, skip: skip)
        let extendedRequest = extendedParameters?.isEmpty == false ? extendedParameters : parametersForMessages()
        QBRequest.messages(withDialogID: dialogID,
                           extendedRequest: extendedRequest,
                           for: page,
                           successBlock: { response, messages, page in
                            var sortedMessages = messages
                            sortedMessages = Array(sortedMessages.reversed())
                            
                            var cancel = false
                            let numberOfMessages = sortedMessages.count
                            cancel = numberOfMessages < page.limit ? true : false
                            
                            successCompletion?(sortedMessages, cancel)
                            
        }, errorBlock: { response in
            // case where we may have deleted dialog from another device
            if response.status == .notFound || response.status.rawValue == 403 {
                self.storage.deleteDialog(withID: dialogID)
                errorHandler?(ChatManagerConstant.notFound)
                return
            }
            errorHandler?(self.errorMessage(response: response))
        })
    }
    
    
    func send(_ message: QBChatMessage, to dialog: QBChatDialog, completion: QBChatCompletionBlock?) {
        dialog.send(message) { (error) in
            if let error = error {
                completion?(error)
            }
            dialog.updatedAt = Date()
            self.storage.update(dialogs: [dialog])
            self.delegate?.chatManager(self, didUpdateChatDialog: dialog)
            completion?(nil)
        }
    }
    
    func read(_ messages: [QBChatMessage],
              dialog: QBChatDialog,
              completion: QBChatCompletionBlock?) {
        let currentUser = Profile()
        if currentUser.isFull == false {
            completion?(nil)
            return
        }
        
        let readGroup = DispatchGroup()
        
        for message in messages {
            if   message.dialogID != dialog.id  {
                continue
            }
            readGroup.enter()
            QBChat.instance.read(message) { error in
                if error == nil {
                    // updating dialog
                    if dialog.unreadMessagesCount > 0 {
                        dialog.unreadMessagesCount = dialog.unreadMessagesCount - 1
                    }
                    if UIApplication.shared.applicationIconBadgeNumber > 0 {
                        let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                        UIApplication.shared.applicationIconBadgeNumber = badgeNumber - 1
                    }
                    readGroup.leave()
                }
            }
        }
        readGroup.notify(queue: DispatchQueue.main) {
            self.storage.update(dialogs: [dialog])
            self.delegate?.chatManager(self, didUpdateChatDialog: dialog)
            completion?(nil)
        }
    }
    
    func joinOccupants(withIDs ids: [NSNumber], to chatDialog: QBChatDialog,
                       completion: @escaping (_ response: QBResponse?, _ updatedDialog: QBChatDialog?) -> Void) {
        let pushOccupantsIDs = ids.map({ $0.stringValue })
        chatDialog.pushOccupantsIDs = pushOccupantsIDs
        QBRequest.update(chatDialog, successBlock: { response, updatedDialog in
            
            chatDialog.pushOccupantsIDs = []
            self.storage.update(dialogs:[updatedDialog])
            completion(response, updatedDialog)
        }, errorBlock: { response in
            chatDialog.pushOccupantsIDs = []
            completion(response, nil)
        })
    }
    
    //MARK: - Connect/Disconnect
    func connect(completion: QBChatCompletionBlock? = nil) {
        let currentUser = Profile()
        
        guard currentUser.isFull == true else {
            completion?(NSError(domain: ChatManagerConstant.chatServiceDomain,
                                code: ChatManagerConstant.errorDomaimCode,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Please enter your login and username."
                ]))
            return
        }
        if QBChat.instance.isConnected == true {
            completion?(nil)
        } else {
            QBSettings.autoReconnectEnabled = true
            QBChat.instance.connect(withUserID: currentUser.ID,
                                    password: currentUser.password,
                                    completion: completion)
        }
    }
    
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        if QBChat.instance.isConnected == true {
            QBChat.instance.disconnect(completionBlock: completion)
        } else {
            completion?(nil)
        }
    }
    
    //MARK: - Internal Methods
    //MARK: - Users
    private func updateUsers(completion: @escaping (_ response: QBResponse?) -> Void) {
        let firstPage = QBGeneralResponsePage(currentPage: 1, perPage: 100)
        QBRequest.users(withExtendedRequest: ["order": "desc string updated_at"],
                        page: firstPage,
                        successBlock: { (response, page, users) in
                            self.storage.update(users:users)
                            completion(response)
        }, errorBlock: { response in
            completion(response)
            debugPrint("[ChatManager] updateUsers error: \(self.errorMessage(response: response) ?? "")")
        })
    }
    
    //MARK: - Dialogs
    private func updateAllDialogs(withPageLimit limit: Int,
                                  extendedRequest: [String: String]? = nil,
                                  iterationBlock: DialogsIterationHandler? = nil,
                                  completion: @escaping (_ response: QBResponse?) -> Void) {
        
        var t_request: DialogsPage?
        
        let request: DialogsPage? = { responsePage in
            QBRequest.dialogs(for: responsePage,
                              extendedRequest: extendedRequest,
                              successBlock: { response,
                                dialogs, dialogsUsersIDs, page in
                                
                                self.storage.update(dialogs:dialogs)
                                page.skip += dialogs.count
                                let cancel = page.totalEntries <= page.skip
                                iterationBlock?(response, dialogs, dialogsUsersIDs, cancel)
                                if cancel == false {
                                    t_request?(page)
                                } else {
                                    completion(response)
                                    t_request = nil
                                }
            }, errorBlock: { response in
                completion(response)
                debugPrint("[ChatManager] updateAllDialogs error: \(self.errorMessage(response: response) ?? "")")
                t_request = nil
            })
        }
        t_request = request
        request?(QBResponsePage(limit: limit))
    }
    
    //MARK: - Messages
    private func parametersForMessages() -> [String : String] {
        let parameters = ["sort_desc": "date_sent", "mark_as_read": "0"]
        return parameters
    }
    
    //MARK: - Helpers
    func color(_ index: Int) -> UIColor {
        let colors = [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), #colorLiteral(red: 0.3035047352, green: 0.8693258762, blue: 0.4432001114, alpha: 1), #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), #colorLiteral(red: 0.02297698334, green: 0.6430568099, blue: 0.603818357, alpha: 1), #colorLiteral(red: 0.5244195461, green: 0.3333674073, blue: 0.9113605022, alpha: 1), #colorLiteral(red: 0, green: 0.5694751143, blue: 1, alpha: 1), #colorLiteral(red: 0.839125216, green: 0.871129334, blue: 0.3547145724, alpha: 1), #colorLiteral(red: 0.09088832885, green: 0.7803853154, blue: 0.8577881455, alpha: 1), #colorLiteral(red: 1, green: 0.3950406728, blue: 0.0543332563, alpha: 1), #colorLiteral(red: 1, green: 0.5161726656, blue: 0.9950085603, alpha: 1), #colorLiteral(red: 1, green: 0.01143101626, blue: 0.09927682555, alpha: 1)]
        if index >= 0 {
            return colors[index % 10]
        } else {
            return .black
        }
    }
    
    //Handle Error
    private func errorMessage(response: QBResponse) -> String? {
        var errorMessage : String
        if response.status.rawValue == 502 {
            errorMessage = "SA_STR_BAD_GATEWAY".localized
        } else if response.status.rawValue == 0 {
            errorMessage = "SA_STR_NETWORK_ERROR".localized
        } else {
            guard let qberror = response.error,
                let error = qberror.error else {
                    return nil
            }
            
            errorMessage = error.localizedDescription.replacingOccurrences(of: "(",
                                                                           with: "",
                                                                           options:.caseInsensitive,
                                                                           range: nil)
            errorMessage = errorMessage.replacingOccurrences(of: ")",
                                                             with: "",
                                                             options: .caseInsensitive,
                                                             range: nil)
        }
        return errorMessage
    }
}
