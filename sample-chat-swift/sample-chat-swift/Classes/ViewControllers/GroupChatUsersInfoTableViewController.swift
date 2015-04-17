//
//  GroupChatUsersInfo.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/14/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class GroupChatUsersInfoTableViewController: LoginTableViewController {
    var occupantsIDs: [UInt] = []
    private var _chatDialog: QBChatDialog?
    var chatDialog: QBChatDialog? {
        get {
            return _chatDialog
        }
        set( newChatDialog ){
            _chatDialog = newChatDialog
            var occupants = newChatDialog!.occupantIDs as! [UInt]
            var tmpOccupantsIDs = occupants.filter({$0 != ConnectionManager.instance.currentUser!.ID})
            occupantsIDs = tmpOccupantsIDs
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! UserTableViewCell
        
        let currentOccupantID = occupantsIDs[indexPath.row]
        if let dialogsUsers = ConnectionManager.instance.dialogsUsers {
            let filteredUsers = dialogsUsers.filter({$0.ID == currentOccupantID })
            if !filteredUsers.isEmpty {
                let currentUser = filteredUsers[0]
                cell.userDescription = currentUser.email ?? currentUser.login
            }
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return occupantsIDs.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
