//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class DialogsViewController: UIViewController, UITableViewDelegate, SWTableViewCellDelegate {
    private var selectedDialog: QBChatDialog?
    private let kChatSegueIdentifier = "goToChat"
    
    @IBOutlet weak var tableView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SVProgressHUD.showWithStatus("Loading", maskType: SVProgressHUDMaskType.Clear)
        
        QBRequest.dialogsWithSuccessBlock({ (response: QBResponse!, dialogs: [AnyObject]!, dialogsUsersIDs: Set<NSObject>!) -> Void in
            
            
            ConnectionManager.instance.dialogs = dialogs as? [QBChatDialog]
            
            var pagedRequest = QBGeneralResponsePage(currentPage: 1, perPage: 100)
            
            QBRequest.usersWithIDs(Array(dialogsUsersIDs), page: pagedRequest, successBlock: {[weak self] (response: QBResponse!, page: QBGeneralResponsePage!, users: [AnyObject]!) -> Void in
                
                SVProgressHUD.showSuccessWithStatus("Completed!")
                
                ConnectionManager.instance.dialogsUsers = users as? [QBUUser]
                
                
                self?.tableView.reloadData()
                
                }, errorBlock: { (response: QBResponse!) -> Void in
                    SVProgressHUD.showErrorWithStatus("Can't download users")
                    println(response.error.error)
            })
            }, errorBlock: { (response: QBResponse!) -> Void in
                SVProgressHUD.showErrorWithStatus("Can't download dialogs")
                println(response.error.error)
        })
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedDialog = ConnectionManager.instance.dialogs![indexPath.row]
        self.performSegueWithIdentifier(kChatSegueIdentifier , sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kChatSegueIdentifier {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = self.selectedDialog
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dialogcell", forIndexPath: indexPath) as! SWTableViewCell
        
        var chatDialog = ConnectionManager.instance.dialogs![indexPath.row]
        
        cell.tag = indexPath.row
        cell.delegate = self
        
        var deleteButton = UIButton()
        deleteButton.setTitle("Delete", forState: UIControlState.Normal)
        deleteButton.backgroundColor = UIColor.redColor()
        deleteButton.tag = 1
        
        switch( chatDialog.type.value ) {
        case QBChatDialogTypePrivate.value:
            cell.detailTextLabel?.text = "private"
            if let users = ConnectionManager.instance.dialogsUsers {
                var recipient = users.filter(){ $0.ID == UInt(chatDialog.recipientID) }[0]
                cell.textLabel?.text = recipient.login ?? recipient.email
                
                var title = "Block"
                var color = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
                if ConnectionManager.instance.privacyManager.isUserInBlockList(recipient) {
                    title = "Unblock"
                    color = UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
                }
                
                var blockButton = UIButton()
                blockButton.setTitle(title, forState: UIControlState.Normal)
                blockButton.backgroundColor = color
                blockButton.tag = 0
                
                cell.rightUtilityButtons = [blockButton, deleteButton]
            }
            
        case QBChatDialogTypeGroup.value:
            cell.detailTextLabel?.text = "group"
            cell.textLabel?.text = chatDialog.name
            cell.rightUtilityButtons = [deleteButton]
        case QBChatDialogTypePublicGroup.value:
            cell.detailTextLabel?.text = "public group"
            cell.textLabel?.text = chatDialog.name
            cell.rightUtilityButtons = [deleteButton]
        default:
            break
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dialogs = ConnectionManager.instance.dialogs {
            return dialogs.count
        }
        return 0
    }
    
    /**
    *  SWTableViewCell delegate methods
    */
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        cell.hideUtilityButtonsAnimated(true)
        
        let cellIndexPath = self.tableView.indexPathForCell(cell)
        var dialog = ConnectionManager.instance.dialogs![cellIndexPath!.row];
        
        // customize action sheet
        if let pressedButton = cell.rightUtilityButtons[index] as? UIButton {
            // block button
            if pressedButton.tag == 0 {
                let actionSheetController: UIAlertController = UIAlertController(title: "Additional actions", message: nil, preferredStyle: .ActionSheet)
                
                let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in }
                actionSheetController.addAction(cancelAction)
                
                let currentUserID = ConnectionManager.instance.currentUser?.ID
                var occupants = dialog.occupantIDs as! [UInt]
                let selectedUserID:UInt = occupants.filter({$0 != currentUserID})[0]
                let selectedUser = ConnectionManager.instance.dialogsUsers!.filter({$0.ID == selectedUserID})[0]
                let userIsBlockedInP2P = ConnectionManager.instance.privacyManager.isUserInBlockListP2P(selectedUser)
                var messageP2P = userIsBlockedInP2P ? "Unblock user in 1-1 chat" : "Block user in 1-1 chat"
                
                let UserP2PAction: UIAlertAction = UIAlertAction(title: messageP2P, style: .Default) { action -> Void in
                    if userIsBlockedInP2P {
                        ConnectionManager.instance.privacyManager.unblockUserInP2PChat(selectedUser)
                                       }
                    else {
                        UIAlertView(title: nil, message: "Note that you will not receive any private message from this user", delegate: nil, cancelButtonTitle: "Ok").show()
                        ConnectionManager.instance.privacyManager.blockUserInP2PChat(selectedUser)
                    }
                    self.tableView!.reloadRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                actionSheetController.addAction(UserP2PAction)
                
                
                var messageGroupChat = userIsBlockedInP2P ? "Unblock user in all group chats" : "Block user in all group chats"
                let userIsBlockedInGroupChats = ConnectionManager.instance.privacyManager.isUserInBlockListP2P(selectedUser)
                
                let blockUserGroupChatAction: UIAlertAction = UIAlertAction(title: messageGroupChat, style: .Default) { action -> Void in
                    if userIsBlockedInGroupChats {
                        ConnectionManager.instance.privacyManager.unblockUserInGroupChats(selectedUser)
                    }
                    else {
                        UIAlertView(title: nil, message: "Note that you will not receive any group chat message from this user", delegate: nil, cancelButtonTitle: "Ok").show()
                        ConnectionManager.instance.privacyManager.blockUserInGroupChats(selectedUser)
                    }
                    self.tableView.reloadRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                actionSheetController.addAction(blockUserGroupChatAction)
                self.presentViewController(actionSheetController, animated: true, completion: nil)
                
            }
            else if pressedButton.tag == 1 {
                // delete button
                
                let alert = SwiftAlert(title: "Warning", message: "Do you really want to delete selected dialog?", cancelButtonTitle: "Cancel", otherButtonTitle: ["Delete"], didClick: { [weak self, weak cellIndexPath] (buttonIndex) -> Void in
                    if buttonIndex == 1 {
                        
                            SVProgressHUD.showWithStatus("Deleting...", maskType: SVProgressHUDMaskType.Clear)
                            
                            QBRequest.deleteDialogWithID(dialog.ID, successBlock: {[weak cellIndexPath] (response: QBResponse!) -> Void in
                                SVProgressHUD.showSuccessWithStatus("Deleted")
                                ConnectionManager.instance.dialogs?.removeAtIndex(cellIndexPath!.row)
                                
                                self?.tableView!.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                                
                                }, errorBlock: { (response: QBResponse!) -> Void in
                                    SVProgressHUD.showErrorWithStatus("Error deleting")
                                    println(response.error.error)
                            })
                        
                    }
                    })
            }
        }
    }
}
