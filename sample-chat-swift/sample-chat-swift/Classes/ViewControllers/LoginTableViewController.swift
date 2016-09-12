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
    
    @IBOutlet weak var buildNumberLabel: UILabel!

    // MARK: ViewController overrides
    
    override func viewDidLoad() {
		super.viewDidLoad()
		
		self.buildNumberLabel.text = self.versionBuild();
        
		guard let currentUser = ServicesManager.instance().currentUser() else {
			return
		}
        
		currentUser.password = kTestUsersDefaultPassword
		
		SVProgressHUD.showWithStatus("SA_STR_LOGGING_IN_AS".localized + currentUser.login!, maskType: SVProgressHUDMaskType.Clear)
		
		// Logging to Quickblox REST API and chat.
		ServicesManager.instance().logInWithUser(currentUser, completion: {
			[weak self] (success:Bool,  errorMessage: String?) -> Void in
			
			guard let strongSelf = self else { return }
			
			guard success else {
				SVProgressHUD.showErrorWithStatus(errorMessage)
				return
			}
			
			strongSelf.registerForRemoteNotification()
			SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)
			
			if (ServicesManager.instance().notificationService.pushDialogID != nil) {
				ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(strongSelf)
			}
			else {
				strongSelf.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
			}
			})
		
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
        let dialogsController = self.storyboard?.instantiateViewControllerWithIdentifier("DialogsViewController") as! DialogsViewController
        let chatController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatController.dialog = chatDialog

        var viewControllers = self.navigationController?.viewControllers
        viewControllers?.appendContentsOf([dialogsController,chatController])
        self.navigationController?.viewControllers = viewControllers!
        
    }
    
    
    func notificationServiceDidFailFetchingDialog() {
        self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
    }
    
    // MARK: Actions
	
	/**
	Login in chat with user and register for remote notifications
	
	- parameter user: QBUUser instance
	*/
    func logInChatWithUser(user: QBUUser) {
        
        SVProgressHUD.showWithStatus("SA_STR_LOGGING_IN_AS".localized + user.login!, maskType: SVProgressHUDMaskType.Clear)

        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logInWithUser(user, completion:{
            [unowned self] (success:Bool, errorMessage: String?) -> Void in

			guard success else {
				SVProgressHUD.showErrorWithStatus(errorMessage)
				return
			}
			
			self.registerForRemoteNotification()
			self.performSegueWithIdentifier("SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
			SVProgressHUD.showSuccessWithStatus("SA_STR_LOGGED_IN".localized)
			
        })
    }
	
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {
        
        let settings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    // MARK: UITableViewDataSource

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SA_STR_CELL_USER".localized, forIndexPath: indexPath) as! UserTableViewCell
        cell.exclusiveTouch = true
        cell.contentView.exclusiveTouch = true
        
        let user = self.users[indexPath.row]
        
        cell.setColorMarkerText(String(indexPath.row + 1), color: ServicesManager.instance().color(forUser: user))
        cell.userDescription = "SA_STR_LOGIN_AS".localized + " " + user.fullName!
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        
        let user = self.users[indexPath.row]
        user.password = kTestUsersDefaultPassword
        
        self.logInChatWithUser(user)
    }
    
    //MARK: Helpers
    
    func appVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    func build() -> String {
         return NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
    }

    func versionBuild() -> String {
        let version = self.appVersion()
        let build = self.build()
        var versionBuild = String(format:"v%@",version)
        if version != build {
            versionBuild = String(format:"%@(%@)", versionBuild, build )
        }
        return versionBuild as String!
    }
}
