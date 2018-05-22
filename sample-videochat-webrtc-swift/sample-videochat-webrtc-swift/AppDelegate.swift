//
//  AppDelegate.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Register new account and application at https://admin.quickblox.com,
        // then put Application credentials from Overview page + Account key from https://admin.quickblox.com/account/settings page
        // here:
        QBSettings.applicationID = 0
        QBSettings.authKey = ""
        QBSettings.authSecret = ""
        QBSettings.accountKey = ""
        QBSettings.autoReconnectEnabled = true
        
        return true
    }
}

