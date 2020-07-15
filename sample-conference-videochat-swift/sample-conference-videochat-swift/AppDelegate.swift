//
//  AppDelegate.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import UserNotifications
import QuickbloxWebRTC
import SVProgressHUD

// To update the QuickBlox credentials, please see the READMe file.(You must create application in admin.quickblox.com)
struct CredentialsConstant {
static let applicationID:UInt = 0
static let authKey = ""
static let authSecret = ""
static let accountKey = ""
}

struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 60.0
    static let dialingTimeInterval: TimeInterval = 5.0
}

struct AppDelegateConstant {
    static let assertMessage = "Multi-conference server is available only for Enterprise plans. Please refer to https://quickblox.com/developers/EnterpriseFeatures for more information and contacts."
    static let enableStatsReports: UInt = 1
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var isCalling = false {
        didSet {
            if UIApplication.shared.applicationState == .background,
                isCalling == false {
                disconnect()
            }
        }
    }
    
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
        QBSettings.carbonsEnabled = false
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .nothing
        // Enables detailed XMPP logging in console output.
        QBSettings.disableXMPPLogging()
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.nothing)
        QBRTCConfig.setConferenceEndpoint("")
        assert((QBRTCConfig.conferenceEndpoint()?.count)! > 0, AppDelegateConstant.assertMessage)
        
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        QBRTCClient.initializeRTC()

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
        ChatManager.instance.connect { (error) in
            if let _ = error {
                return
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Logging out from chat.
        ChatManager.instance.disconnect()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Logging out from chat.
        ChatManager.instance.disconnect()
    }
    
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        QBChat.instance.disconnect(completionBlock: completion)
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
        if self.isCalling == true {
            NotificationCenter.default.post(name: CallConstants.didRecivePushAndOpenCallChatNotification,
                                            object: nil,
                                            userInfo: nil)
        } else {
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
