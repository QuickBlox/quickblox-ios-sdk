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
	
	let usersDataSource:UsersDataSource = UsersDataSource()
	let privacyManager:PrivacyManager = PrivacyManager()
	
	private override init() {
		super.init()
		self.startObservingMessagesToDelete()
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
	/**
	*   Chat delegates
	*/
	
	/**
	Observers
	*/
	func startObservingMessagesToDelete() {
		
		StorageManager.instance.messagesBond.didInsertListener = { [unowned self] (array, indices) in
			var messIDs = NSArray(array: StorageManager.instance.messagesIDsToDelete.value)
			var messIDsSet: Set<NSObject> = NSSet(array: messIDs as [AnyObject]) as Set<NSObject>
			
			QBRequest.deleteMessagesWithIDs(messIDsSet, successBlock: { [weak self] (response: QBResponse!) -> Void in
				println(response)
				// remove deleted message from our messagesIDsToDelete
                for deletedMessage in messIDs {
                    
                    for (index, message) in enumerate(StorageManager.instance.messagesIDsToDelete){
                        
                        if message == deletedMessage as! String {
                            StorageManager.instance.messagesIDsToDelete.removeAtIndex(index)
                        }
                    }
                }
            }, errorBlock: { (response: QBResponse!) -> Void in
					println(response.error)
			})
		}
		
		StorageManager.instance.messagesIDsToDelete ->> StorageManager.instance.messagesBond
	}
	
	func startObservingInternetAvailability() {
		timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "joinAllRooms", userInfo: nil, repeats: true)
	}
	
	func stopObservingInternetAvailability() {
		timer?.invalidate()
		timer = nil
	}
}
