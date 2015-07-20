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

        var cell = cell as! DialogTableViewCell
        
        if let strongTableView = tableView {
            cell.hideUtilityButtonsAnimated(true)
            let cellIndexPath = strongTableView.indexPathForCell(cell)
            // customize action sheet
            if let pressedButton = cell.rightUtilityButtons[index] as? UIButton {
                if pressedButton.tag == 1 {
                    // delete button
                    
                    let alert = SwiftAlert(title: "SA_STR_WARNING".localized, message: "SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized, cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_DELETE".localized], didClick: { [weak self] (buttonIndex) -> Void in
                        if buttonIndex == 1 {
                            
                            SVProgressHUD.showWithStatus("SA_STR_DELETING".localized, maskType: SVProgressHUDMaskType.Clear)
                            assert(cell.dialogID != "")
                            
                            let deleteDialogBlock = { (dialog: QBChatDialog!) -> Void in
                                
                                ServicesManager.instance().chatService.deleteDialogWithID(dialog.ID, completion: { (response: QBResponse!) -> Void in
                                    
                                    if response.success {
                                        
                                        SVProgressHUD.showSuccessWithStatus("SA_STR_DELETED".localized)
                                        
                                    } else {
                                        
                                        SVProgressHUD.showErrorWithStatus("SA_STR_ERROR_DELETING".localized)
                                        println(response.error.error)
                                    }
                                })
                            }
                            
                            if let dialog = ServicesManager.instance().chatService.dialogsMemoryStorage.chatDialogWithID(cell.dialogID) {
                                
                                if dialog.type == QBChatDialogType.Private {
                                    
                                    deleteDialogBlock(dialog)
                                    
                                } else {
                                
                                    var occupantIDs =  dialog.occupantIDs.filter( {$0 as! UInt != ServicesManager.instance().currentUser().ID} )
                                    
                                    dialog.occupantIDs = occupantIDs
                                    
                                    ServicesManager.instance().chatService.notifyAboutUpdateDialog(dialog, occupantsCustomParameters: nil, notificationText:"User \(ServicesManager.instance().currentUser().login) has left the dialog", completion: { (error: NSError!) -> Void in
                                        
                                        deleteDialogBlock(dialog)
                                    })
                                }
                            }
                        }
                        })
                }
            }
        }
    }
}
