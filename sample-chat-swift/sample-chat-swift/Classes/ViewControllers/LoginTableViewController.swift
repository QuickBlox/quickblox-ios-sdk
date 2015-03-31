//
//  LoginTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UsersDataSource.instance.users.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserTableViewCellIdentifier", forIndexPath: indexPath) as! UserTableViewCell

        var user = UsersDataSource.instance.users[indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row+1), color: user.color)
        cell.userDescription = user.fullName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        var user = UsersDataSource.instance.users[indexPath.row]
        self.logInChatWithUser(user);
    }
    
    func logInChatWithUser(user: QBUUser){
        ConnectionManager.instance.logInWithUser(user, completion:{ (success:Bool) -> Void in
            UIAlertView(title: nil, message: "completion!", delegate: nil, cancelButtonTitle: "Ok").show()
        });
    }
    
}
