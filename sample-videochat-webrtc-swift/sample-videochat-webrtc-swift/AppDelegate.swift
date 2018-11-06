//
//  AppDelegate.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import Fabric
import Crashlytics

let kQBApplicationID:UInt = 72448
let kQBAuthKey = "f4HYBYdeqTZ7KNb"
let kQBAuthSecret = "ZC7dK39bOjVc-Z8"
let kQBAccountKey = "C4_z7nuaANnBYmsG_k98"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Set QuickBlox credentials (You must create application in admin.quickblox.com).
        QBSettings.applicationID = kQBApplicationID;
        QBSettings.authKey = kQBAuthKey
        QBSettings.authSecret = kQBAuthSecret
        QBSettings.accountKey = kQBAccountKey
        QBSettings.autoReconnectEnabled = true
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
}

