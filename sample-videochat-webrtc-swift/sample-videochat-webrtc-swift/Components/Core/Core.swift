//
//  Core.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/7/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD
import SystemConfiguration
import UserNotifications

enum NetworkConnectionStatus: UInt {
    case notConnection
    case viaWiFi
    case viaWWAN
}

enum ErrorDomain: UInt {
    case signUp
    case logIn
    case logOut
    case chat
}

struct LoginStatusConstant {
    static let signUp = "Signg up ..."
    static let intoChat = "Login into chat ..."
    static let withCurrentUser = "Login with current user ..."
}

struct CoreConstants {
    static let defaultPassword = "x6Bt0VDy5"
    static let notSatisfyingDeviceToken = "Invalid parameter not satisfying: deviceToken != nil"
}

typealias NetworkStatusBlock = ((_ status: NetworkConnectionStatus) -> Void)?

protocol CoreDelegate: class {
    /**
     *  Notifying about successful login.
     *
     *  @param core QBCore instance
     */
    func coreDidLogin(_ core: Core)
    
    /**
     *  Notifying about successful logout.
     *
     *  @param core QBCore instance
     */
    func coreDidLogout(_ core: Core)
    
    func core(_ core: Core, loginStatus: String)
    
    func core(_ core: Core, error: Error, domain: ErrorDomain)
}

class Core: NSObject {
    
    // MARK: shared Instance
    static let instance: Core = {
        let core = Core()
        core.commonInit()
        return core
    }()
    
    // MARK: Variables
    var currentUser: QBUUser?
    var profile: Profile? {
        didSet {
            currentUser = profile?.userData
        }
    }
    var networkStatusBlock: NetworkStatusBlock?
    var multicastDelegate: CoreDelegate?
    private var currentReachabilityFlags: SCNetworkReachabilityFlags?
    private let reachabilitySerialQueue = DispatchQueue.main
    var reachabilityRef: SCNetworkReachability?
    
    var isAutorized = false
    
    // MARK: - Common Init
    private func commonInit() {
        self.multicastDelegate = QBMulticastDelegate() as? (QBMulticastDelegate & CoreDelegate)
        self.profile = Profile()
        QBSettings.autoReconnectEnabled = true
        QBChat.instance.addDelegate(self)
        self.startReachabliyty()
    }
    
    // MARK: Multicast Delegate
    func addDelegate(_ delegate: CoreDelegate) {
        ////addDelegate
        self.multicastDelegate = delegate
    }
    
    // MARK: - SignUp / Login / Logout
    
    func setLoginStatus(_ loginStatus: String) {
        if let _ = self.multicastDelegate?.core(self, loginStatus: loginStatus) {
            self.multicastDelegate?.core(self, loginStatus: loginStatus)
        }
    }
    
    /**
     *  Signup and login
     *
     *  @param fullName User name
     *  @param roomName room name (tag)
     */
    func signUp(withFullName fullName: String?, roomName: String?) {
        let newUser = QBUUser()
        newUser.login = UUID().uuidString
        newUser.fullName = fullName
        newUser.tags = [roomName] as? [String]
        newUser.password = CoreConstants.defaultPassword
        
        self.setLoginStatus(LoginStatusConstant.signUp)
        
        QBRequest.signUp(newUser, successBlock: { [weak self] response, user in
            
            guard let profile = self?.profile else {
                return
            }
            let status = profile.synchronizeWithUserData(userData: user)
            if status == noErr {
                self?.currentUser = user
                self?.loginWithCurrentUser()
            } else {
                self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
            }
            }, errorBlock: { [weak self] response in
                self?.handleError(response.error?.error, domain: ErrorDomain.signUp)
        })
    }
    
    /**
     *  login
     */
    func loginWithCurrentUser() {
        self.currentUser?.password = CoreConstants.defaultPassword
        guard let user = self.currentUser else {return}
        let password = CoreConstants.defaultPassword
        guard let login = self.currentUser?.login else {return}
        
        let connectToChat: () -> () = {
            self.setLoginStatus(LoginStatusConstant.intoChat)
            QBChat.instance.connect(withUserID: user.id, password: password, completion: { [weak self] error in
                guard let `self` = self else { return }
                if error != nil {
                    
                    if (error as NSError?)?.code == 401 {
                        
                        self.isAutorized = false
                        // Clean profile
                        self.clearProfile()
                        // Notify about logout
                        //add multicastDelegate metod
                        if let _ = self.multicastDelegate?.coreDidLogout {
                            self.multicastDelegate?.coreDidLogout(self)
                        }
                    } else {
                        self.handleError(error, domain: ErrorDomain.logIn)
                    }
                } else {
                    //add multicastDelegate metod
                    if let delegate = self.multicastDelegate {
                        delegate.coreDidLogin(self)
                    }
                }
            })
        }
        if isAutorized == true {
            connectToChat()
            return
        }
        self.setLoginStatus(LoginStatusConstant.withCurrentUser)
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { [weak self] response, user in
                            self?.isAutorized = true
                            connectToChat()
                            self?.registerForRemoteNotifications()
                            
            }, errorBlock: { [weak self] response in
                self?.handleError(response.error?.error, domain: ErrorDomain.logIn)
                if response.status == QBResponseStatusCode.unAuthorized {
                    // Clean profile
                    self?.clearProfile()
                }
        })
    }
    
    /**
     *  Clear current profile (Keychain)
     */
    public func clearProfile() {
        guard let profile = profile else {
            return
        }
        let status = profile.clearProfile()
        if status == noErr {
            currentUser = nil
        }
    }
    
    /**
     *  Logout and remove current user from server
     */
    func logout() {
        let logoutGroup = DispatchGroup()
        logoutGroup.enter()
        unsubscribe(fromRemoteNotifications: {
            logoutGroup.leave()
        })
        logoutGroup.enter()
        QBChat.instance.disconnect(completionBlock: { error in
            logoutGroup.leave()
        })
        logoutGroup.notify(queue: .main) {
            // Delete user from server
            QBRequest.deleteCurrentUser(successBlock: { response in
                self.isAutorized = false
                // Clean profile
                self.clearProfile()
                // Notify about logout
                if let _ = self.multicastDelegate?.coreDidLogout {
                    self.multicastDelegate?.coreDidLogout(self)
                } else {
                }
            }, errorBlock: { response in
                self.handleError(response.error?.error, domain: ErrorDomain.logOut)
            })
        }
    }
    
    // MARK: - Handle errors
    func handleError(_ error: Error?, domain: ErrorDomain) {
        if let delegate = self.multicastDelegate {
            delegate.core(self, error: error!, domain: domain)
        }
    }
    
    // MARK: - Push Notifications
    /**
     *  Create subscription.
     *
     *  @param deviceToken Identifies client device
     */
    func registerForRemoteNotifications() {
        let app = UIApplication.shared
        
        if app.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            
            let type: UIUserNotificationType = [.sound, .alert, .badge]
            
            let settings = UIUserNotificationSettings(types: type, categories: nil)
            
            app.registerUserNotificationSettings(settings)
            app.registerForRemoteNotifications()
        }
    }
    
    func registerForRemoteNotifications(withDeviceToken deviceToken: Data?) {
        assert(deviceToken != nil, CoreConstants.notSatisfyingDeviceToken)
        let subscription = QBMSubscription()
        subscription.notificationChannel = QBMNotificationChannel.APNS
        subscription.deviceUDID = UIDevice.current.identifierForVendor?.uuidString
        subscription.deviceToken = deviceToken
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            
        }, errorBlock: { response in
            debugPrint("response error: \(String(describing: response.error))")
        })
    }
    
    func unsubscribe(fromRemoteNotifications completionBlock: @escaping () -> ()) {
        guard let uuidString = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: uuidString, successBlock: { response in
            completionBlock()
        }, errorBlock: { error in
            completionBlock()
        })
    }
    
    // MARK: - Reachability
    /**
     *  Cheker for internet connection
     */
    public func networkConnectionStatus() -> NetworkConnectionStatus {
        let status: NetworkConnectionStatus = .notConnection
        if let reachabilityRef = reachabilityRef {
            var flags: SCNetworkReachabilityFlags = []
            if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
                return self.networkStatusForFlags(flags)
            }
        }
        return status
    }
    
    private func networkStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkConnectionStatus {
        if flags.contains(.reachable) == false {
            return .notConnection
        }
        else if flags.contains(.isWWAN) == true {
            return .viaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            return .viaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true
            || flags.contains(.connectionOnTraffic) == true)
            && flags.contains(.interventionRequired) == false {
            return .viaWiFi
        }
        else {
            return .notConnection
        }
    }
    
    private func checkReachability(flags: SCNetworkReachabilityFlags) {
        if currentReachabilityFlags != flags {
            currentReachabilityFlags = flags
            reachabilityChanged(flags)
        }
    }
    
    private func startReachabliyty() {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return
        }
        self.reachabilityRef = defaultRouteReachability
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Core>.passUnretained(self).toOpaque())
        
        let callbackClosure: SCNetworkReachabilityCallBack? = {
            (reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            guard let info = info else {
                return
            }
            let handler = Unmanaged<Core>.fromOpaque(info).takeUnretainedValue()
            
            DispatchQueue.main.async {
                handler.checkReachability(flags: flags)
            }
        }
        
        if let reachabilityRef = self.reachabilityRef {
            if SCNetworkReachabilitySetCallback(reachabilityRef, callbackClosure, &context) {
                if (SCNetworkReachabilitySetDispatchQueue(reachabilityRef, self.reachabilitySerialQueue)) {
                }
                else {
                    SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil);
                }
            }
        }
    }
    
    func reachabilityChanged(_ flags: SCNetworkReachabilityFlags) {
        DispatchQueue.main.async(execute: {
            guard let networkStatusBlock = self.networkStatusBlock else {
                return
            }
            networkStatusBlock?(self.networkStatusForFlags(flags))
        })
    }
}

extension Core: QBChatDelegate {
    // MARK: - QBChatDelegate
    func chatDidNotConnectWithError(_ error: Error) {
    }
    
    func chatDidFail(withStreamError error: Error) {
        debugPrint("chatDidFail")
    }
    
    func chatDidAccidentallyDisconnect() {
        debugPrint("chatDidAccidentallyDisconnect")
    }
    
    func chatDidReconnect() {
        debugPrint("chatDidReconnect")
    }
}

