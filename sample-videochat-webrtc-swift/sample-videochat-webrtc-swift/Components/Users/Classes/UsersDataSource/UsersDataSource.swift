//
//  UsersDataSource.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/10/18.
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
    
    private let fullNameSortSelector = #selector(getter: QBUUser.fullName)
    private let lastSeenSortSelector = #selector(getter: QBUUser.createdAt)
    private var usersSet: Set<QBUUser> = []
    private var currentUser: QBUUser?
    
    init(currentUser: QBUUser?) {
        super.init()
        
        self.currentUser = currentUser
    }
    
    // MARK: - Public methods
    
    func setUsers(_ users: [QBUUser]) -> Bool {
        let usersSet = Set<QBUUser>(users)
        
        for user in users {
            
            user.fullName = user.fullName ?? "User id: \(user.id) (no full name)"
        }
        if self.usersSet != usersSet {
            self.usersSet.removeAll()
            self.usersSet = usersSet
            
            for user in selectedUsers {
                if !self.usersSet.contains(user) {
                    selectedUsers.removeAll(where: { element in element == user })
                }
            }
            return true
        }
        return false
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
        return usersSet.filter{ $0.id == ID }.first
    }
    
    
    func ids(forUsers users: [QBUUser]) -> [NSNumber] {
        
        var result = [NSNumber]()
        
        for user in users {
            result.append(NSNumber(value: user.id))
        }
        return result
    }
    
    func removeAllUsers() {
        usersSet.removeAll()
    }
    
    func usersSortedByFullName() -> [QBUUser] {
        return sortUsers(bySEL: fullNameSortSelector)
    }
    
    func usersSortedByLastSeen() -> [QBUUser] {
        return sortUsers(bySEL: lastSeenSortSelector)
    }
    
    func sortUsers(bySEL selector: Selector) -> [QBUUser] {
        // Create sort Descriptor
        let usersSortDescriptor = NSSortDescriptor(key: NSStringFromSelector(selector), ascending: false)
        guard let sorted = (unsortedUsersWithoutMe() as NSArray).sortedArray(using: [usersSortDescriptor]) as? [QBUUser] else {
            return unsortedUsersWithoutMe()
        }
        return sorted
    }
    
    func unsortedUsersWithoutMe() -> [QBUUser] {
        var unsorterUsers = Array(usersSet)
        unsorterUsers.removeAll(where: { element in element == currentUser })
        return unsorterUsers
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
        let userImage = PlaceholderGenerator.placeholder(size: size, title: user.fullName)
        
        cell.fullName = user.fullName
        cell.check = selected
        cell.userImage = userImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let str = String(format: "Select users for call (%tu)", selectedUsers.count)
        return NSLocalizedString(str, comment: "")
    }
}

