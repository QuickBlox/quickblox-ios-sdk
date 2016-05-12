//
//  GroupChatUsersInfo.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/14/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class ChatUsersInfoTableViewController: UsersListTableViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var dialog: QBChatDialog!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUsers()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.dialog.occupantIDs?.count >= ServicesManager.instance().usersService.usersMemoryStorage.unsortedUsers().count {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        
        ServicesManager.instance().chatService.addDelegate(self)
    }
	
    func updateUsers() {
        ServicesManager.instance().usersService.getUsersWithIDs(self.dialog.occupantIDs!) .continueWithBlock { (task :BFTask) -> AnyObject? in
            
            if task.result?.count >= ServicesManager.instance().usersService.usersMemoryStorage.unsortedUsers().count {
                self.navigationItem.rightBarButtonItem?.enabled = false
            }
            else {
                self.navigationItem.rightBarButtonItem?.enabled = true
            }
            
            if task.result?.count > 0 {
                self.setupUsers(task.result! as! [QBUUser])
            }
            
            return nil
        }
    }
	
    override func setupUsers(users: [QBUUser]) {
        
        
        let filteredUsers = users.filter({self.dialog.occupantIDs!.contains(NSNumber(unsignedInteger: $0.ID))})
        
        let sortedUsers = filteredUsers.sort({ (user1, user2) -> Bool in
            return user1.login!.compare(user2.login!, options:NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedAscending
        })
        super.setupUsers(sortedUsers)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_SELECT_OPPONENTS".localized {
            if let newDialogViewController = segue.destinationViewController as? NewDialogViewController {
                newDialogViewController.dialog = self.dialog
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func chatService(chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if (chatDialog.ID == self.dialog!.ID) {
            self.dialog = chatDialog
            self.updateUsers()
            self.tableView.reloadData()
        }
		
    }
    
}
