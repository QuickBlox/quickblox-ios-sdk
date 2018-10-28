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
        for user in objects {
            if user.id == UInt(ID) {
                return user
            }
        }
        return nil
    }
    
    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        var cell = UITableViewCell()
        guard let userCell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserTableViewCell else { return cell }
        
        let user: QBUUser = objects[indexPath.row] as QBUUser
        let selected: Bool = self.selectedObjects.contains(user)
        let size = CGSize(width: 32, height: 32)
        let userImage: UIImage? = PlaceholderGenerator.placeholder(size: size, title: user.fullName)
        
        userCell.fullName = user.fullName
        userCell.check = selected
        userCell.userImage = userImage
        cell = userCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let str = String(format: "Select users to create chat dialog with (%tu)", selectedObjects.count)
        return NSLocalizedString(str, comment: "")
    }
}
