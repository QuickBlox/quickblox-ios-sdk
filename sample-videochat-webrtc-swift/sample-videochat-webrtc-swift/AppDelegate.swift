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
  static let applicationID:UInt = 72448
  static let authKey = "f4HYBYdeqTZ7KNb"
  static let authSecret = "ZC7dK39bOjVc-Z8"
  static let accountKey = "C4_z7nuaANnBYmsG_k98"
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
    
    Fabric.with([Crashlytics.self])
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
    Settings.instance.load()
    return true
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    if !QBChat.instance.isConnected && Core.instance.isAutorized {
      Core.instance.loginWithCurrentUser()
    }
  }
  // MARK: - Remote Notifictions
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    
    if notificationSettings.types != [] {
      
      print("Did register user notificaiton settings")
      application.registerForRemoteNotifications()
    }
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    
    print("Did register for remote notifications with device token")
    Core.instance.registerForRemoteNotifications(withDeviceToken: deviceToken)
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    
    print("Did receive remote notification \(userInfo)")
  }
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    
    print("Did fail to register for remote notification with error \(error.localizedDescription)")
  }
  
}

