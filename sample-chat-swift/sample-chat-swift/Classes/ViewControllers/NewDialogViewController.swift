//
//  NewDialogViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class NewDialogViewController: UsersListTableViewController {
    var dialog: QBChatDialog?
    
    private var delegate : SwipeableTableViewCellWithBlockButtons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = SwipeableTableViewCellWithBlockButtons()
        self.delegate.tableView = self.tableView
        self.checkCreateChatButtonState()
        
        if let dialog = self.dialog  {
            
            var users = self.users.filter({!contains(dialog.occupantIDs as! [UInt], ($0 as QBUUser).ID) })
            self.users = users
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        self.checkCreateChatButtonState()
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
            let user = self.users[indexPath.row]
            users.append(user)
        }
        
        let completion = { (response: QBResponse!, createdDialog: QBChatDialog!) -> Void in
            
            sender.enabled = true
            
            if response.error != nil {
                
                println(response.error.error)
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
                
            } else {
                
                println(createdDialog)
                SVProgressHUD.showSuccessWithStatus("STR_DIALOG_CREATED".localized)
                self.processeNewDialog(createdDialog)
                
            }
        }
        
        if let dialog = self.dialog {
            
            if dialog.type == .Group {
                
                self.updateGroupChatWithNewUsers(users)
                
            } else {
                
                let defaultUsers = ConnectionManager.instance.usersDataSource.users
                let occupantIDs: [UInt] = dialog.occupantIDs as! [UInt]
                let primaryUsers: [QBUUser] = defaultUsers.filter { (user : QBUUser) -> Bool in
                    
                    return contains(occupantIDs, user.ID) && user.ID != ServicesManager.instance.currentUser()!.ID
                }
                
                users.extend(primaryUsers)
                
                let chatName = self.nameForGroupChatWithUsers(users)

                self.createChat(chatName, users: users, completion: completion)
            }
            
        } else {
            
            if users.count == 1 {
                
                self.createChat(nil, users: users, completion: completion)

            } else {
                
                SwiftAlertWithTextField(title: "SA_STR_ENTER_CHAT_NAME".localized, message: nil, showOver:self, didClickOk: { [unowned self] (text) -> Void in
                    
                    var chatName = text
                    
                    if chatName!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
                        chatName = self.nameForGroupChatWithUsers(users)
                    }
                    
                    self.createChat(chatName, users: users, completion: completion)
                    
                    }) { () -> Void in
                        
                        // cancel
                        sender.enabled = true
                }
            }
        }
    }
    
    func updateGroupChatWithNewUsers(users:[QBUUser]) {
        self.dialog!.setPushOccupantsIDs(users.map{ $0.ID })
        
        QBRequest.updateDialog(self.dialog, successBlock: { [weak self] (response: QBResponse!, updatedDialog: QBChatDialog!) -> Void in
            
            ServicesManager.instance.chatService.notifyAboutUpdateDialog(updatedDialog, occupantsCustomParameters: nil, notificationText: "Added new occupants", completion: nil)
            
            SVProgressHUD.showSuccessWithStatus("STR_DIALOG_CREATED".localized)
            
            if let leftBarButtonItem = self?.navigationItem.leftBarButtonItem {
                leftBarButtonItem.enabled = true
            }
            
            println(updatedDialog)
            
            self?.processeNewDialog(updatedDialog)
            
            }) { (response: QBResponse!) -> Void in
                self.navigationItem.leftBarButtonItem!.enabled = true
                println(response.error.error)
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
        }
    }
    
    func nameForGroupChatWithUsers(users:[QBUUser]) -> String {
        
        var chatName = ServicesManager.instance.currentUser()!.login + "_" + ", ".join(users.map({ $0.login ?? $0.email }))
        chatName = chatName.stringByReplacingOccurrencesOfString("@", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return chatName
    }
    
    func createChat(name: String?, users:[QBUUser], completion: (response: QBResponse!, createdDialog: QBChatDialog!) -> Void) {
        
        if users.count == 1 {
            
            ServicesManager.instance.chatService.createPrivateChatDialogWithOpponent(users.first!, completion: { (response: QBResponse!, chatDialog: QBChatDialog!) -> Void in
                
//                ServicesManager.instance.chatService.notifyAboutCreatedDialog(chatDialog, excludedOccupantIDs: nil, occupantsCustomParameters: nil, completion: nil)
                
                completion(response: response, createdDialog: chatDialog)
            })
            
        } else {
            
            ServicesManager.instance.chatService.createGroupChatDialogWithName(name, photo: nil, occupants: users) { (response: QBResponse!, chatDialog: QBChatDialog!) -> Void in

//                ServicesManager.instance.chatService.notifyAboutCreatedDialog(chatDialog, excludedOccupantIDs: nil, occupantsCustomParameters: nil, completion: nil)
                
                completion(response: response, createdDialog: chatDialog)
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
    
    /**
    UITableView delegate methods
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! UserTableViewCell
        let user = self.users[indexPath.row]
        
        var cellModel = UserTableViewCellModel(user: user)
        cell.rightUtilityButtons = cellModel.rightUtilityButtons
        cell.user = user
        cell.delegate = self.delegate
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let user = self.users[indexPath.row]
        
        if user.ID == ServicesManager.instance.currentUser()!.ID {
            return 0.0 // hide current user
        }
        
        return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }
    
}
