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
    
    var currentDialogID : String = ""
    
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
        
        if self.currentDialogID == dialogID {
            return
        }
        
        if message.senderID == self.currentUser().ID {
            return
        }
        
        let dialog = self.chatService.dialogsMemoryStorage.chatDialogWithID(dialogID)
        var dialogName = "New message"
        
        if dialog.type != QBChatDialogType.Private {
            
            if dialog.name != nil {
                dialogName = dialog.name!
            }
    
        } else {
            
            if let user = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(dialog.recipientID)) {
                dialogName = user.login!
            }
        }
        
        TWMessageBarManager.sharedInstance().hideAll()
        TWMessageBarManager.sharedInstance().showMessageWithTitle(dialogName, description: message.text, type: TWMessageBarMessageType.Info)
    }
    
    // MARK: dialog utils
    
    func joinAllGroupDialogs() {
        let allDialogs: Array<QBChatDialog> = ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAtWithAscending(false) as! Array<QBChatDialog>
        for dialog : QBChatDialog in allDialogs {
            
            // Notifies occupants that user left the dialog.
            if dialog.type != QBChatDialogType.Private {
                
                self.chatService.joinToGroupDialog(dialog, completion: { (error: NSError?) -> Void in
                    if (error != nil) {
                        NSLog("Failed to join dialog with error: %@", error!)
                    }
                })
            }
        }
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
    
    override func handleErrorResponse(response: QBResponse!) {
        super.handleErrorResponse(response)
        
        if !self.isAuthorized() {
            return;
        }
        
        var errorMessage : String
        
        if response.status.rawValue == 502 {
            errorMessage = "Bad Gateway, please try again"
        } else if response.status.rawValue == 0 {
            errorMessage = "Connection network error, please try again"
        } else {
            errorMessage = (response.error?.error?.localizedDescription.stringByReplacingOccurrencesOfString("(", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil).stringByReplacingOccurrencesOfString(")", withString: "", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil))!
        }
        
        TWMessageBarManager.sharedInstance().hideAll()
        TWMessageBarManager.sharedInstance().showMessageWithTitle("Error", description: errorMessage, type: TWMessageBarMessageType.Error)
        
    }
    
    func downloadLatestUsers(success:(([QBUUser]!) -> Void)?, error:((NSError!) -> Void)?) {

        let enviroment = Constants.QB_USERS_ENVIROMENT
        
        self.usersService.searchUsersWithTags([enviroment]).continueWithBlock {
            [weak self] (task : BFTask!) -> AnyObject! in
            if (task.error != nil) {
                error?(task.error)
                return nil
            }
            
            let sortedUsers = self?.sortedUsers(task.result as! [QBUUser])
            success?(sortedUsers)
            
            return nil
        }
    }
    
    func color(forUser user:QBUUser) -> UIColor {
        
        let users = self.usersService.usersMemoryStorage.unsortedUsers() as? [QBUUser]
        let userIndex = (users!).indexOf(self.usersService.usersMemoryStorage.userWithID(user.ID)!)
        
        if userIndex < self.colors.count {
            return self.colors[userIndex!]
        } else {
            return UIColor.blackColor()
        }
    }
    
    func sortedUsers(unsortedUsers: [QBUUser]) -> [QBUUser] {
        
        let sortedUsers = unsortedUsers.sort({ (user1, user2) -> Bool in
            return (user1.login! as NSString).compare(user2.login!, options:NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
        })
        
        return sortedUsers
    }
    
    // MARK: QMChatServiceDelegate
    
    override func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        super.chatService(chatService, didAddMessageToMemoryStorage: message, forDialogID: dialogID)
        self.handleNewMessage(message, dialogID: dialogID)
    }
    
}
