//
//  GroupChatUsersInfo.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/14/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class ChatUsersInfoTableViewController: UsersListTableViewController {
    var occupantsIDs: [UInt] = []
    var dialog: QBChatDialog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}
