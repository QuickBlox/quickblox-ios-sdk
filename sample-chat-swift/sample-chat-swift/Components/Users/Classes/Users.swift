//
//  Users.swift
//  sample-chat-swift
//
//  Created by Injoit on 28.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox

class Users {
    //MARK: - Properties
    var users: [UInt: QBUUser] = [:]
    var selected: Set<QBUUser> = []

    //MARK: - Public Methods
    func users(_ usersIDs: [NSNumber], completion: DownloadUsersCompletion?) {
        var members: [UInt: QBUUser] = [:]
        var newUsersIDs: [String] = []
        usersIDs.forEach { (userID) in
            if let user = users[userID.uintValue] {
                members[userID.uintValue] = user
            } else {
                newUsersIDs.append(userID.stringValue)
            }
        }
        if newUsersIDs.isEmpty {
            completion?(Array(members.values), nil)
            return
        }
        let page = QBGeneralResponsePage(currentPage: 1, perPage: UsersConstant.perPage)
        QBRequest.users(withIDs: newUsersIDs, page: page, successBlock: { [weak self] (response, page, users) in
            guard let self = self else {
                completion?(Array(members.values), nil)
                return
            }
            self.append(users)
            completion?(Array(members.values) + users, nil)
        }, errorBlock: { (response) in
            completion?(Array(members.values), response.error?.error)
        })
    }
    
    func append( _ users: [QBUUser]) {
        for user in users {
            self.users[user.id] = user
        }
    }
}
