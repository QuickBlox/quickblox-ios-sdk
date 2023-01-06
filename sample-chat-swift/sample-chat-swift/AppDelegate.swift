//
//  AppDelegate.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        application.applicationIconBadgeNumber = 0
        window?.backgroundColor = .white;
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        Quickblox.initWithApplicationId(0,
                                        authKey: "",
                                        authSecret: "",
                                        accountKey: "")
        // enabling carbons for chat
        QBSettings.carbonsEnabled = true
        // Enables Quickblox REST API calls debug console output.
        QBSettings.logLevel = .debug
        // Enables detailed XMPP logging in console output.
        QBSettings.enableXMPPLogging()
        QBSettings.disableFileLogging()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = PresenterViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    //MARK: - UNUserNotification
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationsProvider.prepareSubscription(withToken: deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("[AppDelegate] Unable to register for remote notifications: \(error.localizedDescription)")
    }
}
