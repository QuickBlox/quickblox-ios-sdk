//
//  QMServiceManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 5/22/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class ServicesManager: NSObject, QMServiceManagerProtocol, QMAuthServiceDelegate, QMChatServiceDelegate, QMChatServiceCacheDelegate {
    
    static let instance = ServicesManager()
    
    var authService : QMAuthService!
    var chatService : QMChatService!
    
    private override init() {
        super.init()
        
        self.setupAuthService()
    }
    
    private func setupAuthService() {
        self.authService = QMAuthService(serviceManager : self)
    }
    
    func setupChatCacheService(userName: String) {
        QMChatCache.setupDBWithStoreNamed(userName + "-storage")
        self.setupChatService()
    }
    
    private func setupChatService() {
        QBChat.instance().autoReconnectEnabled = true
        QBChat.instance().streamManagementEnabled = true
        
        self.chatService = QMChatService(serviceManager : self, cacheDelegate : self)
    }
    
    // MARK: QMServiceManagerProtocol
    
    func currentUser() -> QBUUser! {
        return QBSession.currentSession().currentUser
    }
    
    func isAutorized() -> Bool {
        return self.authService.isAuthorized
    }
    
    func handleErrorResponse(response: QBResponse!) {

    }
    
    // MARK: QMAuthServiceDelegate
    
    func authService(authService: QMAuthService!, didLoginWithUser user: QBUUser!) {
        
    }
    
    func authServiceDidLogOut(authService: QMAuthService!) {
        
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog!) {
        QMChatCache.instance().insertOrUpdateDialog(chatDialog, completion: nil)
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogsToMemoryStorage chatDialogs: [AnyObject]!) {
        QMChatCache.instance().insertOrUpdateDialogs(chatDialogs, completion: nil)
    }
    
    func chatService(chatService: QMChatService!, didAddMessagesToMemoryStorage messages: [AnyObject]!, forDialogID dialogID: String!) {
        QMChatCache.instance().insertOrUpdateMessages(messages, withDialogId: dialogID, completion: nil)
    }
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        QMChatCache.instance().insertOrUpdateMessage(message, withDialogId: dialogID, completion: nil)
    }
    
    func chatService(chatService: QMChatService!, didReceiveNotificationMessage message: QBChatMessage!, createDialog dialog: QBChatDialog!) {
        assert(message.dialog.ID == dialog.ID, "Muste be equal")
        
        QMChatCache.instance().insertOrUpdateMessage(message, withDialogId: message.dialog.ID, completion: nil)
        QMChatCache.instance().insertOrUpdateDialog(dialog, completion: nil)
    }
    
    // MARK: QMChatServiceCacheDelegate
    
    func cachedDialogs(block: QMCacheCollection!) {
        
        QMChatCache.instance().dialogsSortedBy("lastMessageDate", ascending: true) { (dialogs: [AnyObject]!) -> Void in
            block(dialogs);
        }
    }
    
    func cachedMessagesWithDialogID(dialogID: String!, block: QMCacheCollection!) {
        
        QMChatCache.instance().messagesWithDialogId(dialogID, sortedBy: "ID", ascending: true) { (messages: [AnyObject]!) -> Void in
            block(messages)
        }
    }
}
