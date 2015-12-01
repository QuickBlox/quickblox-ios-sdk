//
//  GroupChatUsersInfo.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/14/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class ChatUsersInfoTableViewController: UsersListTableViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var occupantsIDs: [UInt] = []
    var dialog: QBChatDialog?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ServicesManager.instance().chatService.addDelegate(self)
    }
    
    func updateUsers() {
        if let _ = self.dialog  {
            
            self.setupUsers(ServicesManager.instance().sortedUsers(ServicesManager.instance().usersService.usersMemoryStorage.unsortedUsers() as! [QBUUser]))
        }
    }
    
    override func setupUsers(users: [QBUUser]) {
        
        var filteredUsers = users.filter({($0 as QBUUser).ID != ServicesManager.instance().currentUser().ID})
        
        if let _ = self.dialog  {
            
            filteredUsers = filteredUsers.filter({(self.dialog!.occupantIDs as! [UInt]).contains(($0 as QBUUser).ID)})
        }
        
        super.setupUsers(filteredUsers)
        
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
    
    func chatService(chatService: QMChatService!, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog!) {
        
        if (chatDialog.ID == self.dialog!.ID) {
            self.dialog = chatDialog
            self.updateUsers()
            self.tableView.reloadData()
        }
        
    }
    
}
