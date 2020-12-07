//
//  NotificationsProvider.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 3/20/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

import Foundation
import UserNotifications
import PushKit
import CallKit
import Quickblox
import SVProgressHUD

enum PushType {
    case apns
    case apnsVoip
}

protocol NotificationsProviderDelegate: class {
    func notificationsProvider(_ notificationsProvider: NotificationsProvider, didReceive messages: [String])
}

class NotificationsProvider: NSObject {
    weak var delegate: NotificationsProviderDelegate?
    private var voipRegistry: PKPushRegistry = PKPushRegistry(queue: DispatchQueue.main)
    private var provider: CXProvider?
    private var callController: CXCallController?
    
    override init() {
        super.init()
        
        registerForRemoteNotifications()
        
        let configuration: CXProviderConfiguration? = self.configuration()
        if let configuration = configuration {
            provider = CXProvider(configuration: configuration)
        }
        callController = CXCallController(queue: DispatchQueue.main)
        
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set<PKPushType>([.voIP])
    }
}

//MARK: - APNS
//MARK: - UNUserNotificationCenterDelegate
extension NotificationsProvider: UNUserNotificationCenterDelegate {
    private func registerForRemoteNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
            if let error = error {
                SVProgressHUD.showError(withStatus: error.localizedDescription)
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
    
    private func parseNotification(_ notification: UNNotification) -> String {
        let userInfo = notification.request.content.userInfo
        guard let messageDict = userInfo[QBMPushMessageApsKey] as? [String: AnyObject],
            let message = messageDict[QBMPushMessageAlertKey] as? String else {
                return "APNS: Unreadable message"
        }
        return "APNS: " + message
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        delegate?.notificationsProvider(self, didReceive: [parseNotification(notification)])
        center.removeAllDeliveredNotifications()
        completionHandler([.sound, .alert, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        var messages = [parseNotification(response.notification)]
        center.getDeliveredNotifications { (notifications) in
            for notification in notifications {
                if notification == response.notification {
                    continue
                }
                messages.insert(self.parseNotification(notification), at: 0)
            }
            center.removeAllDeliveredNotifications()
            DispatchQueue.main.async {
                self.delegate?.notificationsProvider(self, didReceive: messages)
            }
        }
        completionHandler()
    }
}

//MARK: - VOIP
//MARK: - PKPushRegistryDelegate
extension NotificationsProvider: PKPushRegistryDelegate {
    // MARK: - PKPushRegistryDelegate
    private func configuration() -> CXProviderConfiguration? {
           let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
           let config = CXProviderConfiguration(localizedName: appName ?? "")
           config.supportsVideo = true
           config.maximumCallsPerCallGroup = 1
           config.maximumCallGroups = 1
           let supportedHandleTypes: Set = [CXHandle.HandleType.generic, CXHandle.HandleType.phoneNumber]
           config.supportedHandleTypes = supportedHandleTypes
           if let image = UIImage(named: "CallKitLogo") {
               config.iconTemplateImageData = image.pngData()
           }
           config.ringtoneSound = "ringtone.wav"
           return config
       }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        guard let voipToken = registry.pushToken(for: .voIP) else {
            return
        }
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        let subscription = QBMSubscription()
        subscription.notificationChannel = .APNSVOIP
        subscription.deviceUDID = deviceIdentifier
        subscription.deviceToken = voipToken
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            debugPrint("[NotificationsProvider] Create VOIP Subscription request - Success")
        }, errorBlock: { response in
            debugPrint("[NotificationsProvider] Create VOIP Subscription request - Error")
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let uuidString = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        
        QBRequest.subscriptions(successBlock: { (response, subscriptions) in
            guard let subscriptions = subscriptions, subscriptions.isEmpty == false else {
                return
            }
            for subscription in subscriptions {
                if let subscriptionsUIUD = subscription.deviceUDID,
                   subscriptionsUIUD == uuidString,
                   subscription.notificationChannel == .APNSVOIP {
                    QBRequest.deleteSubscription(withID: subscription.id) { (response) in
                        debugPrint("[NotificationsProvider] Unregister VOIP Subscription request - Success")
                    } errorBlock: { (response) in
                        debugPrint("[NotificationsProvider] Unregister VOIP Subscription request - Error")
                    }
                }
            }
        }) { (response) in
            debugPrint("[NotificationsProvider] Subscriptions request - Error")
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry,
                      didReceiveIncomingPushWith payload: PKPushPayload,
                      for type: PKPushType,
                      completion: @escaping () -> Void) {
        let application = UIApplication.shared
        if application.applicationState != .active {
            return
        }
        if type == .voIP {
            if application.applicationState == .active {
                var message = "VOIP PUSH from Admin"
                if let alertMessage = payload.dictionaryPayload["alertMessage"] as? String {
                    message = alertMessage
                }
                message = "VOIP: " + message
                delegate?.notificationsProvider(self, didReceive: [message])
                completion()
            }
        }
    }
}
