//
//  QMServiceManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 5/22/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

/**
*  Implements user's memory/cache storing, error handling, show top bar notifications.
*/
class ServicesManager: QMServicesManager {
    
    var currentDialogID = ""
    
    var colors = [
        UIColor(red: 0.992, green:0.510, blue:0.035, alpha:1.000),
        UIColor(red: 0.039, green:0.376, blue:1.000, alpha:1.000),
        UIColor(red: 0.984, green:0.000, blue:0.498, alpha:1.000),
        UIColor(red: 0.204, green:0.644, blue:0.251, alpha:1.000),
        UIColor(red: 0.580, green:0.012, blue:0.580, alpha:1.000),
        UIColor(red: 0.396, green:0.580, blue:0.773, alpha:1.000),
        UIColor(red: 0.765, green:0.000, blue:0.086, alpha:1.000),
        UIColor.redColor(),
        UIColor(red: 0.786, green:0.706, blue:0.000, alpha:1.000),
        UIColor(red: 0.740, green:0.624, blue:0.797, alpha:1.000)
    ]
    
    private var contactListService : QMContactListService!
    var notificationService: NotificationService!
    //var lastActivityDate: NSDate!
    
    override init() {
        super.init()
        
        self.setupContactServices()
    }
    
    private func setupContactServices() {
        self.notificationService = NotificationService()
    }
    
    func handleNewMessage(message: QBChatMessage, dialogID: String) {
        
        guard self.currentDialogID != dialogID else {
            return
        }
        
        guard message.senderID != self.currentUser()?.ID else {
            return
        }
		
		guard let dialog = self.chatService.dialogsMemoryStorage.chatDialogWithID(dialogID) else {
			print("chat dialog not found")
			return
		}
		
        var dialogName = "SA_STR_NEW_MESSAGE".localized
        
        if dialog.type != QBChatDialogType.Private {
            
            if dialog.name != nil {
                dialogName = dialog.name!
            }
    
        } else {
            
            if let user = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(dialog.recipientID)) {
                dialogName = user.login!
            }
        }
               QMMessageNotificationManager.showNotificationWithTitle(dialogName, subtitle: message.text, type: QMMessageNotificationType.Info)
    }
    
    // MARK: Last activity date
    
    var lastActivityDate: NSDate? {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.valueForKey("SA_STR_LAST_ACTIVITY_DATE".localized) as! NSDate?
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(newValue, forKey: "SA_STR_LAST_ACTIVITY_DATE".localized)
            defaults.synchronize()
        }
    }

    // MARK: QMServiceManagerProtocol
    
    override func handleErrorResponse(response: QBResponse) {
        super.handleErrorResponse(response)
        
        guard self.isAuthorized() else {
            return
        }
        
        var errorMessage : String
        
        if response.status.rawValue == 502 {
            errorMessage = "SA_STR_BAD_GATEWAY".localized
        } else if response.status.rawValue == 0 {
            errorMessage = "SA_STR_NETWORK_ERROR".localized
        } else {
            errorMessage = (response.error?.error?.localizedDescription.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil))!
        }

        QMMessageNotificationManager.showNotificationWithTitle("SA_STR_ERROR".localized,
                                                               subtitle: errorMessage,
                                                               type: QMMessageNotificationType.Warning)
        
    }
	
	/**
	Download users accordingly to Constants.QB_USERS_ENVIROMENT
	
	- parameter successBlock: successBlock with sorted [QBUUser] if success
	- parameter errorBlock:   errorBlock with error if request is failed
	*/
    func downloadCurrentEnvironmentUsers(successBlock:(([QBUUser]?) -> Void)?, errorBlock:((NSError) -> Void)?) {

        let enviroment = Constants.QB_USERS_ENVIROMENT
        
        self.usersService.searchUsersWithTags([enviroment]).continueWithBlock {
            [weak self] (task : BFTask!) -> AnyObject! in
			
            if let error = task.error {
                errorBlock?(error)
                return nil
            }
			
            successBlock?(self?.sortedUsers())
            
            return nil
        }
    }
    
    func color(forUser user:QBUUser) -> UIColor {
		
		let defaultColor = UIColor.blackColor()
		
		let users = self.usersService.usersMemoryStorage.unsortedUsers()
		
		guard let givenUser = self.usersService.usersMemoryStorage.userWithID(user.ID) else {
			return defaultColor
		}
		
		let indexOfGivenUser = users.indexOf(givenUser)
			
        if indexOfGivenUser < self.colors.count {
            return self.colors[indexOfGivenUser!]
        } else {
            return defaultColor
        }
    }
	
	/**
	Sorted users
	
	- returns: sorted [QBUUser] from usersService.usersMemoryStorage.unsortedUsers()
	*/
    func sortedUsers() -> [QBUUser]? {
		
		let unsortedUsers = self.usersService.usersMemoryStorage.unsortedUsers()

        let sortedUsers = unsortedUsers.sort({ (user1, user2) -> Bool in
            return user1.login!.compare(user2.login!, options:NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
        })
        
        return sortedUsers
    }
	
	/**
	Sorted users without current user
	
	- returns: [QBUUser]
	*/
	func sortedUsersWithoutCurrentUser() -> [QBUUser]? {
		
		guard let sortedUsers = self.sortedUsers() else {
			return nil
		}
		
		let sortedUsersWithoutCurrentUser = sortedUsers.filter({ $0.ID != self.currentUser()?.ID})
		
		return sortedUsersWithoutCurrentUser
	}
	
    // MARK: QMChatServiceDelegate
    
    override func chatService(chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        super.chatService(chatService, didAddMessageToMemoryStorage: message, forDialogID: dialogID)
        
        if self.authService.isAuthorized {
            self.handleNewMessage(message, dialogID: dialogID)
        }
    }
    
}
