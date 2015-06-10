//
//  GroupChatUsersInfo.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/14/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class ChatUsersInfoTableViewController: UsersListTableViewController, QMChatServiceDelegate {
    var occupantsIDs: [UInt] = []
    var dialog: QBChatDialog?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUsers()
        ServicesManager.instance.chatService.addDelegate(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        ServicesManager.instance.chatService.removeDelegate(self)
    }
    
    func updateUsers() {
        if let chatDialog = self.dialog  {
            
            var users = self.users.filter({contains(chatDialog.occupantIDs as! [UInt], ($0 as QBUUser).ID) && ($0 as QBUUser).ID != ServicesManager.instance.currentUser()!.ID})
            self.users = users
        }
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
    
    func chatService(chatService: QMChatService!, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog!) {
        
        if (chatDialog.ID == self.dialog!.ID) {
            self.dialog = chatDialog
            self.updateUsers()
            self.tableView.reloadData()
        }
        
    }
    
}
