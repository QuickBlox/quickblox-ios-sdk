//
//  SelectOpponentViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class SelectOpponentViewController: LoginTableViewController {
    private let kChatSegueIdentifier = "goToChat"
    private var createdDialog: QBChatDialog?
    private var delegate : SwipeableTableViewCellWithBlockButtons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = SwipeableTableViewCellWithBlockButtons()
        self.delegate.tableView = self.tableView
        self.checkCreateChatButtonState()
        self.navigationItem.title = "Welcome, " + ConnectionManager.instance.currentUser!.login
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
        
        var selectedIndexes = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        if selectedIndexes.count == 1 {
            createChatWithName(nil, completion: { () -> Void in
                sender.enabled = true
            })
        }
        else{
            SwiftAlertWithTextField(title: "Enter chat name", message: nil, showOver:self, didClickOk: { [unowned self] (text) -> Void in
                self.createChatWithName(text, completion: { () -> Void in
                    sender.enabled = true
                })
                }) { () -> Void in
                    // cancel
                    sender.enabled = true
            }
        }
    }
    
    func createChatWithName(name: String?, completion: () -> Void){
        var selectedIndexes = self.tableView.indexPathsForSelectedRows() as! [NSIndexPath]
        
        var usersToChat: [QBUUser] = []
        
        for indexPath in selectedIndexes {
            var cell = self.tableView.cellForRowAtIndexPath(indexPath)!
            
            var user = ConnectionManager.instance.usersDataSource.users[cell.tag]
            usersToChat.append(user)
        }
        
        var chatDialog = QBChatDialog()
        chatDialog.occupantIDs = usersToChat.map{ $0.ID }
        
        chatDialog.type = QBChatDialogTypeGroup
        if usersToChat.count == 1 {
            chatDialog.type =  QBChatDialogTypePrivate
        }
        else {
            chatDialog.type = QBChatDialogTypeGroup
            if name != nil && !name!.isEmpty {
                chatDialog.name = name!
            }
            else{
                var chatName = ConnectionManager.instance.currentUser!.login + "_" + ", ".join(usersToChat.map({ $0.login ?? $0.email }))
                chatName = chatName.stringByReplacingOccurrencesOfString("@", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                chatDialog.name = chatName
            }
        }
        
        QBRequest.createDialog(chatDialog, successBlock: { [weak self] (response: QBResponse!, createdDialog: QBChatDialog!) -> Void in
            SVProgressHUD.showSuccessWithStatus("Dialog created!")
            completion()
            self?.createdDialog = createdDialog
            self?.performSegueWithIdentifier(self?.kChatSegueIdentifier, sender: nil)
            println(createdDialog)
            }) { (response: QBResponse!) -> Void in
                completion()
                println(response.error.error)
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kChatSegueIdentifier {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = self.createdDialog
            }
        }
    }
    
    /**
    UITableView delegate methods
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath) as! UserTableViewCell
        let user = ConnectionManager.instance.usersDataSource.users[indexPath.row]
        
        var cellModel = UserTableViewCellModel(user: user)
        cell.rightUtilityButtons = cellModel.rightUtilityButtons
        cell.user = user
        cell.delegate = self.delegate
        
        if user.ID == ConnectionManager.instance.currentUser!.ID {
            cell.hidden = true // hide current user
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let user = ConnectionManager.instance.usersDataSource.users[indexPath.row]
        if user.ID == ConnectionManager.instance.currentUser!.ID {
            return 0 // hide current user
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
