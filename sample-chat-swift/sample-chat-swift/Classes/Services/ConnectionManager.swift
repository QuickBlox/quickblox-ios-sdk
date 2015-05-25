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
	
	var dialogs:[QBChatDialog]?
	var dialogsUsers:[QBUUser]?
	var messagesIDsToDelete: DynamicArray<String> = DynamicArray(Array())
	let messagesBond = ArrayBond<String>()
	var currentUser:QBUUser?
	
	var timer: NSTimer? // join all rooms, handle internet connection availability
	
	let usersDataSource:UsersDataSource = UsersDataSource()
	let privacyManager:PrivacyManager = PrivacyManager()
	
	// after suspending we use this model to check new messages in group chat
	var currentChatViewModel: ChatViewModel?
	
	private override init() {
		super.init()
		self.startObservingMessagesToDelete()
	}
	
	func logInWithUser(user: QBUUser, completion: (success: Bool, errorMessage: String?) -> Void){
        
        ServicesManager.instance.authService.logInWithUser(user, completion: { (response:QBResponse!, user: QBUUser!) -> Void in
            
            if self.currentUser != nil {
                
                ServicesManager.instance.chatService.logoutChat()
                
                if self.dialogs != nil {
                    
                    self.dialogs = nil
                    self.dialogsUsers = nil
                    self.messagesIDsToDelete.removeAll(false)
                    
                }
                
                self.privacyManager.reset()
                
            }
            
            ServicesManager.instance.chatService.logIn({ (error : NSError!) -> Void in
                
                if error == nil {
                    
                    self.currentUser = user
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
        
		if self.currentUser == nil {
			return
		}
        
		if let dialogs = self.dialogs {
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
		
		messagesBond.didInsertListener = { [unowned self] (array, indices) in
			var messIDs = NSArray(array: self.messagesIDsToDelete.value)
			var messIDsSet: Set<NSObject> = NSSet(array: messIDs as [AnyObject]) as Set<NSObject>
			
			QBRequest.deleteMessagesWithIDs(messIDsSet, successBlock: { [weak self] (response: QBResponse!) -> Void in
				println(response)
				// remove deleted message from our messagesIDsToDelete
				if let strongSelf = self {
					for deletedMessage in messIDs {
						for (index, message) in enumerate(strongSelf.messagesIDsToDelete){
							if message == deletedMessage as! String {
								strongSelf.messagesIDsToDelete.removeAtIndex(index)
							}
						}
					}
				}
				}, errorBlock: { (response: QBResponse!) -> Void in
					println(response.error)
			})
		}
		
		self.messagesIDsToDelete ->> messagesBond
	}
	
	func startObservingInternetAvailability() {
		timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "joinAllRooms", userInfo: nil, repeats: true)
	}
	
	func stopObservingInternetAvailability() {
		timer?.invalidate()
		timer = nil
	}
}
