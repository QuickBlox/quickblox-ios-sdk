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
    private let kOpponentsSegueIdentifier = "goToSelectOpponents"
    @IBOutlet weak var tableView:UITableView!
    
    private var delegate : SwipeableTableViewCellWithBlockButtons!
    
    @IBAction private func goToOpponents(sender: AnyObject?){
        self.performSegueWithIdentifier(kOpponentsSegueIdentifier, sender: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = SwipeableTableViewCellWithBlockButtons()
        self.delegate.tableView = self.tableView
        
        SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
        
        QBRequest.dialogsWithSuccessBlock({ [weak self] (response: QBResponse!, dialogs: [AnyObject]!, dialogsUsersIDs: Set<NSObject>!) -> Void in
            
            ConnectionManager.instance.dialogs = dialogs as? [QBChatDialog]
            
            var pagedRequest = QBGeneralResponsePage(currentPage: 1, perPage: 100)
            
            QBRequest.usersWithIDs(Array(dialogsUsersIDs), page: pagedRequest, successBlock: { (response: QBResponse!, page: QBGeneralResponsePage!, users: [AnyObject]!) -> Void in
                
                SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                
                ConnectionManager.instance.dialogsUsers = users as? [QBUUser]
                
                self?.tableView.reloadData()
                
                }, errorBlock: { (response: QBResponse!) -> Void in
                    SVProgressHUD.showErrorWithStatus("SA_STR_CANT_DOWNLOAD_USERS".localized)
                    println(response.error.error)
            })
            }, errorBlock: { (response: QBResponse!) -> Void in
                SVProgressHUD.showErrorWithStatus("SA_STR_CANT_DOWNLOAD_DIALOGS".localized)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_DIALOG".localized, forIndexPath: indexPath) as! UserTableViewCell
        
        var chatDialog = ConnectionManager.instance.dialogs![indexPath.row]
        
        cell.tag = indexPath.row
        cell.delegate = delegate
        cell.dialogID = chatDialog.ID
        
        var cellModel = UserTableViewCellModel(dialog: chatDialog)
        
        cell.detailTextLabel?.text = cellModel.detailTextLabelText
        cell.textLabel?.text = cellModel.textLabelText
        cell.rightUtilityButtons = cellModel.rightUtilityButtons
        cell.user = cellModel.user
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
