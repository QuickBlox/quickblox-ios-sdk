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
		
		SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localized + currentUser.login!, maskType: SVProgressHUDMaskType.clear)
		
		// Logging to Quickblox REST API and chat.
		ServicesManager.instance().logIn(with: currentUser, completion: {
			[weak self] (success:Bool,  errorMessage: String?) -> Void in
			
			guard let strongSelf = self else { return }
			
			guard success else {
				SVProgressHUD.showError(withStatus: errorMessage)
				return
			}
			
			strongSelf.registerForRemoteNotification()
			SVProgressHUD.showSuccess(withStatus: "SA_STR_LOGGED_IN".localized)
			
			if (ServicesManager.instance().notificationService.pushDialogID != nil) {
				ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(delegate: strongSelf)
			}
			else {
				strongSelf.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
			}
			})
		
		self.tableView.reloadData()
    }

    // MARK: NotificationServiceDelegate protocol
	
    func notificationServiceDidStartLoadingDialogFromServer() {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_DIALOG".localized, maskType: SVProgressHUDMaskType.clear)
    }
	
    func notificationServiceDidFinishLoadingDialogFromServer() {
        SVProgressHUD.dismiss()
    }
    
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        let dialogsController = self.storyboard?.instantiateViewController(withIdentifier: "DialogsViewController") as! DialogsViewController
        let chatController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatController.dialog = chatDialog

        self.navigationController?.viewControllers = [dialogsController, chatController]
    }
    
    func notificationServiceDidFailFetchingDialog() {
        self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
    }
    
    // MARK: Actions
	
	/**
	Login in chat with user and register for remote notifications
	
	- parameter user: QBUUser instance
	*/
    func logInChatWithUser(user: QBUUser) {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOGGING_IN_AS".localized + user.login!, maskType: SVProgressHUDMaskType.clear)

        // Logging to Quickblox REST API and chat.
        ServicesManager.instance().logIn(with: user, completion:{
            [unowned self] (success:Bool, errorMessage: String?) -> Void in

			guard success else {
				SVProgressHUD.showError(withStatus: errorMessage)
				return
			}
			
			self.registerForRemoteNotification()
			self.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_DIALOGS".localized, sender: nil)
			SVProgressHUD.showSuccess(withStatus: "SA_STR_LOGGED_IN".localized)
			
        })
    }
	
    // MARK: Remote notifications
    
    func registerForRemoteNotification() {
        // Register for push in iOS 8
        if #available(iOS 8.0, *) {
            let settings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            // Register for push in iOS 7
            UIApplication.shared.registerForRemoteNotifications(matching: [UIRemoteNotificationType.badge, UIRemoteNotificationType.sound, UIRemoteNotificationType.alert])
        }
    }
    
    // MARK: UITableViewDataSource

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SA_STR_CELL_USER".localized, for: indexPath) as! UserTableViewCell
        cell.isExclusiveTouch = true
        cell.contentView.isExclusiveTouch = true
        
        let user = self.users[indexPath.row]
        
        cell.setColorMarkerText(text: String(indexPath.row + 1), color: ServicesManager.instance().color(forUser: user))
        cell.userDescription = "SA_STR_LOGIN_AS".localized + " " + user.fullName!
        cell.tag = indexPath.row
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated:true)
        
        let user = self.users[indexPath.row]
        user.password = kTestUsersDefaultPassword
        
        self.logInChatWithUser(user: user)
    }
    
    //MARK: Helpers
    
    func appVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    func build() -> String {
         return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
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
