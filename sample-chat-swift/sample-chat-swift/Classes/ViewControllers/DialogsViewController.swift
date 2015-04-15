//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class DialogsViewController: UIViewController, UITableViewDelegate {
    private var selectedDialog: QBChatDialog?
    private let kChatSegueIdentifier = "goToChat"
    @IBOutlet weak var tableView:UITableView!
    
    private var delegate : SwipeableTableViewCellWithBlockButtons!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = SwipeableTableViewCellWithBlockButtons()
        self.delegate.tableView = self.tableView
        
        SVProgressHUD.showWithStatus("Loading", maskType: SVProgressHUDMaskType.Clear)
        
        QBRequest.dialogsWithSuccessBlock({ [weak self] (response: QBResponse!, dialogs: [AnyObject]!, dialogsUsersIDs: Set<NSObject>!) -> Void in
            
            ConnectionManager.instance.dialogs = dialogs as? [QBChatDialog]
            
            var pagedRequest = QBGeneralResponsePage(currentPage: 1, perPage: 100)
            
            QBRequest.usersWithIDs(Array(dialogsUsersIDs), page: pagedRequest, successBlock: { (response: QBResponse!, page: QBGeneralResponsePage!, users: [AnyObject]!) -> Void in
                
                SVProgressHUD.showSuccessWithStatus("Completed!")
                
                ConnectionManager.instance.dialogsUsers = users as? [QBUUser]
                
                self?.tableView.reloadData()
                
                }, errorBlock: { (response: QBResponse!) -> Void in
                    SVProgressHUD.showErrorWithStatus("Can't download users")
                    println(response.error.error)
            })
            }, errorBlock: { (response: QBResponse!) -> Void in
                SVProgressHUD.showErrorWithStatus("Can't download dialogs")
                println(response.error.error)
        })
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        selectedDialog = ConnectionManager.instance.dialogs![indexPath.row]
        self.performSegueWithIdentifier(kChatSegueIdentifier , sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kChatSegueIdentifier {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = self.selectedDialog
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("dialogcell", forIndexPath: indexPath) as! UserTableViewCell
        
        var chatDialog = ConnectionManager.instance.dialogs![indexPath.row]
        
        cell.tag = indexPath.row
        cell.delegate = delegate
        cell.dialogID = chatDialog.ID
        
        switch( chatDialog.type.value ) {
        case QBChatDialogTypePrivate.value:
            cell.detailTextLabel?.text = "private"
            if let users = ConnectionManager.instance.dialogsUsers {
                var recipient = users.filter(){ $0.ID == UInt(chatDialog.recipientID) }[0]
                cell.textLabel?.text = recipient.login ?? recipient.email
                cell.rightUtilityButtons = UserBlockButtons.blockButtonsForDialogType(chatDialog.type, user: recipient, includeDeleteButton: true)
                cell.user = recipient
            }
            
        case QBChatDialogTypeGroup.value:
            cell.detailTextLabel?.text = "group"
            cell.textLabel?.text = chatDialog.name
            cell.rightUtilityButtons = UserBlockButtons.blockButtonsForDialogType(chatDialog.type, user: nil, includeDeleteButton: true)
        case QBChatDialogTypePublicGroup.value:
            cell.detailTextLabel?.text = "public group"
            cell.textLabel?.text = chatDialog.name
            cell.rightUtilityButtons = UserBlockButtons.blockButtonsForDialogType(chatDialog.type, user: nil, includeDeleteButton: true)
        default:
            break
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dialogs = ConnectionManager.instance.dialogs {
            return dialogs.count
        }
        return 0
    }
    
}
