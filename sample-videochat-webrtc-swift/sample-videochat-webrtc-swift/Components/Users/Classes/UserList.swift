//
//  UserList.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 28.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox

class UserList {
    //MARK: - Properties
    var fetched: [QBUUser] = []
    var selected: Set<UInt> = []
    var isLoadAll = false
    var currentPage: UInt = 1 {
        didSet {
            if currentPage == 1 {
                users.removeAll()
            }
        }
    }
    
    private var users: [UInt: QBUUser] = [:]
    
    //MARK: - Public Methods
    func fetchWithPage(_ pageNumber: UInt, completion: DownloadUsersCompletion?) {
        let page = QBGeneralResponsePage(currentPage: pageNumber, perPage: UsersConstant.perPage)
        let extendedRequest: [String: String] = ["order": "desc date last_request_at"]
        QBRequest.users(withExtendedRequest: extendedRequest,
                        page: page,
                        successBlock: { [weak self] (response, page, users) in

            self?.isLoadAll = users.count < page.perPage
            self?.currentPage = pageNumber
            self?.append(users)
            completion?(users, nil)
        }, errorBlock: { [weak self] (response) in
            if let error = response.error?.error, error._code == QBResponseStatusCode.notFound.rawValue {
                self?.isLoadAll = true
            }
            completion?([], response.error?.error)
        })
    }
    
    func fetchNext(completion: DownloadUsersCompletion?) {
        let nextPage = currentPage + 1
        fetchWithPage(nextPage) { (users, error) in
            completion?(users, error);
        }
    }
    
    func append( _ users: [QBUUser]) {
        let profile = Profile()
        for user in users {
            if user.id == profile.ID {
                continue
            }
            self.users[user.id] = user
        }
        fetched = sortUsers(Array(self.users.values))
    }
    
    //MARK: - Private Methods
    private func sortUsers(_ users: [QBUUser]) -> [QBUUser] {
        let sortedUsers = users.sorted(by: {
            guard let firstUpdatedAt = $0.lastRequestAt, let secondUpdatedAt = $1.lastRequestAt else {
                return false
            }
            return firstUpdatedAt > secondUpdatedAt
        })
        return sortedUsers
    }
}
