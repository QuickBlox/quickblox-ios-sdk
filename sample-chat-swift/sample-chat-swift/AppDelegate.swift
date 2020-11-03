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
        QBSettings.disableFileLogging()
        QBSettings.autoReconnectEnabled = true
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootParentVC()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Logging out from chat.
        ChatManager.instance.disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        ChatManager.instance.connect()
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
        debugPrint("[AppDelegate] Unable to register for remote notifications: \(error.localizedDescription)")
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if UIApplication.shared.applicationState == .active {
            completionHandler()
            return
        }
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        guard let dialogID = userInfo["SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized] as? String,
              dialogID.isEmpty == false else {
            completionHandler()
            return
        }
        DispatchQueue.main.async {
            if ChatManager.instance.storage.dialog(withID: dialogID) != nil {
                self.rootViewController.dialogID = dialogID
            } else {
                ChatManager.instance.loadDialog(withID: dialogID, completion: { (loadedDialog: QBChatDialog?) -> Void in
                    guard loadedDialog != nil else {
                        return
                    }
                    self.rootViewController.dialogID = dialogID
                })
            }
        }
        completionHandler()
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

extension AppDelegate {
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var rootViewController: RootParentVC {
        return window!.rootViewController as! RootParentVC
    }
}
