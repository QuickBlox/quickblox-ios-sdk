//
//  UsersService.swift
//  sample-chat-swift
//
//  Created by Injoit on 7/17/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

/**
*  Service responsible for working with users. 
*/
class UsersService: NSObject {
    
    var contactListService : QMContactListService!
    
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
    
    init(contactListService: QMContactListService) {
        super.init()
        self.contactListService = contactListService
    }
    
    
    func cachedUser(completion:(([QBUUser]) -> Void)?) {
        
        weak var weakSelf = self
        
        // check memory storage
        
        let memoryUsers = self.contactListService!.usersMemoryStorage.usersSortedByKey("fullName", ascending: true)
        
        if (memoryUsers != nil && memoryUsers.count > 0) {
            
            var sortedUsers = memoryUsers.sorted({ (user1, user2) -> Bool in
                return (user1.login as NSString).compare(user2.login, options:NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
            }) as! [QBUUser]
            
            completion?(sortedUsers)
            
            return
        }
    
        // check persistent storage
        
        QMContactListCache.instance().usersSortedBy("login", ascending: true) { (users: [AnyObject]!) -> Void in
            
            var sortedUsers = users.sorted({ (user1, user2) -> Bool in
                return (user1.login as NSString).compare(user2.login, options:NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
            }) as! [QBUUser]
            
            weakSelf?.contactListService!.usersMemoryStorage.addUsers(sortedUsers)
            
            completion?(sortedUsers)
        }
    }
    
    func downloadLatestUsers(success:(([QBUUser]) -> Void)?, error:((QBResponse) -> Void)?) {
        
        weak var weakSelf = self
        
        let enviroment = Constants.QB_USERS_ENVIROMENT
        
        QBRequest.usersWithTags([enviroment], successBlock: { (response: QBResponse!, page: QBGeneralResponsePage!, users: [AnyObject]!) -> Void in
            
            var sortedUsers = users.sorted({ (user1, user2) -> Bool in
                return (user1.login as NSString).compare(user2.login, options:NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
            }) as! [QBUUser]

            weakSelf?.contactListService!.usersMemoryStorage.addUsers(sortedUsers)
            QMContactListCache.instance().insertOrUpdateUsers(sortedUsers, completion: nil)
            
            success?(sortedUsers)
            
            }) { (response: QBResponse!) -> Void in
            
                error?(response)
                
                NSLog("error: %@", response)
        }
    }
    
    func user(userID: UInt) -> QBUUser? {
    
        return self.contactListService.usersMemoryStorage.userWithID(userID)
    }
    
    func users() -> [QBUUser]? {
        return self.contactListService.usersMemoryStorage.unsortedUsers() as? [QBUUser]
    }
    
    func users(withoutUser user: QBUUser) -> [QBUUser]? {
        
        return (self.contactListService.usersMemoryStorage.unsortedUsers() as! [QBUUser]).filter({$0.ID != user.ID})
    }
    
    func color(forUser user:QBUUser) -> UIColor {
        
        let userIndex = find(self.contactListService.usersMemoryStorage.unsortedUsers() as! [QBUUser], user)
        
        if userIndex < self.colors.count {
            return self.colors[userIndex!]
        } else {
            return UIColor.blackColor()
        }
    }
}