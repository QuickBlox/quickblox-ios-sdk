//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class DialogTableViewCellModel: NSObject {
    
    var rightUtilityButtons: [UIButton]!
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
            
            let users = ConnectionManager.instance.usersDataSource.users
            
            var filteredUsers = users.filter(){ $0.ID == UInt(dialog.recipientID) }
            
            if !filteredUsers.isEmpty {
                var recipient = filteredUsers[0]
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
        
        rightUtilityButtons = DialogTableViewCellModel.deleteButtons()
        
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
            self.dialogIcon = UIImage(named: "chatRoomIcon")
        } else {
            self.dialogIcon = UIImage(named: "GroupChatIcon")
        }
    }
    
    static func deleteButtons() -> [UIButton]{
        var deleteButton = UIButton()
        
        deleteButton.setTitle("SA_STR_DELETE".localized, forState: UIControlState.Normal)
        deleteButton.backgroundColor = UIColor.redColor()
        deleteButton.tag = 1
        
        return [deleteButton]
    }
    
}

class DialogsViewController: UIViewController, UITableViewDelegate, QMChatServiceDelegate, QMChatConnectionDelegate {
    @IBOutlet weak var tableView:UITableView!
    
    private var delegate : SwipeableTableViewCellWithBlockButtons!
    private var didEnterBackgroundDate: NSDate?
    
    @IBAction private func goToOpponents(sender: AnyObject?){
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_SELECT_OPPONENTS".localized, sender: nil)
    }
    
    // MARK: - ViewController overrides
    
    override func viewDidLoad() {

        self.navigationItem.title = "SA_STR_WELCOME".localized + ", " + ServicesManager.instance.currentUser()!.login
        
        self.delegate = SwipeableTableViewCellWithBlockButtons()
        self.delegate.tableView = self.tableView
        
        self.navigationItem.leftBarButtonItem = self.createLogoutButton()

        ServicesManager.instance.chatService.addDelegate(self)
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            
            SVProgressHUD.showWithStatus("SA_STR_CONNECTING_TO_CHAT".localized, maskType: SVProgressHUDMaskType.Clear)
            self.getLastUpdatedDialogs()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEnterBackgroundNotification", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        for dialog : QBChatDialog in DialogsViewController.dialogs() {
            
            if dialog.type != QBChatDialogType.Private {
                ServicesManager.instance.chatService.joinToGroupDialog(dialog, failed: { (error: NSError!) -> Void in
                    
                })
            }
        }
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
    
    func logoutAction() {
        
        SVProgressHUD.showWithStatus("SA_STR_LOGOUTING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        ServicesManager.instance.logout { () -> Void in
            
            SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
            
            NSNotificationCenter.defaultCenter().removeObserver(self)
            ServicesManager.instance.chatService.removeDelegate(self)
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
        
        ServicesManager.instance.chatService.allDialogsWithPageLimit(kDialogsPageLimit, extendedRequest:extendedRequest, iterationBlock: { (response: QBResponse!, dialogObjects: [AnyObject]!, dialogsUsersIDs: Set<NSObject>!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

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
            
            let extendedRequest = ["last_message_date_sent[gte]" : didEnterBackgroundDate.timeIntervalSince1970]
    
            self.getDialogs(extendedRequest)
            
        } else {
            
            self.getDialogs(nil)
            
        }
        
    }
    
    // MARK: - DataSource
    
    static func dialogs() -> Array<QBChatDialog> {
        
        let descriptors = [NSSortDescriptor(key: "lastMessageDate", ascending: false)]
        
        return ServicesManager.instance.chatService.dialogsMemoryStorage.dialogsWithSortDescriptors(descriptors) as! Array<QBChatDialog>
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInSection = DialogsViewController.dialogs().count
        
        return numberOfRowsInSection
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_DIALOG".localized, forIndexPath: indexPath) as! DialogTableViewCell
        
        let chatDialog = DialogsViewController.dialogs()[indexPath.row]
        
        cell.tag = indexPath.row
        cell.delegate = delegate
        cell.dialogID = chatDialog.ID
        
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
        cell.dialogLastMessage?.text = chatDialog.lastMessageText
        cell.dialogName?.text = cellModel.textLabelText
        cell.dialogTypeImage.image = cellModel.dialogIcon
        cell.rightUtilityButtons = cellModel.rightUtilityButtons
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.hidden = cellModel.unreadMessagesCounterHiden
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let dialog = DialogsViewController.dialogs()[indexPath.row]
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog!) {
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogsToMemoryStorage chatDialogs: [AnyObject]!) {
        
        for dialog : QBChatDialog in chatDialogs as! [QBChatDialog] {
            
            if dialog.type != QBChatDialogType.Private {
                ServicesManager.instance.chatService.joinToGroupDialog(dialog, failed: { (error: NSError!) -> Void in
                    
                })
            }
        }
        
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog!) {
        
        if chatDialog.type != QBChatDialogType.Private {
            ServicesManager.instance.chatService.joinToGroupDialog(chatDialog, failed: { (error: NSError!) -> Void in
                
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
        SVProgressHUD.showSuccessWithStatus("SA_STR_LOG_IN".localized)
    }
    
    func chatServiceChatDidNotLoginWithError(error: NSError!) {
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
    }
    
    func chatServiceChatDidReconnect(chatService: QMChatService!) {
        SVProgressHUD.showSuccessWithStatus("SA_STR_RECONNECTED".localized)
    }
}
