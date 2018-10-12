//
//  QBDataFetcher.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 11.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

let kQBPageLimit: UInt = 50
let kQBPageSize: UInt = 50

class QBDataFetcher {
    
    class func fetchDialogs(_ completion: @escaping (_ dialogs: [Any]?) -> Void) {
        
        let extendedRequest = ["type[in]": "2"]
        
        var t_request: ((_ responsePage: QBResponsePage?, _ allDialogs: [AnyHashable]?) -> Void)?
        var allDialogsTempArr: [AnyHashable]?
        let request: ((QBResponsePage?, [AnyHashable]?) -> Void)? = { responsePage, allDialogs in
            
            QBRequest.dialogs(for: responsePage!, extendedRequest: extendedRequest, successBlock: { response, dialogs, dialogsUsersIDs, page in
                
                allDialogsTempArr = allDialogs
                allDialogsTempArr?.append(contentsOf: dialogs)
                
                var cancel = false
                page.skip += dialogs.count
                
                if page.totalEntries <= page.skip {
                    
                    cancel = true
                }
                
                if !cancel {
                    
                    t_request?(page, allDialogsTempArr)
                } else {
                    
                    completion(allDialogsTempArr)
                    
                    t_request = nil
                }
                
            }, errorBlock: { response in
                
                completion(allDialogsTempArr)
                
                t_request = nil
            })
        }
        
        t_request = request
        let allDialogs: [AnyHashable] = []
        request?(QBResponsePage(limit: Int(kQBPageLimit)), allDialogs)
    }
    
    class func fetchUsers(_ completion: @escaping (_ users: [Any]?) -> Void) {
        
        //        weak var weakSelf = self
        var t_request: ((_ page: QBGeneralResponsePage?, _ allUsers: [AnyHashable]?) -> Void)?
        var allUsersTempArray: [QBUUser]?
        let request: ((QBGeneralResponsePage?, [AnyHashable]?) -> Void)? = { page, allUsers in
            
            //            let strongSelf = weakSelf
            
            QBRequest.users(withTags: (QBCore.instance.currentUser?.tags)!, page: page, successBlock: { response, page, users in
                page.currentPage = page.currentPage + 1
                
                allUsersTempArray = allUsers as? [QBUUser]
                allUsersTempArray?.append(contentsOf: users)
                
                var cancel = false
                if page.currentPage * page.perPage >= page.totalEntries {
                    cancel = true
                }
                
                if !cancel {
                    t_request?(page, allUsersTempArray)
                } else {
                    
                    completion(self.excludeCurrentUser(fromUsersArray: allUsersTempArray))
                    
                    t_request = nil
                }
                
            }, errorBlock: { response in
                
                completion(self.excludeCurrentUser(fromUsersArray: allUsersTempArray))
                
                t_request = nil
            })
        }
        
        t_request = request
        let allUsers: [AnyHashable] = []
        request?(QBGeneralResponsePage(currentPage: 1, perPage: kQBPageSize), allUsers)
    }
    
    class func excludeCurrentUser(fromUsersArray users: [QBUUser]?) -> [QBUUser]? {
        
        let currentUser: QBUUser? = QBCore.instance.currentUser
        if let anUser = currentUser, let usersArr = users {
            let contains = usersArr.contains(where: {$0 == anUser})
            if contains {
                let mutableArray = users
                return mutableArray?.filter({$0 != anUser})
            }
        }
        return users
    }
}
