//
//  ConnectionManager.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject, QBChatDelegate {
    static let instance = ConnectionManager()
    
    private var presenceTimer:NSTimer!
    private var chatLoginCompletion:((Bool, String?) -> Void)!
    var dialogs:[QBChatDialog]?
    var dialogsUsers:[QBUUser]?
    var usersDataSource:UsersDataSource
    var currentUser:QBUUser?
    
    
     private override init() {
        self.usersDataSource = UsersDataSource()
    }
    
    func logInWithUser(user: QBUUser, completion: (success: Bool, errorMessage: String?) -> Void){
        var params = QBSessionParameters()
        params.userLogin = user.login
        params.userPassword = user.password
        
        QBRequest.createSessionWithExtendedParameters(params, successBlock: { [weak self ] (response: QBResponse!, session: QBASession!) -> Void in
            var conm = ConnectionManager.instance
            
            conm.currentUser = QBUUser()
            conm.currentUser!.ID = session.userID
            conm.currentUser!.login = user.login
            conm.currentUser!.password = user.password
            
            
            QBChat.instance().addDelegate(self)
            QBChat.instance().loginWithUser(user)
            
            if( QBChat.instance().isLoggedIn() ){
                completion(success: true, errorMessage: nil)
            }
            else{
                conm.chatLoginCompletion = completion
            }
            
            }) { (response: QBResponse!) -> Void in
                completion(success: false, errorMessage: response.error.error.localizedDescription)
                println(response.error.error.localizedDescription)
        }
    }
    
    /**
    *   Chat delegates
    */
    
    func chatDidFailWithError(code: Int) {
        if self.chatLoginCompletion != nil {
            self.chatLoginCompletion(false, "chat did fail with code" + String(code))
            self.chatLoginCompletion = nil
        }
    }
    
    func chatDidLogin() {
        self.presenceTimer = NSTimer.scheduledTimerWithTimeInterval(kChatPresenceTimeInterval, target: self, selector: Selector("sendChatPresence"), userInfo: nil, repeats: true)
        
        if self.chatLoginCompletion != nil {
            self.chatLoginCompletion(true, nil)
            self.chatLoginCompletion = nil
        }
        
    }
    
    func sendChatPresence() {
        QBChat.instance().sendPresence()
    }
}
