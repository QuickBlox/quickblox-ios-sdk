//
//  SwipeableTableViewCellWithBlockButtons.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/10/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

class SwipeableTableViewCellWithBlockButtons : NSObject, SWTableViewCellDelegate
{
    
    var tableView: UITableView?
    /**
    *  SWTableViewCell delegate methods
    */
    
    func swipeableTableViewCell(cell: SWTableViewCell!, didTriggerRightUtilityButtonWithIndex index: Int) {
        assert(cell.isKindOfClass(UserTableViewCell))
        
        var cell = cell as! UserTableViewCell
        
        if let strongTableView = tableView {
            cell.hideUtilityButtonsAnimated(true)
            let cellIndexPath = strongTableView.indexPathForCell(cell)
            // customize action sheet
            if let pressedButton = cell.rightUtilityButtons[index] as? UIButton {
                // block button
                if pressedButton.tag == 0 {
                    let actionSheetController = UIAlertDialog(style: UIAlertDialogStyle.ActionSheet, title: "SA_STR_ADDITIONAL_ACTIONS".localized, andMessage: nil)
                    
                    /// P2P block
                    let selectedUser = cell.user!
                    let userIsBlockedInP2P = ConnectionManager.instance.privacyManager.isUserInBlockListP2P(selectedUser)
                    var messageP2P = userIsBlockedInP2P ? "SA_STR_UNBLOCK_USER_P2P_CHAT".localized : "SA_STR_BLOCK_USER_P2P_CHAT".localized
                    
                    actionSheetController.addButtonWithTitle(messageP2P, andHandler: { (index: Int) -> Void in
                        if userIsBlockedInP2P {
                            ConnectionManager.instance.privacyManager.unblockUserInP2PChat(selectedUser)
                        }
                        else {
                            UIAlertView(title: nil, message: "SA_STR_NOTE_YOU_WILL_NOT_RECEIVE_AMY_P2P_MESSAGES".localized, delegate: nil, cancelButtonTitle: "SA_STR_OK".localized).show()
                            ConnectionManager.instance.privacyManager.blockUserInP2PChat(selectedUser)
                        }
                        // update block/unblock title
                        strongTableView.reloadRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                    })
                    
                    /// Groupchat block
                    let userIsBlockedInGroupChats = ConnectionManager.instance.privacyManager.isUserInBlockListGroupChats(selectedUser)
                    var messageGroupChat = userIsBlockedInGroupChats ? "SA_STR_UNBLOCK_USER_GROUP_CHATS".localized : "SA_STR_BLOCK_USER_GROUP_CHATS".localized
                    
                    actionSheetController.addButtonWithTitle(messageGroupChat, andHandler: { (index: Int) -> Void in
                        if userIsBlockedInGroupChats {
                            ConnectionManager.instance.privacyManager.unblockUserInGroupChats(selectedUser)
                        }
                        else {
                            UIAlertView(title: nil, message: "SA_STR_NOTE_YOU_WILL_NOT_RECEIVE_AMY_GROUP_MESSAGES".localized, delegate: nil, cancelButtonTitle: "SA_STR_OK".localized).show()
                            ConnectionManager.instance.privacyManager.blockUserInGroupChats(selectedUser)
                        }
                        // update block/unblock title
                        strongTableView.reloadRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                    })
                    
                    let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
                    actionSheetController.showInViewController(appDelegate.window!.rootViewController!)
                    
                }
                else if pressedButton.tag == 1 {
                    // delete button
                    
                    let alert = SwiftAlert(title: "SA_STR_WARNING".localized, message: "SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized, cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_DELETE".localized], didClick: { [weak self] (buttonIndex) -> Void in
                        if buttonIndex == 1 {
                            
                            SVProgressHUD.showWithStatus("SA_STR_DELETING".localized, maskType: SVProgressHUDMaskType.Clear)
                            assert(cell.dialogID != "")
                            QBRequest.deleteDialogWithID(cell.dialogID, successBlock: {(response: QBResponse!) -> Void in
                                SVProgressHUD.showSuccessWithStatus("SA_STR_DELETED".localized)
                                ConnectionManager.instance.dialogs?.removeAtIndex(cellIndexPath!.row)
                                
                                strongTableView.deleteRowsAtIndexPaths([cellIndexPath!], withRowAnimation: UITableViewRowAnimation.Automatic)
                                
                                }, errorBlock: { (response: QBResponse!) -> Void in
                                    SVProgressHUD.showErrorWithStatus("SA_STR_ERROR_DELETING".localized)
                                    println(response.error.error)
                            })
                        }
                        })
                }
            }
        }
    }
}
