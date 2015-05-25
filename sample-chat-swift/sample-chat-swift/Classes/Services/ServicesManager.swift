//
//  QMServiceManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 5/22/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class ServicesManager: NSObject, QMServiceManagerProtocol {
    
    static let instance = ServicesManager()
    
    var authService : QMAuthService!
    var chatService : QMChatService!
    
    private override init() {
        
        super.init()
        
        self.authService = QMAuthService(serviceManager : self)
        self.chatService = QMChatService(serviceManager : self, cacheDelegate : nil)
    }
    
    func currentUser() -> QBUUser! {
        
        return QBSession.currentSession().currentUser
        
    }
    
    func isAutorized() -> Bool {
        
        return self.authService.isAuthorized
        
    }
    
    func handleErrorResponse(response: QBResponse!) {
        
        let alertView = UIAlertView()
        alertView.title = "Errors"
        alertView.message = response.error.description
        alertView.addButtonWithTitle("Ok")
        alertView.show()
        
    }
    
}
