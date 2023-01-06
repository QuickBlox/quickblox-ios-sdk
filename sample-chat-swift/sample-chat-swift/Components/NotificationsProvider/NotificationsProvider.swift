//
//  NotificationsProvider.swift
//  sample-chat-swift
//
//  Created by Injoit on 16.12.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import Foundation
import UserNotifications
import Quickblox

enum PushType {
    case apns
}

struct NotificationsConstant {
    static let subscriptionID = "last_apns_subscription_id"
    static let token = "last_apns_token"
    static let needUpdateToken = "last_apns_token_need_update"
}

protocol NotificationsProviderDelegate: AnyObject {
    func notificationsProvider(_ notificationsProvider: NotificationsProvider, didReceive dialogID: String)
}

class NotificationsProvider: NSObject {
    weak var delegate: NotificationsProviderDelegate?
    
    private func parseNotification(_ notification: UNNotification) -> String {
        let userInfo = notification.request.content.userInfo
        guard let dialogID = userInfo[Key.dialogId] as? String,
              dialogID.isEmpty == false else {
            return ""
        }
        return dialogID
    }
    
    static func prepareSubscription(withToken token: Data) {
        let userDefaults = UserDefaults.standard
        if let lastToken = userDefaults.object(forKey: NotificationsConstant.token) as? Data,
           token == lastToken {
            return
        }
        userDefaults.setValue(token, forKey: NotificationsConstant.token)
        userDefaults.set(true, forKey: NotificationsConstant.needUpdateToken)
        deleteLastSubscription {
            self.createSubscription(withToken: token)
        }
    }
    
    static func clearSubscription(withCompletion completion:@escaping () -> Void) {
        UserDefaults.standard.removeObject(forKey: NotificationsConstant.token)
        deleteLastSubscription{
            completion()
        }
    }
    
    static func createSubscription(withToken token: Data) {
        guard let deviceUUID = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let userDefaults = UserDefaults.standard
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNS
        subscription.deviceUDID = deviceUUID
        subscription.deviceToken = token
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            guard let subscriptions = objects, subscriptions.isEmpty == false else {
                return
            }
            var newSubscription: QBMSubscription? = nil
            for subscription in subscriptions {
                if subscription.notificationChannel == .APNS,
                   let subscriptionsUIUD = subscription.deviceUDID,
                   subscriptionsUIUD == deviceUUID {
                    newSubscription = subscription
                }
            }
            guard let newSubscriptionID = newSubscription?.id else {
                return
            }
            userDefaults.setValue(NSNumber(value: newSubscriptionID), forKey: NotificationsConstant.subscriptionID)
            debugPrint("[\(NotificationsProvider.className)] \(#function) Create APNS Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[\(NotificationsProvider.className)] \(#function) Create APNS Subscription request - Error")
        })
    }
    
   static func deleteLastSubscription(withCompletion completion:@escaping () -> Void) {
       let userDefaults = UserDefaults.standard
       defer {
           completion()
       }
       guard let lastSubscriptionId = userDefaults.object(forKey: NotificationsConstant.subscriptionID) as? NSNumber  else {
           return
       }
       QBRequest.deleteSubscription(withID: lastSubscriptionId.uintValue) { (response) in
           userDefaults.removeObject(forKey: NotificationsConstant.subscriptionID)
           debugPrint("[\(NotificationsProvider.className)] \(#function) Unregister Subscription request - Success")
       } errorBlock: { (response) in
           debugPrint("[\(NotificationsProvider.className)] \(#function) Unregister Subscription request - Error")
       }
   }
}

//MARK: - APNS
//MARK: - UNUserNotificationCenterDelegate
extension NotificationsProvider: UNUserNotificationCenterDelegate {
    func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, _ in
            if granted == false {
                return
            }
            center.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    return
                }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            })
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active {
            return
        }
        delegate?.notificationsProvider(self, didReceive: parseNotification(notification))
        center.removeAllDeliveredNotifications()
        completionHandler([.banner, .list, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if UIApplication.shared.applicationState == .active {
            return
        }
        delegate?.notificationsProvider(self, didReceive: parseNotification(response.notification))
        completionHandler()
    }
}
