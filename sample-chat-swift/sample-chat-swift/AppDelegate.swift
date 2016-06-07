//
//  AppDelegate.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit

let kQBApplicationID:UInt = 28784
let kQBAuthKey = "QJtmmW2Z7tb-mJF"
let kQBAuthSecret = "xuwgyRWcUhcwjCM"
let kQBAccountKey = "7yvNe17TnjNUqDoPwfqp"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NotificationServiceDelegate {
	
	var window: UIWindow?
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
         application.applicationIconBadgeNumber = 0
        
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.setApplicationID(kQBApplicationID)
        QBSettings.setAuthKey(kQBAuthKey)
        QBSettings.setAuthSecret(kQBAuthSecret)
        QBSettings.setAccountKey(kQBAccountKey)
        
        // enabling carbons for chat
        QBSettings.setCarbonsEnabled(true)
        
        // Enables Quickblox REST API calls debug console output.
		QBSettings.setLogLevel(QBLogLevel.Nothing)
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        QBSettings.setChatDNSLookupCacheEnabled(true);
        
        // app was launched from push notification, handling it
        let remoteNotification: NSDictionary! = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary
        if (remoteNotification != nil) {
            ServicesManager.instance().notificationService.pushDialogID = remoteNotification["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String
        }
		
		return true
	}
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceIdentifier: String = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let subscription: QBMSubscription! = QBMSubscription()
        
        subscription.notificationChannel = QBMNotificationChannelAPNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            //
            }) { (response: QBResponse!) -> Void in
            //
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog("Push failed to register with error: %@", error)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSLog("my push is: %@", userInfo)
		guard application.applicationState == UIApplicationState.Inactive else {
			return
		}
		
		guard let dialogID = userInfo["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String else {
			return
		}
		
		guard !dialogID.isEmpty else {
			return
		}
		
			
		let dialogWithIDWasEntered: String? = ServicesManager.instance().currentDialogID
		if dialogWithIDWasEntered == dialogID {
			return
		}
		
		ServicesManager.instance().notificationService.pushDialogID = dialogID
		
		// calling dispatch async for push notification handling to have priority in main queue
		dispatch_async(dispatch_get_main_queue(), {
			ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(self)
		});
    }
	
    func applicationWillResignActive(application: UIApplication) {
    }
	
    func applicationDidEnterBackground(application: UIApplication) {
        
        application.applicationIconBadgeNumber = 0
        // Logging out from chat.
        ServicesManager.instance().chatService.disconnectWithCompletionBlock(nil)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Logging in to chat.
        ServicesManager.instance().chatService.connectWithCompletionBlock(nil)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
      
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Logging out from chat.
        ServicesManager.instance().chatService.disconnectWithCompletionBlock(nil)
    }
	
    // MARK: NotificationServiceDelegate protocol
    
    func notificationServiceDidStartLoadingDialogFromServer() {
    }
    
    func notificationServiceDidFinishLoadingDialogFromServer() {
    }
    
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!) {
        let navigatonController: UINavigationController! = self.window?.rootViewController as! UINavigationController
        
        let chatController: ChatViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController
        chatController.dialog = chatDialog
        
        let dialogWithIDWasEntered = ServicesManager.instance().currentDialogID
        if !dialogWithIDWasEntered.isEmpty {
            // some chat already opened, return to dialogs view controller first
            navigatonController.popViewControllerAnimated(false);
        }
        
        navigatonController.pushViewController(chatController, animated: true)
    }
    
    func notificationServiceDidFailFetchingDialog() {
    }
}

