//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class DialogTableViewCellModel: NSObject {
    
    var detailTextLabelText: String = ""
    var textLabelText: String = ""
    var unreadMessagesCounterLabelText : String?
    var unreadMessagesCounterHiden = true
    var dialogIcon : UIImage?

    init(dialog: QBChatDialog) {
        super.init()
        
        if dialog.type == .Private {
            
            self.detailTextLabelText = "SA_STR_PRIVATE".localized
            
            if dialog.recipientID == -1 {
                return
            }
            
            // Getting recipient from users service.
            if let recipient = ServicesManager.instance().usersService.user(UInt(dialog.recipientID)) {
                self.textLabelText = recipient.login ?? recipient.email
            }
            
        } else if dialog.type == .Group {
            self.detailTextLabelText = "SA_STR_GROUP".localized
        } else {
            self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
        }
        
        if self.textLabelText.isEmpty {
            // group chat
            
            if let dialogName = dialog.name {
                self.textLabelText = dialogName
            }
        }
        
        // Unread messages counter label
        
        if (dialog.unreadMessagesCount > 0) {
            
            var trimmedUnreadMessageCount : String
            
            if dialog.unreadMessagesCount > 99 {
                trimmedUnreadMessageCount = "99+"
            } else {
                trimmedUnreadMessageCount = String(format: "%d", dialog.unreadMessagesCount)
            }
            
            self.unreadMessagesCounterLabelText = trimmedUnreadMessageCount
            self.unreadMessagesCounterHiden = false
            
        } else {
            
            self.unreadMessagesCounterLabelText = nil
            self.unreadMessagesCounterHiden = true
        }
        
        // Dialog icon
        
        if dialog.type == .Private {
            self.dialogIcon = UIImage(named: "user")
        } else {
            self.dialogIcon = UIImage(named: "group")
        }
    }
}

class DialogsViewController: UITableViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    
    private var didEnterBackgroundDate: NSDate?
    
    var shouldUpdateDialogsAfterLogIn = false
    
    // MARK: - ViewController overrides
    
    override func viewDidLoad() {

        self.navigationItem.title = "SA_STR_WELCOME".localized + " " + ServicesManager.instance().currentUser()!.fullName
        
        self.navigationItem.leftBarButtonItem = self.createLogoutButton()

        ServicesManager.instance().chatService.addDelegate(self)
        
        weak var weakSelf = self
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            
            SVProgressHUD.showWithStatus("SA_STR_CONNECTING_TO_CHAT".localized, maskType: SVProgressHUDMaskType.Clear)
            
            if QBChat.instance().isLoggedIn() {
                weakSelf?.getLastUpdatedDialogs()
            } else {
                weakSelf?.shouldUpdateDialogsAfterLogIn = true
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        self.joinToAllDialogs()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.getDialogs(nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = sender as? QBChatDialog
            }
        }
    }
    
    // MARK: - Notification handling
    
    func didEnterBackgroundNotification() {
        self.didEnterBackgroundDate = NSDate()
    }
    
    // MARK: - Actions
    
    func createLogoutButton() -> UIBarButtonItem {
        
        let logoutButton = UIBarButtonItem(title: "SA_STR_LOGOUT".localized, style: UIBarButtonItemStyle.Plain, target: self, action: Selector("logoutAction"))
        
        return logoutButton
    }
    
    @IBAction func logoutAction() {
        
        SVProgressHUD.showWithStatus("SA_STR_LOGOUTING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        // Logouts from Quickblox, clears cache.
        ServicesManager.instance().logoutWithCompletion { () -> Void in
            
            SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
            
            NSNotificationCenter.defaultCenter().removeObserver(self)
            ServicesManager.instance().chatService.removeDelegate(self)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - DataSource Action
    
    func getDialogs(extendedRequest: Dictionary<String, AnyObject>?) {
        
        var shouldShowSuccessStatus = false
        
        if DialogsViewController.dialogs().count == 0 {
            shouldShowSuccessStatus = true
            SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
        }
        
        // Retrieves all dialogs from Quickblox.
        ServicesManager.instance().chatService.allDialogsWithPageLimit(kDialogsPageLimit, extendedRequest:extendedRequest, iterationBlock: { (response: QBResponse!, dialogObjects: [AnyObject]!, dialogsUsersIDs: Set<NSObject>!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

        }) { (response: QBResponse!) -> Void in
            
            if response == nil || response?.error != nil {
                
                SVProgressHUD.showErrorWithStatus("SA_STR_CANT_DOWNLOAD_DIALOGS".localized)
                
                if response != nil {
                    println(response.error.error)
                }
            }
            else {
        
                if shouldShowSuccessStatus {
                    SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                }
            }
        }
    }
    
    func getLastUpdatedDialogs() {
        
        if let didEnterBackgroundDate = self.didEnterBackgroundDate {
            
            let extendedRequest = ["last_message_date_sent[gte]" : Int(didEnterBackgroundDate.timeIntervalSince1970)]
    
            self.getDialogs(extendedRequest)
            
        } else {
            
            self.getDialogs(nil)
            
        }
        
    }
    
    // MARK: - DataSource
    
    static func dialogs() -> Array<QBChatDialog> {
        
        let descriptors = [NSSortDescriptor(key: "lastMessageDate", ascending: false)]
        // Returns dialogs sorted by last message date.
        return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsWithSortDescriptors(descriptors) as! Array<QBChatDialog>
    }
    
    // MARK: - Helper
    
    func joinToAllDialogs() {
        
        for dialog : QBChatDialog in DialogsViewController.dialogs() {
            
            // Notifies occupants that user left the dialog.
            if dialog.type != QBChatDialogType.Private {
                
                ServicesManager.instance().chatService.joinToGroupDialog(dialog, failed: { (error: NSError!) -> Void in

                })
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = DialogsViewController.dialogs().count
        
        return numberOfRowsInSection
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dialogcell", forIndexPath: indexPath) as! DialogTableViewCell
        
        let chatDialog = DialogsViewController.dialogs()[indexPath.row]
        
        cell.tag = indexPath.row
        cell.dialogID = chatDialog.ID
        
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
        cell.dialogLastMessage?.text = chatDialog.lastMessageText
        cell.dialogName?.text = cellModel.textLabelText
        cell.dialogTypeImage.image = cellModel.dialogIcon
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.hidden = cellModel.unreadMessagesCounterHiden
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let dialog = DialogsViewController.dialogs()[indexPath.row]
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            
            let dialog = DialogsViewController.dialogs()[indexPath.row]
            
            let alert = AlertView(title:"SA_STR_WARNING".localized , message:"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized , cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_DELETE".localized], didClick: { [weak self] (buttonIndex) -> Void in
                
                if buttonIndex != 1 {
                    return
                }
                
                SVProgressHUD.showWithStatus("SA_STR_DELETING".localized, maskType: SVProgressHUDMaskType.Clear)
                
                let deleteDialogBlock = { (dialog: QBChatDialog!) -> Void in
                    
                    // Deletes dialog from server and cache.
                    ServicesManager.instance().chatService.deleteDialogWithID(dialog.ID, completion: { (response: QBResponse!) -> Void in
                        
                        if response.success {
                            
                            SVProgressHUD.showSuccessWithStatus("SA_STR_DELETED".localized)
                            
                        } else {
                            
                            SVProgressHUD.showErrorWithStatus("SA_STR_ERROR_DELETING".localized)
                            println(response.error.error)
                        }
                    })
                }
                
                if dialog.type == QBChatDialogType.Private {
                    
                    deleteDialogBlock(dialog)
                    
                } else {
                    
                    var occupantIDs =  dialog.occupantIDs.filter( {$0 as! UInt != ServicesManager.instance().currentUser().ID} )
                    
                    dialog.occupantIDs = occupantIDs
                    
                    // Notifies occupants that user left the dialog.
                    ServicesManager.instance().chatService.notifyAboutUpdateDialog(dialog, occupantsCustomParameters: nil, notificationText:"User \(ServicesManager.instance().currentUser().login) has left the dialog", completion: { (error: NSError!) -> Void in
                        
                        deleteDialogBlock(dialog)
                    })
                }
            })
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "SA_STR_DELETE".localized
    }
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog!) {
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogsToMemoryStorage chatDialogs: [AnyObject]!) {
        
        for dialog : QBChatDialog in chatDialogs as! [QBChatDialog] {
            
            // Performing join to the group dialogs.
            if dialog.type != QBChatDialogType.Private {
                ServicesManager.instance().chatService.joinToGroupDialog(dialog, failed: { (error: NSError!) -> Void in
                    
                })
            }
        }
        
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog!) {
        // Performing join to the group dialogs.
        if chatDialog.type != QBChatDialogType.Private {
            ServicesManager.instance().chatService.joinToGroupDialog(chatDialog, failed: { (error: NSError!) -> Void in
                
            })
        }
        
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String!) {
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didAddMessagesToMemoryStorage messages: [AnyObject]!, forDialogID dialogID: String!) {
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        self.tableView.reloadData()
    }
    
    // MARK: QMChatConnectionDelegate
    
    func chatServiceChatDidAccidentallyDisconnect(chatService: QMChatService!) {
        
    }
    
    func chatServiceChatDidConnect(chatService: QMChatService!) {
        SVProgressHUD.showSuccessWithStatus("SA_STR_CONNECTED".localized)
        SVProgressHUD.showWithStatus("SA_STR_LOG_INING".localized, maskType: SVProgressHUDMaskType.Clear)
    }
    
    func chatServiceChatDidLogin() {
        
        self.joinToAllDialogs()
        
        SVProgressHUD.showSuccessWithStatus("SA_STR_LOG_IN".localized)
        
        if self.shouldUpdateDialogsAfterLogIn {
            self.shouldUpdateDialogsAfterLogIn = false
            self.getLastUpdatedDialogs()
        }
    }
    
    func chatServiceChatDidNotLoginWithError(error: NSError!) {
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
    }
    
    func chatServiceChatDidReconnect(chatService: QMChatService!) {
        SVProgressHUD.showSuccessWithStatus("SA_STR_RECONNECTED".localized)
    }
}
