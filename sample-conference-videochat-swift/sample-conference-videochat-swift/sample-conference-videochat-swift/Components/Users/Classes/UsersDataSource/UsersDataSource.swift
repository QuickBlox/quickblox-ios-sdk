//
//  UsersDataSource.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 17.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

class UsersDataSource: MainDataSource<QBUUser> {
    
    // MARK: Construction
    convenience init() {
        self.init(sortSelector: #selector(getter: QBUUser.fullName))
    }
    
    // MARK: Public
    func user(withID ID: Int) -> QBUUser? {
        
        for user: QBUUser? in objects {
            
            if user?.id == UInt(ID) {
                return user
            }
        }
        
        return nil
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! UserTableViewCell
        
        let user: QBUUser = objects[indexPath.row] as QBUUser
        var selected: Bool? = nil

            selected = self.selectedObjects.contains(user)
        
        
        let userImage: UIImage? = PlaceholderGenerator.placeholder(title: user.fullName)
        
        cell.fullName = user.fullName
        cell.check = selected
        cell.userImage = userImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let str = String(format: "Select users to create chat dialog with (%tu)", selectedObjects.count)
        
        return NSLocalizedString(str, comment: "")
    }
}
