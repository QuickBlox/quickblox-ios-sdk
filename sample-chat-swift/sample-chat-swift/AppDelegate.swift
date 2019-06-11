//
//  AppDelegate.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import UserNotifications

// To update the QuickBlox credentials, please see the READMe file.(You must create application in admin.quickblox.com)
struct CredentialsConstant {
    static let applicationID:UInt = 0
    static let authKey = ""
    static let authSecret = ""
    static let accountKey = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.applicationIconBadgeNumber = 0
        window?.backgroundColor = .white;
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = CredentialsConstant.applicationID
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        // enabling carbons for chat
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        application.applicationIconBadgeNumber = 0
        // Logging out from chat.
        ChatManager.instance.disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        registerForRemoteNotifications()
        ChatManager.instance.connect { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Logging out from chat.
        ChatManager.instance.disconnect()
    }
    
    //MARK: - UNUserNotification
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        guard let identifierForVendor = UIDevice.current.identifierForVendor else {
            return
        }

        let deviceIdentifier = identifierForVendor.uuidString
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = deviceToken
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
        }, errorBlock: { response in
            debugPrint("[AppDelegate] createSubscription error: \(String(describing: response.error))")
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    private func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
            if let error = error {
                debugPrint("[AppDelegate] requestAuthorization error: \(error.localizedDescription)")
                return
            }
            center.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    return
                }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            })
        })
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if UIApplication.shared.applicationState == .active {
            return
        }
        
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        guard let dialogID = userInfo["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String,
            dialogID.isEmpty == false else {
                return
        }
        // calling dispatch async for push notification handling to have priority in main queue
        DispatchQueue.main.async {
            
            if let chatDialog = ChatManager.instance.storage.dialog(withID: dialogID) {
                self.openChat(chatDialog)
            } else {
                ChatManager.instance.loadDialog(withID: dialogID, completion: { (loadedDialog: QBChatDialog?) -> Void in
                    guard let dialog = loadedDialog else {
                        return
                    }
                    self.openChat(dialog)
                })
            }
        }
        completionHandler()
    }
    
    //MARK: Help
    func openChat(_ chatDialog: QBChatDialog) {
        guard let window = window,
            let navigationController = window.rootViewController as? UINavigationController else {
                return
        }
        var controllers = [UIViewController]()
        
        for controller in navigationController.viewControllers {
            controllers.append(controller)
            if controller is DialogsViewController {
                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                let chatController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                chatController.dialogID = chatDialog.id
                controllers.append(chatController)
                navigationController.setViewControllers(controllers, animated: true)
                return
            }
        }
    }
}
