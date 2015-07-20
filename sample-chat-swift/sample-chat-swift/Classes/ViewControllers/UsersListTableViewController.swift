//
//  UsersListTableViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 6/3/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class UsersListTableViewController: UITableViewController {
    
    var users : [QBUUser]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakSelf = self
        

        ServicesManager.instance().usersService.cachedUser { (users: [QBUUser]) -> Void in
            
            if users.count > 0 {
                
                weakSelf?.setupUsers(users)
                
            } else {
                
                SVProgressHUD.showWithStatus("Loading users", maskType: SVProgressHUDMaskType.Clear)
                
                ServicesManager.instance().usersService.downloadLatestUsers({ (users: [QBUUser]) -> Void in
                    
                    SVProgressHUD.showSuccessWithStatus("Completed")
                    weakSelf?.setupUsers(users)
                    
                    }, error: { (response: QBResponse) -> Void in
                        
                        SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
                })
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let users = self.users {
            
            return self.users!.count
            
        } else {
            
            return 0
        }
    }
    
    internal override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_USER".localized, forIndexPath: indexPath) as! UserTableViewCell
        
        let user = self.users![indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row + 1), color: ServicesManager.instance().usersService.color(forUser: user))
        cell.userDescription = user.fullName
        cell.tag = indexPath.row
        
        return cell
    }
    
    private func setupUsers(users: [QBUUser]) {
        self.users = users
        self.tableView.reloadData()
    }
}