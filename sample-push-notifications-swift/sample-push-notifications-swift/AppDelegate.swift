//
//  AppDelegate.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 3/19/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD

//To update the Credentials, please see the README file.
struct CredentialsConstant {
    static let applicationID:UInt = 0
    static let authKey = ""
    static let authSecret = ""
    static let accountKey = ""
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = CredentialsConstant.applicationID
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = RootParentVC()
        window?.makeKeyAndVisible()
        
        return true
    }
    
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
            SVProgressHUD.dismiss()
        }, errorBlock: { response in
            SVProgressHUD.showError(withStatus: response.error?.description)
        })
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
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
