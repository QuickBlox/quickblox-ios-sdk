//
//  NewDialogViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class NewDialogViewController: UsersListTableViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var dialog: QBChatDialog?
    
    private var delegate : SwipeableTableViewCellWithBlockButtons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = SwipeableTableViewCellWithBlockButtons()
        self.delegate.tableView = self.tableView
        self.checkCreateChatButtonState()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateUsers()
        ServicesManager.instance().chatService.addDelegate(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        self.checkCreateChatButtonState()
    }
    
    func updateUsers() {
        if let dialog = self.dialog  {
            
            let filteredUsers = ServicesManager.instance().usersService.users(withoutUser: ServicesManager.instance().currentUser())?.filter({!contains(dialog.occupantIDs as! [UInt], ($0 as QBUUser).ID)})
            self.users = filteredUsers
        }
    }
    
    func checkCreateChatButtonState() {
        self.navigationItem.rightBarButtonItem?.enabled = tableView.indexPathsForSelectedRows()?.count != nil
    }
    
    // called when create chat button is pressed
    @IBAction func createChatButtonPressed(sender: UIButton) {
        sender.enabled = false
        
        let selectedIndexes = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        
        var users: [QBUUser] = []
        
        for indexPath in selectedIndexes {
            let user = self.users![indexPath.row]
            users.append(user)
        }
        
        weak var weakSelf = self
        
        let completion = { (response: QBResponse!, createdDialog: QBChatDialog!) -> Void in
            
            sender.enabled = true
            
            if createdDialog != nil {
                println(createdDialog)
                weakSelf?.processeNewDialog(createdDialog)
            }
            
            if response != nil && response.error != nil {
                println(response.error.error)
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
            }
        }
        
        if let dialog = self.dialog {
            
            if dialog.type == .Group {
                
                SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
                
                NewDialogViewController.updateDialog(self.dialog!, newUsers:users, completion: { (response, dialog) -> Void in
                    
                    if let rightBarButtonItem = weakSelf?.navigationItem.rightBarButtonItem {
                        rightBarButtonItem.enabled = true
                    }
                    
                    if (response.error == nil) {
                        
                        SVProgressHUD.showSuccessWithStatus("STR_DIALOG_CREATED".localized)
        
        
                        weakSelf?.processeNewDialog(dialog)
                        
                    } else {
                        SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
                    }
                    
                })
                
            } else {
                
                let primaryUsers = ServicesManager.instance().usersService.users(withoutUser: ServicesManager.instance().currentUser())?.filter({contains(dialog.occupantIDs as! [UInt], ($0 as QBUUser).ID)})
                
                if primaryUsers != nil && primaryUsers!.count > 0 {
                    users.extend(primaryUsers! as [QBUUser])
                }
                
                let chatName = NewDialogViewController.nameForGroupChatWithUsers(users)

                NewDialogViewController.createChat(chatName, users: users, completion: completion)
            }
            
        } else {
            
            if users.count == 1 {
                
                NewDialogViewController.createChat(nil, users: users, completion: completion)

            } else {
                
                SwiftAlertWithTextField(title: "SA_STR_ENTER_CHAT_NAME".localized, message: nil, showOver:self, didClickOk: { [unowned self] (text) -> Void in
                    
                    var chatName = text
                    
                    if chatName!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
                        chatName = NewDialogViewController.nameForGroupChatWithUsers(users)
                    }
                    
                    NewDialogViewController.createChat(chatName, users: users, completion: completion)
                    
                    }) { () -> Void in
                        
                        // cancel
                        sender.enabled = true
                }
            }
        }
    }
    
    static func updateDialog(dialog:QBChatDialog!, newUsers users:[QBUUser], completion: ((response: QBResponse!, dialog: QBChatDialog!) -> Void)?) {
        
        let usersIDs = users.map{ $0.ID }
        
        ServicesManager.instance().chatService.joinOccupantsWithIDs(usersIDs, toChatDialog: dialog) { (response: QBResponse!, dialog: QBChatDialog!) -> Void in
    
            if (response.error == nil) {
                
                ServicesManager.instance().chatService.notifyUsersWithIDs(usersIDs, aboutAddingToDialog: dialog)
                
                ServicesManager.instance().chatService.notifyAboutUpdateDialog(dialog, occupantsCustomParameters: nil, notificationText: "Added new occupants", completion: nil)
                
                println(dialog)
                
                completion?(response: response, dialog: dialog)
                
            } else {
                
                println(response.error.error)
                
                completion?(response: response, dialog: nil)
    
            }
            
        }
    }
    
    static func nameForGroupChatWithUsers(users:[QBUUser]) -> String {
        
        let chatName = ServicesManager.instance().currentUser()!.login + "_" + ", ".join(users.map({ $0.login ?? $0.email })).stringByReplacingOccurrencesOfString("@", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return chatName
    }
    
    static func createChat(name: String?, users:[QBUUser], completion: ((response: QBResponse!, createdDialog: QBChatDialog!) -> Void)?) {
        
        SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        if users.count == 1 {
            
            ServicesManager.instance().chatService.createPrivateChatDialogWithOpponent(users.first!, completion: { (response: QBResponse!, chatDialog: QBChatDialog!) -> Void in
                
//                SVProgressHUD.showSuccessWithStatus("STR_DIALOG_CREATED".localized)
                
                completion?(response: response, createdDialog: chatDialog)
            })
            
        } else {
            
            ServicesManager.instance().chatService.createGroupChatDialogWithName(name, photo: nil, occupants: users) { (response: QBResponse!, chatDialog: QBChatDialog!) -> Void in
                
                if (chatDialog != nil) {
                    ServicesManager.instance().chatService.notifyUsersWithIDs(chatDialog.occupantIDs, aboutAddingToDialog: chatDialog)
                }
                
//                SVProgressHUD.showSuccessWithStatus("STR_DIALOG_CREATED".localized)
                
                completion?(response: response, createdDialog: chatDialog)
            }
        }
    }
    
    func processeNewDialog(dialog: QBChatDialog!) {
        self.dialog = dialog
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_CHAT".localized, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = self.dialog
                chatVC.shouldFixViewControllersStack = true
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! UserTableViewCell
        let user = self.users![indexPath.row]
        
        cell.user = user
        cell.delegate = self.delegate
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let user = self.users![indexPath.row]
        
        if user.ID == ServicesManager.instance().currentUser()!.ID {
            return 0.0 // hide current user
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog!) {
        
        if (chatDialog.ID == self.dialog?.ID) {
            self.dialog = chatDialog
            self.updateUsers()
            self.tableView.reloadData()
        }
        
    }
    
}
