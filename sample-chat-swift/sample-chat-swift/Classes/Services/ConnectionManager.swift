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

	var timer: NSTimer? // join all rooms, handle internet connection availability
	
	let privacyManager:PrivacyManager = PrivacyManager()
	
	private override init() {
		super.init()
	}
	
	func logInWithUser(user: QBUUser, completion: (success: Bool, errorMessage: String?) -> Void){
        
        ServicesManager.instance.setupChatCacheService(user.login)
        
        ServicesManager.instance.authService.logInWithUser(user, completion: { (response:QBResponse!, user: QBUUser!) -> Void in
            
            if (response.error != nil) {
                
                completion(success: false, errorMessage: response.error.error.localizedDescription)
                return
            }
            
            if ServicesManager.instance.currentUser() != nil {
                
                ServicesManager.instance.chatService.logoutChat()
                StorageManager.instance.reset()
                self.privacyManager.reset()
                
            }
            
            ServicesManager.instance.chatService.logIn({ (error : NSError!) -> Void in
                
                if error == nil {
                    
                    self.privacyManager.retrieveDefaultPrivacyList()
                }
                
                completion(success: error == nil, errorMessage: error?.localizedDescription)
                
            })
            
        })
        
	}
	
	func joinAllRooms() {
        
		if !IJReachability.isConnectedToNetwork() {
			return
		}
        
		if !QBChat.instance().isLoggedIn() {
			return
		}
        
        let dialogs = StorageManager.instance.dialogs
        
		if dialogs.count > 0 {
			let groupDialogs = dialogs.filter({$0.type != .Private})
            
			for roomDialog in groupDialogs {
				if !roomDialog.chatRoom.isJoined {
					roomDialog.chatRoom.joinRoomWithHistoryAttribute(["maxstanzas":0])
				}
			}
		}
		
	}
}
