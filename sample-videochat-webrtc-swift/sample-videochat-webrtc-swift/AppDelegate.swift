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
import SVProgressHUD

//To update the Credentials, please see the README file.
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
    static let enableStatsReports: UInt = 1
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        return backgroundTask
    }()
    
    var window: UIWindow?
    
    var isCalling = false {
        didSet {
            switch UIApplication.shared.applicationState {
            case .active:
                break
            case .inactive:
                break
            case .background:
                if isCalling == false {
                    disconnect()
                }
                break
            default:
                break
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        QBSettings.applicationID = CredentialsConstant.applicationID;
        QBSettings.authKey = CredentialsConstant.authKey
        QBSettings.authSecret = CredentialsConstant.authSecret
        QBSettings.accountKey = CredentialsConstant.accountKey
        QBSettings.autoReconnectEnabled = true
        QBSettings.logLevel = QBLogLevel.nothing
        QBRTCConfig.setAnswerTimeInterval(TimeIntervalConstant.answerTimeInterval)
        QBRTCConfig.setDialingTimeInterval(TimeIntervalConstant.dialingTimeInterval)
        QBRTCConfig.setLogLevel(QBRTCLogLevel.nothing)
        
        if AppDelegateConstant.enableStatsReports == 1 {
            QBRTCConfig.setStatsReportTimeInterval(1.0)
        }
        
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.clear)
        QBRTCClient.initializeRTC()

        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Logging out from chat.
        if isCalling == false {
            disconnect()
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Logging in to chat.
        if QBChat.instance.isConnected == true {
            return
        }
        connect { (error) in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
                return
            }
            SVProgressHUD.showSuccess(withStatus: "Connected")
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Logging out from chat.
        disconnect()
    }
    
    //MARK: - Connect/Disconnect
    func connect(completion: QBChatCompletionBlock? = nil) {
        let currentUser = Profile()
        
        guard currentUser.isFull == true else {
            completion?(NSError(domain: LoginConstant.chatServiceDomain,
                                code: LoginConstant.errorDomaimCode,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Please enter your login and username."
                ]))
            return
        }
        if QBChat.instance.isConnected == true {
            completion?(nil)
        } else {
            QBSettings.autoReconnectEnabled = true
            QBChat.instance.connect(withUserID: currentUser.ID, password: currentUser.password, completion: completion)
        }
    }
    
    func disconnect(completion: QBChatCompletionBlock? = nil) {
        QBChat.instance.disconnect(completionBlock: completion)
    }
}
