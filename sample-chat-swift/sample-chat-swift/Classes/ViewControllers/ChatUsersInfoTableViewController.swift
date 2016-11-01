//
//  GroupChatUsersInfo.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/14/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class ChatUsersInfoTableViewController: UsersListTableViewController, QMChatServiceDelegate, QMChatConnectionDelegate {
    var dialog: QBChatDialog!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (self.dialog.occupantIDs?.count)! >= ServicesManager.instance().usersService.usersMemoryStorage.unsortedUsers().count {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
        
        ServicesManager.instance().chatService.addDelegate(self)
    }
	
    func updateUsers() {
        
        ServicesManager.instance().usersService.getUsersWithIDs(self.dialog.occupantIDs!).continue ({ (task) -> Any? in
            
            if (task.result?.count)! >= ServicesManager.instance().usersService.usersMemoryStorage.unsortedUsers().count {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
            else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
            
            if task.result?.count ?? 0 > 0 {
                self.setupUsers(users: task.result! as! [QBUUser])
            }
            
            return nil
        })
    }
	
    override func setupUsers(users: [QBUUser]) {
        
        
        let filteredUsers = users.filter({self.dialog.occupantIDs!.contains(NSNumber(value: $0.id))})
        
        let sortedUsers = filteredUsers.sorted(by: { (user1, user2) -> Bool in
            return user1.login!.compare(user2.login!, options:String.CompareOptions.numeric) == ComparisonResult.orderedAscending
        })
        super.setupUsers(users: sortedUsers)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SA_STR_SEGUE_GO_TO_SELECT_OPPONENTS".localized {
            if let newDialogViewController = segue.destination as? NewDialogViewController {
                newDialogViewController.dialog = self.dialog
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if (chatDialog.id == self.dialog!.id) {
            
            self.dialog = chatDialog
            self.updateUsers()
            self.tableView.reloadData()
        }
    }
}
