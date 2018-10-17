//
//  AppDelegate.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import Fabric
import Crashlytics
import SVProgressHUD

// Credentials for Test Sample App
let kQBApplicationID:UInt = 73803
let kQBAuthKey = "qp4zDcV8mk29Qp9"
let kQBAuthSecret = "Hm2KgDE6eeMZHu5"
let kQBAccountKey = "uK_8uinNyz8-npTNB6tx"

//const NSUInteger kApplicationID = 73803;
//NSString *const kAuthKey        = @"qp4zDcV8mk29Qp9";
//NSString *const kAuthSecret     = @"Hm2KgDE6eeMZHu5";
//NSString *const kAccountKey     = @"uK_8uinNyz8-npTNB6tx";

let kQBAnswerTimeInterval: TimeInterval = 60.0
let kQBDialingTimeInterval: TimeInterval = 5.0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Fabric.with([Crashlytics.self])
        
        QBSettings.applicationID = kQBApplicationID;
        QBSettings.authKey = kQBAuthKey
        QBSettings.authSecret = kQBAuthSecret
        QBSettings.accountKey = kQBAccountKey
        QBSettings.autoReconnectEnabled = true
        
        QBSettings.logLevel = QBLogLevel.nothing
        QBSettings.disableXMPPLogging()
        
        QBRTCConfig.setAnswerTimeInterval(kQBAnswerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(kQBDialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)
        
        QBRTCConfig.setConferenceEndpoint("wss://janusdev.quickblox.com:8989")
        assert((QBRTCConfig.conferenceEndpoint()?.count)! > 0, "Multi-conference server is available only for Enterprise plans. Please refer to https://quickblox.com/developers/EnterpriseFeatures for more information and contacts.")
        
        #if ENABLE_STATS_REPORTS
        QBRTCConfig.setStatsReportTimeInterval(1.0)
        #endif
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        
        QBRTCClient.initializeRTC()
        
        // loading settings
        Settings.instance
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

