//
//  LoginTableViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/31/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

/**
 *  Default test users password
 */
let kTestUsersDefaultPassword = "x6Bt0VDy5"

class LoginTableViewController: UsersListTableViewController, NotificationServiceDelegate {

    // MARK: ViewController overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (ServicesManager.instance().currentUser() != nil) {
            ServicesManager.instance().currentUser().password = kTestUsersDefaultPassword
            SVProgressHUD.showWithStatus("SA_STR_LOGGIN_IN_AS".localized + ServicesManager.instance().currentUser().login!, maskType: SVProgressHUDMaskType.Clear)
            // Logging to Quickblox REST API and chat.
            ServicesManager.instance().logInWithUser(ServicesManager.instance().currentUser(), completion:{
                [weak self] (success:Bool,  errorMessage: String?) -> Void in
                if let strongSelf = self {
                    if (success) {
                        strongSelf.registerForRemoteNotification()
                        SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)
                        
                        if (ServicesManager.instance().notificationService?.pushDialogID != nil) {
                            ServicesManager.instance().notificationService?.handlePushNotificationWithDelegate(self as! NotificationServiceDelegate)
                        }
                        else {
                            strongSelf.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                        }
                    } else {
                        SVProgressHUD.showErrorWithStatus(errorMessage)
                    }
                }
                })
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: NotificationServiceDelegate protocol
    
    func notificationServiceDidStartLoadingDialogFromServer() {
        SVProgressHUD.showWithStatus("SA_STR_LOADING_DIALOG".localized, maskType: SVProgressHUDMaskType.Clear)
    }
    
    func notificationServiceDidFinishLoadingDialogFromServer() {
        SVProgressHUD.dismiss()
    }
    
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        let dialogsController: DialogsViewController! = self.storyboard?.instantiateViewControllerWithIdentifier("DialogsViewController") as! DialogsViewController
        let chatController: ChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatController.dialog = chatDialog

        self.navigationController?.viewControllers = [dialogsController, chatController]
    }
    
    func notificationServiceDidFailFetchingDialog() {
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
    }
    
    // MARK: Actions
    
    func logInChatWithUser(user: QBUUser) {
        
        SVProgressHUD.showWithStatus("SA_STR_LOADING".localized, maskType: SVProgressHUDMaskType.Clear)

        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logInWithUser(user, completion:{
            [unowned self] (success:Bool,  errorMessage: String?) -> Void in

            if (success) {
                self.registerForRemoteNotification()
                self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
                SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)
                
            } else {
                
                SVProgressHUD.showErrorWithStatus(errorMessage)
            }

        })
    }
    
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {
        // Register for push in iOS 8
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            // Register for push in iOS 7
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([UIRemoteNotificationType.Badge, UIRemoteNotificationType.Sound, UIRemoteNotificationType.Alert])
        }
    }
    
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_USER".localized, forIndexPath: indexPath) as! UserTableViewCell
        
        let user = self.users![indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row + 1), color: ServicesManager.instance().color(forUser: user))
        cell.userDescription = "Login as " + user.fullName!
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let user = self.users![indexPath.row]
        user.password = kTestUsersDefaultPassword
        
        self.logInChatWithUser(user)
    }
    
}
