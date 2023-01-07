//
//  AppDelegate.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/7/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 30.0
    static let dialingTimeInterval: TimeInterval = 3.0
}

struct AppDelegateConstant {
    static let enableStatsReports: UInt = 1
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //To update the Credentials, please see the README file.
        Quickblox.initWithApplicationId(0,
                                        authKey: "",
                                        authSecret: "",
                                        accountKey: "")

        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = .nothing
        QBSettings.disableXMPPLogging()
        QBSettings.disableFileLogging()
        QBRTCConfig.setLogLevel(.nothing)
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(3.0)
        }
        QBRTCClient.initializeRTC()
        
        let settings = Settings()
        settings.mediaConfiguration.videoCodec = .VP8
        settings.saveToDisk()
        settings.applyConfig()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = PresenterViewController()
        window?.makeKeyAndVisible()

        return true
    }
}
