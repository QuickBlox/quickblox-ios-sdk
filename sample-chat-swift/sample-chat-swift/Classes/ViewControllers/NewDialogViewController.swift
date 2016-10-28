 //
 //  NewDialogViewController.swift
 //  sample-chat-swift
 //
 //  Created by Anton Sokolchenko on 4/1/15.
 //  Copyright (c) 2015 quickblox. All rights reserved.
 //
 
 
 class NewDialogViewController: UsersListTableViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var dialog: QBChatDialog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkCreateChatButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ServicesManager.instance().chatService.addDelegate(self)
        
        if let _ = self.dialog {
            self.navigationItem.rightBarButtonItem?.title = "SA_STR_DONE".localized
            self.title = "SA_STR_ADD_OCCUPANTS".localized
        } else {
            self.navigationItem.rightBarButtonItem?.title = "SA_STR_CREATE".localized
            self.title = "SA_STR_NEW_CHAT".localized
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkCreateChatButtonState()
    }
    
    func updateUsers() {
        if let users = ServicesManager.instance().sortedUsers() {
            
            self.setupUsers(users: users)
            self.checkCreateChatButtonState()
        }
    }
    
    override func setupUsers(users: [QBUUser]) {
        
        var filteredUsers = users.filter({($0 as QBUUser).id != ServicesManager.instance().currentUser()?.id})
        
        if let _ = self.dialog  {
            
            filteredUsers = filteredUsers.filter({!(self.dialog!.occupantIDs as! [UInt]).contains(($0 as QBUUser).id)})
        }
        
        super.setupUsers(users: filteredUsers)
        
    }
    
    func checkCreateChatButtonState() {
        self.navigationItem.rightBarButtonItem?.isEnabled = tableView.indexPathsForSelectedRows?.count != nil
    }
    
    @IBAction func createChatButtonPressed(sender: AnyObject) {
        
        let selectedIndexes = self.tableView.indexPathsForSelectedRows
        
        var users: [QBUUser] = []
        
        for indexPath in selectedIndexes! {
            let user = self.users[indexPath.row]
            users.append(user)
        }
        
        let completion = {[weak self] (response: QBResponse?, createdDialog: QBChatDialog?) -> Void in
            
            if createdDialog != nil {
                for indexPath in selectedIndexes! {
                    self?.tableView.deselectRow(at: indexPath, animated: false)
                }
                self?.checkCreateChatButtonState()
                
                print(createdDialog)
                self?.openNewDialog(dialog: createdDialog)
            }
            
            guard let unwrappedResponse = response else {
                print("Error empty response")
                return
            }
            
            if let error = unwrappedResponse.error {
                print(error.error)
                SVProgressHUD.showError(withStatus: error.error?.localizedDescription)
            }
            else {
                SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)
            }
        }
        
        if let dialog = self.dialog {
            
            if dialog.type == .group {
                
                SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
                
                self.updateDialog(dialog: self.dialog!, newUsers:users, completion: {[weak self] (response, dialog) -> Void in
                    
                    guard response?.error == nil else {
                        SVProgressHUD.showError(withStatus: response?.error?.error?.localizedDescription)
                        return
                    }
                    
                    SVProgressHUD.showSuccess(withStatus: "STR_DIALOG_CREATED".localized)
                    
                    for indexPath in selectedIndexes! {
                        self?.tableView.deselectRow(at: indexPath, animated: false)
                    }
                    self?.checkCreateChatButtonState()

                    self?.openNewDialog(dialog: dialog)
                    })
                
            } else {
                
                guard let usersWithoutCurrentUser = ServicesManager.instance().sortedUsersWithoutCurrentUser() else {
                    print("No users found")
                    return
                }
                
                guard let dialogOccupants = dialog.occupantIDs else {
                    print("Dialog has not occupants")
                    return
                }
                
                let usersInDialogs = usersWithoutCurrentUser.filter({ (user) -> Bool in
                    
                    return dialogOccupants.contains(NSNumber(value: user.id))
                })
                
                if usersInDialogs.count > 0 {
                    users.append(contentsOf: usersInDialogs)
                }
                
                let chatName = self.nameForGroupChatWithUsers(users: users)
                
                self.createChat(name: chatName, users: users, completion: completion)
            }
            
        } else {
            
            if users.count == 1 {
                
                self.createChat(name: nil, users: users, completion: completion)
                
            } else {
                
                _ = AlertViewWithTextField(title: "SA_STR_ENTER_CHAT_NAME".localized, message: nil, showOver:self, didClickOk: { (text) -> Void in
                    
                    var chatName = text!.trimmingCharacters(in: CharacterSet.whitespaces)

                    
                    if chatName.isEmpty {
                        chatName = self.nameForGroupChatWithUsers(users: users)
                    }
                    
                    self.createChat(name: chatName, users: users, completion: completion)
                    
                }) { () -> Void in
                    self.checkCreateChatButtonState()
                }
            }
        }
    }
    
    func updateDialog(dialog:QBChatDialog, newUsers users:[QBUUser], completion: ((_ response: QBResponse?, _ dialog: QBChatDialog?) -> Void)?) {
        
        let usersIDs = users.map{ NSNumber(value: $0.id) }
        
        // Updates dialog with new occupants.
        ServicesManager.instance().chatService.joinOccupants(withIDs: usersIDs, to: dialog) { [weak self] (response: QBResponse, dialog: QBChatDialog?) -> Void in
            
            guard response.error == nil else {
                SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                
                completion?(response, nil)
                return
            }
            
            guard let unwrappedDialog = dialog else {
                print("Received dialog is nil")
                return
            }
            guard let strongSelf = self else { return }
            let notificationText = strongSelf.updatedMessageWithUsers(users: users,isNewDialog: false)
            
            // Notifies users about new dialog with them.
            ServicesManager.instance().chatService.sendSystemMessageAboutAdding(to: unwrappedDialog, toUsersIDs: usersIDs, withText: notificationText, completion: { (error) in
                
                ServicesManager.instance().chatService.sendNotificationMessageAboutAddingOccupants(usersIDs, to: unwrappedDialog, withNotificationText: notificationText)
                
                print(unwrappedDialog)
                
                completion?(response, unwrappedDialog)
            })
        }
    }
    
    /**
     Creates string Login1 added login2, login3
     
     - parameter users: [QBUUser] instance
     
     - returns: String instance
     */
    func updatedMessageWithUsers(users: [QBUUser],isNewDialog:Bool) -> String {
        
        let dialogMessage = isNewDialog ? "SA_STR_CREATE_NEW".localized : "SA_STR_ADDED".localized
        
        var message: String = "\(QBSession.current().currentUser!.login!) " + dialogMessage + " "
        for user: QBUUser in users {
            message = "\(message)\(user.login!),"
        }
        message.remove(at: message.index(before: message.endIndex))
        return message
    }
    
    func nameForGroupChatWithUsers(users:[QBUUser]) -> String {
        
        let chatName = ServicesManager.instance().currentUser()!.login! + "_" + users.map({ $0.login ?? $0.email! }).joined(separator: ", ").replacingOccurrences(of: "@", with: "", options: String.CompareOptions.literal, range: nil)
        
        return chatName
    }
    
    func createChat(name: String?, users:[QBUUser], completion: ((_ response: QBResponse?, _ createdDialog: QBChatDialog?) -> Void)?) {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.clear)
        
        if users.count == 1 {
            // Creating private chat.
            ServicesManager.instance().chatService.createPrivateChatDialog(withOpponent: users.first!, completion: { (response, chatDialog) in
                
                completion?(response, chatDialog)
            })
            
        } else {
            // Creating group chat.
            
            ServicesManager.instance().chatService.createGroupChatDialog(withName: name, photo: nil, occupants: users) { [weak self] (response, chatDialog) -> Void in
                
            
                guard response.error == nil else {
                    
                    SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                    return
                }

                guard let unwrappedDialog = chatDialog else {
                    return
                }
                
                guard let dialogOccupants = chatDialog?.occupantIDs else {
                    print("Chat dialog has not occupants")
                    return
                }
                
                guard let strongSelf = self else { return }
                
                let notificationText = strongSelf.updatedMessageWithUsers(users: users, isNewDialog: true)
                
                ServicesManager.instance().chatService.sendSystemMessageAboutAdding(to: unwrappedDialog, toUsersIDs: dialogOccupants, withText:notificationText, completion: { (error) -> Void in
                    
                     ServicesManager.instance().chatService.sendNotificationMessageAboutAddingOccupants(dialogOccupants, to: unwrappedDialog, withNotificationText: notificationText)
                    
                    completion?(response, unwrappedDialog)
                })
            }
        }
    }
    
    func openNewDialog(dialog: QBChatDialog!) {
        self.dialog = dialog
        
        let navigationArray = self.navigationController?.viewControllers
        let newStack = [] as NSMutableArray
        
        //change stack by replacing view controllers after ChatVC with ChatVC
        for vc in navigationArray! {
            // ChatViewController
            newStack.add(vc)
            if vc is DialogsViewController {
                let chatVC = self.storyboard!.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                chatVC.dialog = dialog
                newStack.add(chatVC)
                self.navigationController!.setViewControllers(newStack.copy() as! [UIViewController], animated: true)
                return;
            }
        }

        //else perform segue
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_CHAT".localized, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destination as? ChatViewController {
                chatVC.dialog = self.dialog
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SA_STR_CELL_USER".localized, for: indexPath as IndexPath) as! UserTableViewCell
        
        let user = self.users[indexPath.row]
        
        cell.setColorMarkerText(text: String(indexPath.row + 1), color: ServicesManager.instance().color(forUser: user))
        cell.userDescription = user.fullName
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.checkCreateChatButtonState()
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.checkCreateChatButtonState()
    }
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if (chatDialog.id == self.dialog?.id) {
            self.dialog = chatDialog
            self.updateUsers()
            self.tableView.reloadData()
        }
        
    }
    
 }
