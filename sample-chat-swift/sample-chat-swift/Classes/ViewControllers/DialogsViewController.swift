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
		
		switch (dialog.type){
		case .PublicGroup:
			self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
		case .Group:
			self.detailTextLabelText = "SA_STR_GROUP".localized
		case .Private:
			self.detailTextLabelText = "SA_STR_PRIVATE".localized
			
			if dialog.recipientID == -1 {
				return
			}
			
			// Getting recipient from users service.
			if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(dialog.recipientID)) {
				self.textLabelText = recipient.login ?? recipient.email!
			}
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
    private var observer: NSObjectProtocol?
    // MARK: - ViewController overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // calling awakeFromNib due to viewDidLoad not being called by instantiateViewControllerWithIdentifier
        self.navigationItem.title = ServicesManager.instance().currentUser()?.login!
        
        self.navigationItem.leftBarButtonItem = self.createLogoutButton()
        
        ServicesManager.instance().chatService.addDelegate(self)
        
        self.observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            
            if !QBChat.instance().isConnected {
                SVProgressHUD.showWithStatus("SA_STR_CONNECTING_TO_CHAT".localized, maskType: SVProgressHUDMaskType.Clear)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DialogsViewController.didEnterBackgroundNotification), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        if (QBChat.instance().isConnected) {
            self.getDialogs()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
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
        
        let logoutButton = UIBarButtonItem(title: "SA_STR_LOGOUT".localized, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(DialogsViewController.logoutAction))
        return logoutButton
    }
    
    @IBAction func logoutAction() {
        
        SVProgressHUD.showWithStatus("SA_STR_LOGOUTING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        if !QBChat.instance().isConnected {

            SVProgressHUD.showErrorWithStatus("You're not connected to the chat.")
            return
        }
        
        let logoutGroup = dispatch_group_create()
        dispatch_group_enter(logoutGroup)
        
        let deviceIdentifier = UIDevice.currentDevice().identifierForVendor!.UUIDString
		
        QBRequest.unregisterSubscriptionForUniqueDeviceIdentifier(deviceIdentifier, successBlock: { (response: QBResponse!) -> Void in
            //
            print("Successfuly unsubscribed from push notifications")
            dispatch_group_leave(logoutGroup)
			
			}) { (error: QBError?) -> Void in
                //
                print("Push notifications unsubscribe failed")
				dispatch_group_leave(logoutGroup)
        }
		
        ServicesManager.instance().lastActivityDate = nil
        
        dispatch_group_notify(logoutGroup, dispatch_get_main_queue()) {
            [weak self] () -> Void in
            // Logouts from Quickblox, clears cache.
			guard let strongSelf = self else { return }
			ServicesManager.instance().logoutWithCompletion {
				
                NSNotificationCenter.defaultCenter().removeObserver(strongSelf)
				NSNotificationCenter.defaultCenter().removeObserver(strongSelf.observer!)
                
                strongSelf.observer = nil
                
				ServicesManager.instance().chatService.removeDelegate(strongSelf)
                
				strongSelf.navigationController?.popViewControllerAnimated(true)
				
				SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
			}
        }
    }
	
    // MARK: - DataSource Action
	
    func getDialogs() {
		
        if let lastActivityDate = ServicesManager.instance().lastActivityDate {
			
			ServicesManager.instance().chatService.fetchDialogsUpdatedFromDate(lastActivityDate, andPageLimit: kDialogsPageLimit, iterationBlock: { (response: QBResponse?, dialogObjects: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
				
				}, completionBlock: { (response: QBResponse?) -> Void in
					
					guard let unwrappedResponse = response else {
						print("fetchDialogsUpdatedFromDate error")
						return
					}
					
					guard unwrappedResponse.success else {
						print("fetchDialogsUpdatedFromDate error \(response)")
						return
					}
					
					ServicesManager.instance().lastActivityDate = NSDate()
			})
        }
        else {
            SVProgressHUD.showWithStatus("SA_STR_LOADING_DIALOGS".localized, maskType: SVProgressHUDMaskType.Clear)
			
			ServicesManager.instance().chatService.allDialogsWithPageLimit(kDialogsPageLimit, extendedRequest: nil, iterationBlock: { (response: QBResponse?, dialogObjects: [QBChatDialog]?, dialogsUsersIDS: Set<NSNumber>?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
				
				}, completion: { (response: QBResponse?) -> Void in
					
					guard response != nil && response!.success else {
						SVProgressHUD.showErrorWithStatus("SA_STR_FAILED_LOAD_DIALOGS".localized)
						return
					}
					
					SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
					ServicesManager.instance().lastActivityDate = NSDate()
					
			})
			
        }
    }

    // MARK: - DataSource
    
	func dialogs() -> [QBChatDialog]? {
        
        // Returns dialogs sorted by updatedAt date.
        return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAtWithAscending(false)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let dialogs = self.dialogs() {
			return dialogs.count
		}
        return 0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dialogcell", forIndexPath: indexPath) as! DialogTableViewCell
		
		guard let chatDialog = self.dialogs()?[indexPath.row] else {
			return cell
		}
		
        
        cell.tag = indexPath.row
        cell.dialogID = chatDialog.ID!
        
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
        
		guard let dialog = self.dialogs()?[indexPath.row] else {
			return
		}
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
		guard editingStyle == UITableViewCellEditingStyle.Delete else {
			return
		}
		
		
		guard let dialog = self.dialogs()?[indexPath.row] else {
			return
		}
		
		_ = AlertView(title:"SA_STR_WARNING".localized , message:"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized , cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_DELETE".localized], didClick:{ (buttonIndex) -> Void in
			
			guard buttonIndex == 1 else {
				return
			}
			
			SVProgressHUD.showWithStatus("SA_STR_DELETING".localized, maskType: SVProgressHUDMaskType.Clear)
			
			let deleteDialogBlock = { (dialog: QBChatDialog!) -> Void in
				
				// Deletes dialog from server and cache.
				ServicesManager.instance().chatService.deleteDialogWithID(dialog.ID!, completion: { (response: QBResponse!) -> Void in
					
					guard response.success else {
						SVProgressHUD.showErrorWithStatus("SA_STR_ERROR_DELETING".localized)
						print(response.error?.error)
						return
					}
					
					SVProgressHUD.showSuccessWithStatus("SA_STR_DELETED".localized)
				})
			}
			
			if dialog.type == QBChatDialogType.Private {
				
				deleteDialogBlock(dialog)
				
			} else {
				
				// group
				
				let occupantIDs = dialog.occupantIDs!.filter( {$0 != ServicesManager.instance().currentUser()?.ID} )
				
				dialog.occupantIDs = occupantIDs
				
				let notificationMessage = "User \(ServicesManager.instance().currentUser()?.login!) " + "SA_STR_USER_HAS_LEFT".localized
				// Notifies occupants that user left the dialog.
				ServicesManager.instance().chatService.sendNotificationMessageAboutLeavingDialog(dialog, withNotificationText: notificationMessage, completion: { (error : NSError?) -> Void in
					deleteDialogBlock(dialog)
				})
			}
		})
		
    }
	
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "SA_STR_DELETE".localized
    }
	
    // MARK: - QMChatServiceDelegate
	
    func chatService(chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
		
        self.tableView.reloadData()
    }
	
    func chatService(chatService: QMChatService,didUpdateChatDialogsInMemoryStorage dialogs: [QBChatDialog]){
		
        self.tableView.reloadData()
    }
	
    func chatService(chatService: QMChatService, didAddChatDialogsToMemoryStorage chatDialogs: [QBChatDialog]) {
        
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog) {
        
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String) {
        
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService, didAddMessagesToMemoryStorage messages: [QBChatMessage], forDialogID dialogID: String) {
        
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String){
        
        self.tableView.reloadData()
    }
    
    // MARK: QMChatConnectionDelegate
    
    func chatServiceChatDidFailWithStreamError(error: NSError) {
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
        
    }
    
    func chatServiceChatDidAccidentallyDisconnect(chatService: QMChatService) {
        SVProgressHUD.showErrorWithStatus("SA_STR_DISCONNECTED".localized)
    }
    
    func chatServiceChatDidConnect(chatService: QMChatService) {
        SVProgressHUD.showSuccessWithStatus("SA_STR_CONNECTED".localized, maskType:.Clear)
    
        self.getDialogs()
    }
    
    func chatService(chatService: QMChatService,chatDidNotConnectWithError error: NSError){
        SVProgressHUD.showErrorWithStatus(error.localizedDescription)
    }
	
	
    func chatServiceChatDidReconnect(chatService: QMChatService) {
        SVProgressHUD.showSuccessWithStatus("SA_STR_CONNECTED".localized, maskType: .Clear)
        self.getDialogs()
    }

}
