//
//  LoginTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class LoginTableViewController: UsersListTableViewController {

    // MARK: ViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.reloadData()
    }
    
    // MARK: Actions
    
    func logInChatWithUser(user: QBUUser) {
        
        SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        weak var weakSelf = self

        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logInWithUser(user, completion:{ (success:Bool,  errorMessage: String?) -> Void in

            if (success) {
                
                SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)

                weakSelf?.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                
            } else {
                
                SVProgressHUD.showErrorWithStatus(errorMessage)
            }

        })
    }
    
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_USER".localized, forIndexPath: indexPath) as! UserTableViewCell
        
        let user = self.users![indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row + 1), color: ServicesManager.instance().usersService.color(forUser: user))
        cell.userDescription = "Login as " + user.fullName
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let user = self.users![indexPath.row]
        user.password = "x6Bt0VDy5"
        
        self.logInChatWithUser(user)
    }
    
}
