//
//  ConnectionManager.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject, QBChatDelegate {
    private var presenceTimer:NSTimer!
    private var chatLoginCompletion:((Bool) -> Void)!
    
    
    static let instance = ConnectionManager()
    
    func logInWithUser(user: QBUUser, completion: (success: Bool) -> Void){
        
        QBChat.instance().addDelegate(self)
        QBChat.instance().loginWithUser(user)
        
        if( QBChat.instance().isLoggedIn() ){
                completion(success: true)
        }
        else{
            self.chatLoginCompletion = completion
        }
    }
    
    
    /**
    *   Chat delegates
    */
    
    func chatDidFailWithError(code: Int) {
        if self.chatLoginCompletion != nil {
            self.chatLoginCompletion(false)
            self.chatLoginCompletion = nil
        }
    }
    
    func chatDidLogin() {
        self.presenceTimer = NSTimer.scheduledTimerWithTimeInterval(kChatPresenceTimeInterval, target: self, selector: Selector("sendChatPresence"), userInfo: nil, repeats: true)
        
        if self.chatLoginCompletion != nil {
            self.chatLoginCompletion(true)
            self.chatLoginCompletion = nil
        }
        
    }
    
    func sendChatPresence() {
        QBChat.instance().sendPresence()
    }
}
