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
    
    func logInChatWithUser(user: QBUUser){
        SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        ConnectionManager.instance.logInWithUser(user, completion:{ (success:Bool,  errorMessage: String?) -> Void in
            
            if( success ){
                SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)
                
                let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                dispatch_after(delay, dispatch_get_main_queue(), {[weak self] () ->  Void in
                    
                    self?.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                    })
            }
            else{
                SVProgressHUD.showErrorWithStatus(errorMessage)
            }
        })
    }
    
    /**
    UITableView delegate methods
    */
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ConnectionManager.instance.usersDataSource.users.count
    }

    internal override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_USER".localized, forIndexPath: indexPath) as! UserTableViewCell

        let user = ConnectionManager.instance.usersDataSource.users[indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row+1), color: user.color)
        cell.userDescription = user.fullName
        cell.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        var user = ConnectionManager.instance.usersDataSource.users[indexPath.row]
        self.logInChatWithUser(user);
    }
    
}
