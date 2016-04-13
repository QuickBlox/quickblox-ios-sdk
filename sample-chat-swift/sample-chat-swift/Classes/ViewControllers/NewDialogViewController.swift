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
    
    override func viewWillAppear(animated: Bool) {
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkCreateChatButtonState()
    }
    
    func updateUsers() {
        if let users = ServicesManager.instance().sortedUsers() {
            
            self.setupUsers(users)
            self.checkCreateChatButtonState()
        }
    }
    
    override func setupUsers(users: [QBUUser]) {
    
        var filteredUsers = users.filter({($0 as QBUUser).ID != ServicesManager.instance().currentUser().ID})
        
        if let _ = self.dialog  {
            
            filteredUsers = filteredUsers.filter({!(self.dialog!.occupantIDs as! [UInt]).contains(($0 as QBUUser).ID)})
        }
        
        super.setupUsers(filteredUsers)
    
    }
    
    func checkCreateChatButtonState() {
        self.navigationItem.rightBarButtonItem?.enabled = tableView.indexPathsForSelectedRows?.count != nil
    }
    
    @IBAction func createChatButtonPressed(sender: AnyObject) {

        (sender as! UIBarButtonItem).enabled = false
        
        let selectedIndexes = self.tableView.indexPathsForSelectedRows
        
        var users: [QBUUser] = []
        
        for indexPath in selectedIndexes! {
            let user = self.users[indexPath.row]
            users.append(user)
        }
        
        let completion = {[weak self] (response: QBResponse?, createdDialog: QBChatDialog?) -> Void in
            
            (sender as! UIBarButtonItem).enabled = true
            
            if createdDialog != nil {
                print(createdDialog)
                self?.openNewDialog(createdDialog)
            }
			
			guard let unwrappedResponse = response else {
				print("Error empty response")
				return
			}
			
			
            if let error = unwrappedResponse.error {
                print(error.error)
                SVProgressHUD.showErrorWithStatus(error.error?.localizedDescription)
            }
        }
        
        if let dialog = self.dialog {
            
            if dialog.type == .Group {
                
                SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
                
                self.updateDialog(self.dialog!, newUsers:users, completion: {[weak self] (response, dialog) -> Void in
                    
                    if let rightBarButtonItem = self?.navigationItem.rightBarButtonItem {
                        rightBarButtonItem.enabled = true
                    }
					
					guard response.error == nil else {
						SVProgressHUD.showErrorWithStatus(response.error?.error?.localizedDescription)
						return
					}
					
					SVProgressHUD.showSuccessWithStatus("STR_DIALOG_CREATED".localized)
					
					
					self?.openNewDialog(dialog)
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
				
                let usersInDialogs = usersWithoutCurrentUser.filter({dialogOccupants.contains(($0 as QBUUser).ID)})
				
                if usersInDialogs.count > 0 {
                    users.appendContentsOf(usersInDialogs)
                }
                
                let chatName = self.nameForGroupChatWithUsers(users)
				
                self.createChat(chatName, users: users, completion: completion)
            }
            
        } else {
            
            if users.count == 1 {
                
                self.createChat(nil, users: users, completion: completion)

            } else {
                
                _ = AlertViewWithTextField(title: "SA_STR_ENTER_CHAT_NAME".localized, message: nil, showOver:self, didClickOk: { (text) -> Void in
                    
                    var chatName = text
                    
                    if chatName!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).isEmpty {
                        chatName = self.nameForGroupChatWithUsers(users)
                    }
                    
                    self.createChat(chatName, users: users, completion: completion)
                    
                    }) { () -> Void in
                        
                        // cancel
                        (sender as! UIBarButtonItem).enabled = true
                }
            }
        }
    }
    
	func updateDialog(dialog:QBChatDialog, newUsers users:[QBUUser], completion: ((response: QBResponse!, dialog: QBChatDialog!) -> Void)?) {
        
        let usersIDs = users.map{ NSNumber(unsignedInteger: $0.ID) }
        
        // Updates dialog with new occupants.
        ServicesManager.instance().chatService.joinOccupantsWithIDs(usersIDs, toChatDialog: dialog) { [weak self] (response: QBResponse, dialog: QBChatDialog?) -> Void in
			
			guard response.error == nil else {
				print(response.error?.error)
				
				completion?(response: response, dialog: nil)
				return
			}
			
			guard let unwrappedDialog = dialog else {
				print("Received dialog is nil")
				return
			}
			
			// Notifies users about new dialog with them.
			ServicesManager.instance().chatService.sendSystemMessageAboutAddingToDialog(unwrappedDialog, toUsersIDs: usersIDs, completion: { (error: NSError?) -> Void in
				
				guard let strongSelf = self else { return }
				// Notifies existing dialog occupants about new users.
				let notificationText = strongSelf.updatedMessageWithUsers(users)
				
				ServicesManager.instance().chatService.sendNotificationMessageAboutAddingOccupants(usersIDs, toDialog: unwrappedDialog, withNotificationText: notificationText)
				
				print(unwrappedDialog)
				
				completion?(response: response, dialog: unwrappedDialog)
			})
        }
    }
	
	/**
	Creates string Login1 added login2, login3
	
	- parameter users: [QBUUser] instance
	
	- returns: String instance
	*/
	func updatedMessageWithUsers(users: [QBUUser]) -> String {
        var message: String = "\(QBSession.currentSession().currentUser!.login!) " + "SA_STR_ADDED".localized + " "
        for user: QBUUser in users {
            message = "\(message)\(user.login!),"
        }
        message = message.substringToIndex(message.endIndex.predecessor())
        return message
    }
    
	func nameForGroupChatWithUsers(users:[QBUUser]) -> String {
        
        let chatName = ServicesManager.instance().currentUser()!.login! + "_" + users.map({ $0.login ?? $0.email! }).joinWithSeparator(", ").stringByReplacingOccurrencesOfString("@", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        return chatName
    }
    
	func createChat(name: String?, users:[QBUUser], completion: ((response: QBResponse?, createdDialog: QBChatDialog?) -> Void)?) {
        
        SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        if users.count == 1 {
            // Creating private chat.
			
            ServicesManager.instance().chatService.createPrivateChatDialogWithOpponent(users.first!, completion: { (response: QBResponse?, chatDialog: QBChatDialog?) -> Void in
                
                completion?(response: response, createdDialog: chatDialog)
            })
            
        } else {
            // Creating group chat.
			
            ServicesManager.instance().chatService.createGroupChatDialogWithName(name, photo: nil, occupants: users) { (response: QBResponse, chatDialog: QBChatDialog?) -> Void in
				
				guard let unwrappedDialog = chatDialog else {
					return
				}
				
				guard let dialogOccupants = chatDialog?.occupantIDs else {
					print("Chat dialog has not occupants")
					return
				}
				
				ServicesManager.instance().chatService.sendSystemMessageAboutAddingToDialog(unwrappedDialog, toUsersIDs: dialogOccupants, completion: { (error: NSError?) -> Void in
					
					completion?(response: response, createdDialog: unwrappedDialog)
				})
            }
        }
    }
	
    func openNewDialog(dialog: QBChatDialog!) {
        self.dialog = dialog
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_CHAT".localized, sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = self.dialog
            } 
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_USER".localized, forIndexPath: indexPath) as! UserTableViewCell
        
        let user = self.users[indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row + 1), color: ServicesManager.instance().color(forUser: user))
        cell.userDescription = user.fullName
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }

    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.checkCreateChatButtonState()
    }
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if (chatDialog.ID == self.dialog?.ID) {
            self.dialog = chatDialog
            self.updateUsers()
            self.tableView.reloadData()
        }
        
    }
    
}
