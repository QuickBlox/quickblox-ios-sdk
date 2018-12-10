//
//  AppDelegate.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/7/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import Fabric
import Crashlytics
import SVProgressHUD

struct CredentialsConstant {
    static let applicationID:UInt = 73803
    static let authKey = "qp4zDcV8mk29Qp9"
    static let authSecret = "Hm2KgDE6eeMZHu5"
    static let accountKey = "uK_8uinNyz8-npTNB6tx"
}

struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 60.0
    static let dialingTimeInterval: TimeInterval = 5.0
}

struct AppDelegateConstant {
    static let enableStatsReports: UInt = 1
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //        Fabric.with([Crashlytics.self])
        QBSettings.applicationID = CredentialsConstant.applicationID;
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.debug
        QBSettings.enableXMPPLogging()
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.verbose)
        
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        QBRTCClient.initializeRTC()
        
        // loading settings
        //        Settings.instance.load()
        return true
    }
}

