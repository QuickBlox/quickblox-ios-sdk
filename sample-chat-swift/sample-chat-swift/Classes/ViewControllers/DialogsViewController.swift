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
		case .publicGroup:
			self.detailTextLabelText = "SA_STR_PUBLIC_GROUP".localized
		case .group:
			self.detailTextLabelText = "SA_STR_GROUP".localized
		case .private:
			self.detailTextLabelText = "SA_STR_PRIVATE".localized
			
			if dialog.recipientID == -1 {
				return
			}
			
			// Getting recipient from users service.
			if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(dialog.recipientID)) {
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
        
        if dialog.type == .private {
            self.dialogIcon = UIImage(named: "user")
        } else {
            self.dialogIcon = UIImage(named: "group")
        }
    }
    
    
}

class DialogsViewController: UITableViewController, QMChatServiceDelegate, QMChatConnectionDelegate, QMAuthServiceDelegate {
    private var didEnterBackgroundDate: NSDate?
    private var observer: NSObjectProtocol?
    // MARK: - ViewController overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // calling awakeFromNib due to viewDidLoad not being called by instantiateViewControllerWithIdentifier
        self.navigationItem.title = ServicesManager.instance().currentUser()?.login!
        
        self.navigationItem.leftBarButtonItem = self.createLogoutButton()
        
        ServicesManager.instance().chatService.addDelegate(self)
        
        ServicesManager.instance().authService.add(self)
        
        self.observer = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: OperationQueue.main) { (notification) -> Void in
            
            if !QBChat.instance().isConnected {
                SVProgressHUD.show(withStatus: "SA_STR_CONNECTING_TO_CHAT".localized, maskType: SVProgressHUDMaskType.clear)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(DialogsViewController.didEnterBackgroundNotification), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        if (QBChat.instance().isConnected) {
            self.getDialogs()
        }
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
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
        
        let logoutButton = UIBarButtonItem(title: "SA_STR_LOGOUT".localized, style: UIBarButtonItemStyle.plain, target: self, action: #selector(DialogsViewController.logoutAction))
        return logoutButton
    }
    
    @IBAction func logoutAction() {
        
        if !QBChat.instance().isConnected {

            SVProgressHUD.showError(withStatus: "Error")
            return
        }
        
        SVProgressHUD.show(withStatus: "SA_STR_LOGOUTING".localized, maskType: SVProgressHUDMaskType.clear)
        
        ServicesManager.instance().logoutUserWithCompletion { [weak self] (boolValue) -> () in
            
            guard let strongSelf = self else { return }
            if boolValue {
                NotificationCenter.default.removeObserver(strongSelf)
                
                if strongSelf.observer != nil {
                    NotificationCenter.default.removeObserver(strongSelf.observer!)
                    strongSelf.observer = nil
                }
                
                ServicesManager.instance().chatService.removeDelegate(strongSelf)
                ServicesManager.instance().authService.remove(strongSelf)
                
                ServicesManager.instance().lastActivityDate = nil;
                
                let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                
                SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
            }
        }
    }
	
    // MARK: - DataSource Action
	
    func getDialogs() {
		
        if let lastActivityDate = ServicesManager.instance().lastActivityDate {
			
			ServicesManager.instance().chatService.fetchDialogsUpdated(from: lastActivityDate as Date, andPageLimit: kDialogsPageLimit, iterationBlock: { (response, dialogObjects, dialogsUsersIDs, stop) -> Void in
				
				}, completionBlock: { (response) -> Void in
					
                    if (response.isSuccess) {
                        
                        ServicesManager.instance().lastActivityDate = NSDate()
                    }
			})
        }
        else {
            
            SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOGS".localized, maskType: SVProgressHUDMaskType.clear)
			
			ServicesManager.instance().chatService.allDialogs(withPageLimit: kDialogsPageLimit, extendedRequest: nil, iterationBlock: { (response: QBResponse?, dialogObjects: [QBChatDialog]?, dialogsUsersIDS: Set<NSNumber>?, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
				
				}, completion: { (response: QBResponse?) -> Void in
					
					guard response != nil && response!.isSuccess else {
						SVProgressHUD.showError(withStatus: "SA_STR_FAILED_LOAD_DIALOGS".localized)
						return
					}
					
					SVProgressHUD.showSuccess(withStatus: "SA_STR_COMPLETED".localized)
					ServicesManager.instance().lastActivityDate = NSDate()
			})
        }
    }

    // MARK: - DataSource
    
	func dialogs() -> [QBChatDialog]? {
        
        // Returns dialogs sorted by updatedAt date.
        return ServicesManager.instance().chatService.dialogsMemoryStorage.dialogsSortByUpdatedAt(withAscending: false)
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let dialogs = self.dialogs() {
			return dialogs.count
		}
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 64.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "dialogcell", for: indexPath) as! DialogTableViewCell
        
        if ((self.dialogs()?.count)! < indexPath.row) {
            return cell
        }
        
        guard let chatDialog = self.dialogs()?[indexPath.row] else {
            return cell
        }
        
        cell.isExclusiveTouch = true
        cell.contentView.isExclusiveTouch = true
        
        cell.tag = indexPath.row
        cell.dialogID = chatDialog.id!
        
        let cellModel = DialogTableViewCellModel(dialog: chatDialog)
        
        cell.dialogLastMessage?.text = chatDialog.lastMessageText
        cell.dialogName?.text = cellModel.textLabelText
        cell.dialogTypeImage.image = cellModel.dialogIcon
        cell.unreadMessageCounterLabel.text = cellModel.unreadMessagesCounterLabelText
        cell.unreadMessageCounterHolder.isHidden = cellModel.unreadMessagesCounterHiden
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if (ServicesManager.instance().isProcessingLogOut!) {
            return
        }
        
        guard let dialog = self.dialogs()?[indexPath.row] else {
            return
        }
        
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard editingStyle == UITableViewCellEditingStyle.delete else {
            return
        }
        
        
        guard let dialog = self.dialogs()?[indexPath.row] else {
            return
        }
        
        _ = AlertView(title:"SA_STR_WARNING".localized , message:"SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized , cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_DELETE".localized], didClick:{ (buttonIndex) -> Void in
            
            guard buttonIndex == 1 else {
                return
            }
            
            SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized, maskType: SVProgressHUDMaskType.clear)
            
            let deleteDialogBlock = { (dialog: QBChatDialog!) -> Void in
                
                // Deletes dialog from server and cache.
                ServicesManager.instance().chatService.deleteDialog(withID: dialog.id!, completion: { (response: QBResponse!) -> Void in
                    
                    guard response.isSuccess else {
                        SVProgressHUD.showError(withStatus: "SA_STR_ERROR_DELETING".localized)
                        print(response.error?.error)
                        return
                    }
                    
                    SVProgressHUD.showSuccess(withStatus: "SA_STR_DELETED".localized)
                })
            }
            
            if dialog.type == QBChatDialogType.private {
                
                deleteDialogBlock(dialog)
                
            } else {
                
                // group
                
                let occupantIDs = dialog.occupantIDs!.filter({ (number) -> Bool in
                    
                    return number.uintValue != ServicesManager.instance().currentUser()?.id
                })
                
                dialog.occupantIDs = occupantIDs
                let userLogin = ServicesManager.instance().currentUser()?.login ?? ""
                let notificationMessage = "User \(userLogin) " + "SA_STR_USER_HAS_LEFT".localized
                // Notifies occupants that user left the dialog.
                ServicesManager.instance().chatService.sendNotificationMessageAboutLeaving(dialog, withNotificationText: notificationMessage, completion: { (error) -> Void in
                    deleteDialogBlock(dialog)
                })
            }
        })
    }
	
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        
        return "SA_STR_DELETE".localized
    }
    
    // MARK: - QMChatServiceDelegate
	
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
		
        self.reloadTableViewIfNeeded()
    }
	
    func chatService(_ chatService: QMChatService,didUpdateChatDialogsInMemoryStorage dialogs: [QBChatDialog]){
		
        self.reloadTableViewIfNeeded()
    }
	
    func chatService(_ chatService: QMChatService, didAddChatDialogsToMemoryStorage chatDialogs: [QBChatDialog]) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didDeleteChatDialogWithIDFromMemoryStorage chatDialogID: String) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessagesToMemoryStorage messages: [QBChatMessage], forDialogID dialogID: String) {
        
        self.reloadTableViewIfNeeded()
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String){
        
        self.reloadTableViewIfNeeded()
    }

    // MARK: QMChatConnectionDelegate
    
    func chatServiceChatDidFail(withStreamError error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
        
    }
    
    func chatServiceChatDidAccidentallyDisconnect(_ chatService: QMChatService) {
        SVProgressHUD.showError(withStatus: "SA_STR_DISCONNECTED".localized)
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType:.clear)
        if !ServicesManager.instance().isProcessingLogOut! {
            self.getDialogs()
        }
    }
    
    func chatService(_ chatService: QMChatService,chatDidNotConnectWithError error: Error){
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
	
	
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        SVProgressHUD.showSuccess(withStatus: "SA_STR_CONNECTED".localized, maskType: .clear)
        if !ServicesManager.instance().isProcessingLogOut! {
            self.getDialogs()
        }
    }
    
    // MARK: - Helpers
    func reloadTableViewIfNeeded() {
        if !ServicesManager.instance().isProcessingLogOut! {
            self.tableView.reloadData()
        }
    }
}
