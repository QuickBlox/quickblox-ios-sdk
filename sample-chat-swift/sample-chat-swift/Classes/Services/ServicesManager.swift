//
//  QMServiceManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 5/22/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class ServicesManager: NSObject, QMServiceManagerProtocol, QMAuthServiceDelegate, QMChatServiceDelegate, QMChatServiceCacheDataSource {
    
    static let instance = ServicesManager()
    
    var authService : QMAuthService!
    var chatService : QMChatService!
    
    var logoutGroup = dispatch_group_create()
    
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
        
        self.chatService = QMChatService(serviceManager : self, cacheDataSource : self)
        self.chatService.addDelegate(ServicesManager.instance)
    }
    
    func logout(completion: (() -> Void)!) {
        
        if self.currentUser() == nil {
            completion()
            
            return
        }
        
        dispatch_group_enter(self.logoutGroup)
        
        self.authService .logOut { (response: QBResponse!) -> Void in
            self.chatService.logoutChat()
            
            dispatch_group_leave(self.logoutGroup)
        }
        
        dispatch_group_enter(self.logoutGroup)
        
        QMChatCache.instance().deleteAllMessages { () -> Void in
            dispatch_group_leave(self.logoutGroup)
        }
        
        dispatch_group_enter(self.logoutGroup)
        
        QMChatCache.instance().deleteAllDialogs { () -> Void in
            dispatch_group_leave(self.logoutGroup)
        }
        
        dispatch_group_notify(self.logoutGroup, dispatch_get_main_queue()) { () -> Void in
            completion()
        }
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
    
    func chatService(chatService: QMChatService!, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog!) {
        QMChatCache.instance().insertOrUpdateDialog(chatDialog, completion: nil)
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog!) {
        QMChatCache.instance().insertOrUpdateDialog(chatDialog, completion: nil)
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogsToMemoryStorage chatDialogs: [AnyObject]!) {
        QMChatCache.instance().insertOrUpdateDialogs(chatDialogs, completion: nil)
    }
    
    func chatService(chatService: QMChatService!, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String!) {
        QMChatCache.instance().deleteDialogWithID(chatDialogID, completion: nil)
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
    
    // MARK: QMChatServiceCacheDataSource
    
    func cachedDialogs(block: QMCacheCollection!) {
        
        QMChatCache.instance().dialogsSortedBy("lastMessageDate", ascending: true) { (dialogs: [AnyObject]!) -> Void in
            block(dialogs);
        }
    }
    
    func cachedMessagesWithDialogID(dialogID: String!, block: QMCacheCollection!) {
        
        QMChatCache.instance().messagesWithDialogId(dialogID, sortedBy: CDMessageAttributes.messageID as String, ascending: true) { (messages: [AnyObject]!) -> Void in
            block(messages)
        }
    }
}
