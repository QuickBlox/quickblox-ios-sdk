//
//  DialogsTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

class DialogsViewController: UIViewController, UITableViewDelegate, QMChatServiceDelegate {
    @IBOutlet weak var tableView:UITableView!
    
    private var delegate : SwipeableTableViewCellWithBlockButtons!
    
    @IBAction private func goToOpponents(sender: AnyObject?){
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_SELECT_OPPONENTS".localized, sender: nil)
    }
    
    // MARK: - ViewController overrides
    
    override func viewDidLoad() {

        self.navigationItem.title = "SA_STR_WELCOME".localized + ", " + ServicesManager.instance.currentUser()!.login
        
        self.delegate = SwipeableTableViewCellWithBlockButtons()
        self.delegate.tableView = self.tableView

        ServicesManager.instance.chatService.addDelegate(self)
        ServicesManager.instance.chatService.addDelegate(ServicesManager.instance)
            
        self.getDialogs()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController() {
            ServicesManager.instance.chatService.logoutChat()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_CHAT".localized {
            if let chatVC = segue.destinationViewController as? ChatViewController {
                chatVC.dialog = sender as? QBChatDialog
            }
        }
    }
    
    // MARK: - DataSource Action
    
    func getDialogs() {

//        if !QBChat.instance().isLoggedIn() {
//            return
//        }
//        
//        SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)
//        
        ServicesManager.instance.chatService.allDialogsWithPageLimit(100, interationBlock: { (responce: QBResponse!, dialogObjects: [AnyObject]!, dialogsUsersIDs: Set<NSObject>!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
        }) { (responce: QBResponse!) -> Void in
            
        }
//
//            if response.error != nil {
//                SVProgressHUD.showErrorWithStatus("SA_STR_CANT_DOWNLOAD_DIALOGS".localized)
//                println(response.error.error)
//                
//                return
//            }
//            
//            StorageManager.instance.dialogs = dialogObjects as! [QBChatDialog]
//            
//            SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
//        })
    }
    
    // MARK: - DataSource
    
    func dialogs() -> Array<QBChatDialog> {
        return ServicesManager.instance.chatService.dialogsMemoryStorage.unsortedDialogs() as! Array<QBChatDialog>
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dialogs().count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_DIALOG".localized, forIndexPath: indexPath) as! UserTableViewCell
        
        var chatDialog = self.dialogs()[indexPath.row]
        
        cell.tag = indexPath.row
        cell.delegate = delegate
        cell.dialogID = chatDialog.ID
        
        var cellModel = UserTableViewCellModel(dialog: chatDialog)
        
        cell.detailTextLabel?.text = cellModel.detailTextLabelText
        cell.textLabel?.text = cellModel.textLabelText
        cell.rightUtilityButtons = cellModel.rightUtilityButtons
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var dialog = self.dialogs()[indexPath.row]
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_CHAT".localized , sender: dialog)
    }
    
    // MARK: - QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didAddChatDialogsToMemoryStorage chatDialogs: [AnyObject]!) {
        self.tableView.reloadData()
    }
    
    func chatService(chatService: QMChatService!, didAddChatDialogToMemoryStorage chatDialog: QBChatDialog!) {
        self.tableView.reloadData()
    }
}
