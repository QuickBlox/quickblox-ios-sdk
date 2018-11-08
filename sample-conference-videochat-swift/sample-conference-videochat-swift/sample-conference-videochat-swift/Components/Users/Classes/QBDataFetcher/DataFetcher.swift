//
//  DataFetcher.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 11.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct DataFetcherConstant {
    static let pageLimit: UInt = 50
    static let pageSize: UInt = 50
}

class DataFetcher {
    // MARK: Class Methods
    
    class func fetchDialogs(_ completion: @escaping (_ dialogs: [QBChatDialog]) -> Void,
                            failure: @escaping (_ errorDescription: String?) -> Void) {
        let extendedRequest = ["type[in]": "2"]
        
        var t_request: ((_ responsePage: QBResponsePage, _ allDialogs: [QBChatDialog]) -> Void)?
        
        var allDialogsTempArr = [QBChatDialog]()
        
        let request: ((QBResponsePage, [QBChatDialog]) -> Void) = { responsePage, allDialogs in
            QBRequest.dialogs(for: responsePage, extendedRequest: extendedRequest,
                              successBlock: { response, dialogs, dialogsUsersIDs, page in
                                
                                allDialogsTempArr = allDialogs
                                allDialogsTempArr.append(contentsOf: dialogs)
                                page.skip += dialogs.count
                                let isLastPage = page.totalEntries <= page.skip
                                if isLastPage == false {
                                    t_request?(page, allDialogsTempArr)
                                } else {
                                    completion(allDialogsTempArr)
                                    t_request = nil
                                }
                                
            }, errorBlock: { response in
                t_request = nil
                guard let message = DataFetcher.handleEror(response.error) else {
                    return
                }
                failure(message)
            })
        }
        t_request = request
        let allDialogs: [QBChatDialog] = []
        request(QBResponsePage(limit: Int(DataFetcherConstant.pageLimit)), allDialogs)
    }
    
    class func fetchUsers(_ completion: @escaping (_ users: [QBUUser]?) -> Void) {
        var t_request: ((_ page: QBGeneralResponsePage?, _ allUsers: [QBUUser]?) -> Void)?
        var allUsersTempArray = [QBUUser]()
        let request: ((QBGeneralResponsePage?, [QBUUser]?) -> Void)? = { page, allUsers in
            
            guard let allUsers = allUsers, let currentUserTags = Core.instance.currentUser?.tags else {
                return }
            
            QBRequest.users(withTags: currentUserTags, page: page,
                            successBlock: { response, page, users in
                                
                                page.currentPage = page.currentPage + 1
                                allUsersTempArray = allUsers
                                allUsersTempArray.append(contentsOf: users)
                                let isLastPage = page.currentPage * page.perPage >= page.totalEntries
                                let cancel = isLastPage ? true : false
                                if cancel == false {
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
        let allUsers: [QBUUser] = []
        request?(QBGeneralResponsePage(currentPage: 1, perPage: DataFetcherConstant.pageSize), allUsers)
    }
    
    class func excludeCurrentUser(fromUsersArray users: [QBUUser]?) -> [QBUUser]? {
        let currentUser = Core.instance.currentUser
        if let users = users {
            let contains = users.contains(where: {$0 == currentUser})
            if contains {
                let mutableArray = users
                return mutableArray.filter({$0 != currentUser})
            }
        }
        return users
    }
    
    private class func handleEror(_ error: QBError?) -> String? {
        guard let error = error else {
            return nil
        }
        
        if let suberror = error.error {
            return suberror.localizedDescription
        } else if let reasons = error.reasons {
            let description = (reasons.compactMap({ (key, value) -> String in
                return "\(key): \(value)"
            }) as Array).joined(separator: "\n")
            return description
        } else {
            return nil
        }
    }
}
