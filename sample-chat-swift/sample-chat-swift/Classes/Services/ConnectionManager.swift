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
	
	var request: QBRequest?
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
		tmpUser = user
		var params = QBSessionParameters()
		params.userLogin = user.login
		params.userPassword = user.password
		self.chatLoginCompletion = completion
		request = QBRequest.createSessionWithExtendedParameters(params, successBlock: { [weak self ] (response: QBResponse!, session: QBASession!) -> Void in
			if let strongSelf = self {
				strongSelf.request = nil
				
				strongSelf.currentUser = QBUUser()
				strongSelf.currentUser!.ID = session.userID
				strongSelf.currentUser!.login = user.login
				strongSelf.currentUser!.password = user.password
				
				if QBChat.instance().isLoggedIn() {
					QBChat.instance().logout()
					if strongSelf.dialogs != nil {
						strongSelf.dialogs = nil
						strongSelf.dialogsUsers = nil
						strongSelf.messagesIDsToDelete.removeAll(false)
					}
					strongSelf.privacyManager.reset()
				}
				
				QBChat.instance().loginWithUser(user)
			}
			}) {[weak self] (response: QBResponse!) -> Void in
				self?.request = nil
				self?.chatLoginCompletion = nil
				completion(success: false, errorMessage: response.error.error.localizedDescription)
				println(response.error.error.localizedDescription)
		}
	}
	
	func joinAllRooms() {
		if !IJReachability.isConnectedToNetwork() {
			return
		}
		if !QBChat.instance().isLoggedIn() {
			return
		}
		if let dialogs = self.dialogs {
			let groupDialogs = dialogs.filter({$0.type.value != QBChatDialogTypePrivate.value})
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
