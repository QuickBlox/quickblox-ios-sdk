//
//  UsersDataSource.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/10/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

struct UsersDataSourceConstant {
    static let userCellIdentifier = "UserCell"
}

class UsersDataSource: NSObject {
    
    // MARK: - Properties
    var selectedUsers = [QBUUser]()
    private var users = [QBUUser]()
    
    func update(users: [QBUUser]) {
        for chatUser in users {
            update(user:chatUser)
        }
    }
    
    func update(user: QBUUser) {
        if let localUser = users.filter({ $0.id == user.id }).first {
            //Update local User
            localUser.fullName = user.fullName
            localUser.updatedAt = user.updatedAt
            return
        }
        users.append(user)
    }
    
    func selectUser(at indexPath: IndexPath) {
        
        let user = usersSortedByLastSeen()[indexPath.row]
        if selectedUsers.contains(user) {
            selectedUsers.removeAll(where: { element in element == user })
        } else {
            selectedUsers.append(user)
        }
    }
    
    func user(withID ID: UInt) -> QBUUser? {
        return users.filter{ $0.id == ID }.first
    }
    
    
    func ids(forUsers users: [QBUUser]) -> [NSNumber] {
        
        var result = [NSNumber]()
        
        for user in users {
            result.append(NSNumber(value: user.id))
        }
        return result
    }
    
    func removeAllUsers() {
        users.removeAll()
    }
    
    func usersSortedByFullName() -> [QBUUser] {
        let sortedUsers = unsortedUsersWithoutMe().sorted(by: {
            guard let firstUserName = $0.fullName, let secondUserName = $1.fullName else {
                return false
            }
            return firstUserName < secondUserName
        })
        return sortedUsers
    }
    
    func usersSortedByLastSeen() -> [QBUUser] {
        let sortedUsers = unsortedUsersWithoutMe().sorted(by: {
            guard let firstUpdatedAt = $0.updatedAt, let secondUpdatedAt = $1.updatedAt else {
                return false
            }
            return secondUpdatedAt < firstUpdatedAt
        })
        return sortedUsers
    }
    
    func unsortedUsersWithoutMe() -> [QBUUser] {
        var unsorterUsers = self.users
        let profile = Profile()
        if profile.isFull == false {
            return unsorterUsers
        }
        guard let index = unsorterUsers.index(where: { $0.id == profile.ID }) else {
            return unsorterUsers
        }
        unsorterUsers.remove(at: index)
        return unsorterUsers
    }
    
    //MARK: - Load User from server
    func loadUser(_ id: UInt, completion: ((QBUUser?) -> Void)? = nil) {
        QBRequest.user(withID: id, successBlock: { [weak self] (response, user) in
            self?.update(user: user)
            completion?(user)
        }) { (response) in
            completion?(nil)
        }
    }
}

extension UsersDataSource: UITableViewDataSource {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersSortedByLastSeen().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UsersDataSourceConstant.userCellIdentifier)
            as? UserTableViewCell else {
                return UITableViewCell()
        }
        
        let user = usersSortedByLastSeen()[indexPath.row]
        let selected = selectedUsers.contains(user)
        
        let size = CGSize(width: 32.0, height: 32.0)
        var name = user.fullName ?? ""
        if name.isEmpty {
            name = user.login ?? "Unknown user"
        }
        let userImage = PlaceholderGenerator.placeholder(size: size, title: name)
        cell.fullName = name
        cell.check = selected
        cell.userImage = userImage
        
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let str = String(format: "Select users for call (%tu)", selectedUsers.count)
        return NSLocalizedString(str, comment: "")
    }
}

