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
	
	private var tmpUser: QBUUser? // if chat failed to connect, we try to connect again
	
	private var presenceTimer:NSTimer!
	private var chatLoginCompletion:((Bool, String?) -> Void)!
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
		QBChat.instance().addDelegate(self)
		self.startObservingMessagesToDelete()
	}
	
	func logInWithUser(user: QBUUser, completion: (success: Bool, errorMessage: String?) -> Void){
		self.chatLoginCompletion = completion
        self.tmpUser = user
        
        if QBChat.instance().isLoggedIn() {
            QBChat.instance().logout()
            if self.dialogs != nil {
                self.dialogs = nil
                self.dialogsUsers = nil
                self.messagesIDsToDelete.removeAll(false)
            }
            self.privacyManager.reset()
        }
        
        QBChat.instance().loginWithUser(user)
        
        
	}
	
	func joinAllRooms() {
		if !IJReachability.isConnectedToNetwork() {
			return
		}
		if !QBChat.instance().isLoggedIn() {
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
	
	func chatDidFailWithError(code: Int) {
		if self.chatLoginCompletion != nil {
			self.chatLoginCompletion(false, "chat did fail with code" + String(code))
			self.chatLoginCompletion = nil
		}
	}
	
	func chatDidLogin() {
        self.currentUser = QBSession.currentSession().currentUser
		self.presenceTimer = NSTimer.scheduledTimerWithTimeInterval(kChatPresenceTimeInterval, target: QBChat.instance(), selector: Selector("sendPresence"), userInfo: nil, repeats: true)
		self.privacyManager.retrieveDefaultPrivacyList()
	}
	
	func chatDidReceivePrivacyList(privacyList: QBPrivacyList!) {
		if self.chatLoginCompletion != nil {
			self.chatLoginCompletion(true, nil)
			self.chatLoginCompletion = nil
		}
	}
	
	func chatDidNotLogin() {
		if tmpUser != nil {
			self.logInWithUser(tmpUser!, completion: self.chatLoginCompletion)
		}
	}
	
	func chatDidNotReceivePrivacyListWithName(name: String!, error: AnyObject!) {
		if self.chatLoginCompletion != nil {
			self.chatLoginCompletion(true, nil)
			self.chatLoginCompletion = nil
		}
	}
	
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
	
	deinit{
		self.presenceTimer.invalidate()
		QBChat.instance().removeDelegate(self)
	}
	
	
}
