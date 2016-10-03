//
//  AppDelegate.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 3/30/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

let kQBApplicationID:UInt = 28784
let kQBAuthKey = "QJtmmW2Z7tb-mJF"
let kQBAuthSecret = "xuwgyRWcUhcwjCM"
let kQBAccountKey = "7yvNe17TnjNUqDoPwfqp"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NotificationServiceDelegate {
	
	var window: UIWindow?
    
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        application.applicationIconBadgeNumber = 0
        
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.setApplicationID(kQBApplicationID)
        QBSettings.setAuthKey(kQBAuthKey)
        QBSettings.setAuthSecret(kQBAuthSecret)
        QBSettings.setAccountKey(kQBAccountKey)
        
        // enabling carbons for chat
        QBSettings.setCarbonsEnabled(true)
        
        // Enables Quickblox REST API calls debug console output.
		QBSettings.setLogLevel(QBLogLevel.debug)
        
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
 
        // app was launched from push notification, handling it
        let remoteNotification: NSDictionary! = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary
        if (remoteNotification != nil) {
            ServicesManager.instance().notificationService.pushDialogID = remoteNotification["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String
        }
		
		return true
	}
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceIdentifier: String = UIDevice.current.identifierForVendor!.uuidString
        let subscription: QBMSubscription! = QBMSubscription()
        
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { (response: QBResponse!, objects: [QBMSubscription]?) -> Void in
            //
            }) { (response: QBResponse!) -> Void in
            //
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Push failed to register with error: %@", error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NSLog("my push is: %@", userInfo)
		guard application.applicationState == UIApplicationState.inactive else {
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
		DispatchQueue.main.async(execute: {
			ServicesManager.instance().notificationService.handlePushNotificationWithDelegate(self)
		});
    }
	
    func applicationWillResignActive(_ application: UIApplication) {
    }
	
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        application.applicationIconBadgeNumber = 0
        // Logging out from chat.
        ServicesManager.instance().chatService.disconnect(completionBlock: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        ServicesManager.instance().chatService.connect(completionBlock: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
      
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Logging out from chat.
        ServicesManager.instance().chatService.disconnect(completionBlock: nil)
    }
	
    // MARK: NotificationServiceDelegate protocol
    
    func notificationServiceDidStartLoadingDialogFromServer() {
    }
    
    func notificationServiceDidFinishLoadingDialogFromServer() {
    }
    
    func notificationServiceDidSucceedFetchingDialog(_ chatDialog: QBChatDialog!) {
        let navigatonController: UINavigationController! = self.window?.rootViewController as! UINavigationController
        
        let chatController: ChatViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        chatController.dialog = chatDialog
        
        let dialogWithIDWasEntered = ServicesManager.instance().currentDialogID
        if !dialogWithIDWasEntered.isEmpty {
            // some chat already opened, return to dialogs view controller first
            navigatonController.popViewController(animated: false);
        }
        
        navigatonController.pushViewController(chatController, animated: true)
    }
    
    func notificationServiceDidFailFetchingDialog() {
    }
}

