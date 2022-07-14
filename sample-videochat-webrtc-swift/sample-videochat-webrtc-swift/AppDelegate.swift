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

//To update the Credentials, please see the README file.
struct CredentialsConstant {
    static let applicationID:UInt = 0
    static let authKey = ""
    static let authSecret = ""
    static let accountKey = ""
}

struct TimeIntervalConstant {
    static let answerTimeInterval: TimeInterval = 30.0
    static let dialingTimeInterval: TimeInterval = 5.0
}

struct AppDelegateConstant {
    static let enableStatsReports: UInt = 1
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        QBSettings.applicationID = CredentialsConstant.applicationID;
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
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
        
        let storyboard = UIStoryboard(name: "Authorization", bundle: nil)
        let root: UINavigationController = storyboard.instantiateViewController(identifier: "AuthNavVC")
        root.view.backgroundColor = #colorLiteral(red: 0.0862745098, green: 0.4901960784, blue: 0.9882352941, alpha: 1)
        
        let profile = Profile()
        let isLoggedIn = profile.isFull
        
        if isLoggedIn, let users = Screen.usersViewController() {
            var viewControllers = root.viewControllers
            viewControllers.append(users)
            root.setViewControllers(viewControllers, animated: false)
        }

        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.rootViewController = root
        window?.makeKeyAndVisible()

        return true
    }
}
