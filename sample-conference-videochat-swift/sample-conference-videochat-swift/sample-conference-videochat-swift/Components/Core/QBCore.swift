//
//  QBCore.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
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
    case ErrorDomainSignUp = 0
    case ErrorDomainLogIn = 1
    case ErrorDomainLogOut = 2
    case ErrorDomainChat = 3
}

struct QBCoreConstants {
    static let kQBDefaultPassword = "x6Bt0VDy5"
}

typealias QBNetworkStatusBlock = ((_ status: NetworkConnectionStatus) -> Void)?

protocol QBCoreDelegate: class {
    /**
     *  Notifying about successful login.
     *
     *  @param core QBCore instance
     */
    func coreDidLogin(_ core: QBCore)
    
    /**
     *  Notifying about successful logout.
     *
     *  @param core QBCore instance
     */
    func coreDidLogout(_ core: QBCore)
    
    func core(_ core: QBCore, _ loginStatus: String)
    
    func core(_ core: QBCore, _ error: Error, _ domain: ErrorDomain)
}

class QBCore: NSObject, QBChatDelegate {
    
    // MARK: shared Instance
    //    static let instance = QBCore()
    static let instance: QBCore = {
        let core = QBCore()
        core.commonInit()
        return core
    }()
    
    // MARK: Variables
    var currentUser: QBUUser?{
        didSet {
            debugPrint("currentUser didSet \(String(describing: currentUser))")
        }
    }
    var profile: QBProfile?{
        didSet {
            debugPrint("profile didSet \(String(describing: profile))")
            currentUser = profile?.userData
        }
    }
    var networkStatusBlock: QBNetworkStatusBlock?
    var multicastDelegate: QBCoreDelegate?
    private var currentReachabilityFlags: SCNetworkReachabilityFlags?
    private let reachabilitySerialQueue = DispatchQueue.main
    
    var reachabilityRef: SCNetworkReachability? {
        didSet {
            debugPrint("reachabilityRef didSet \(String(describing: reachabilityRef))")
        }
    }
    
    var isAutorized: Bool? {
        didSet {
            debugPrint("isAutorized didSet \(String(describing: isAutorized))")
        }
    }
    
    // MARK: - Common Init
    private func commonInit() {
        self.multicastDelegate = QBMulticastDelegate() as? (QBMulticastDelegate & QBCoreDelegate)
        self.profile = QBProfile()
        QBSettings.autoReconnectEnabled = true
        QBChat.instance.addDelegate(self)
        self.startReachabliyty()
    }
    
    // MARK: Multicast Delegate
    func addDelegate(_ delegate: QBCoreDelegate) {
        ////addDelegate
        debugPrint("delegate \(delegate)")
        //        self.multicastDelegate?.addDelegate(delegate)
    }
    
    // MARK: - QBChatDelegate
    func chatDidNotConnectWithError(_ error: Error) {
        debugPrint("chatDidNotConnectWithError")
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
    
    // MARK: - SignUp / Login / Logout
    
    func setLoginStatus(_ loginStatus: String?) {
        debugPrint("loginStatus \(loginStatus!)")
        
        if let _ = self.multicastDelegate?.core(self, loginStatus!) {
            self.multicastDelegate?.core(self, loginStatus!)
        }else {
            debugPrint("delegate not response coreloginStatus metod")
        }
    }
    
    /**
     *  Signup and login
     *
     *  @param fullName User name
     *  @param roomName room name (tag)
     */
    func signUp(withFullName fullName: String?, roomName: String?) {
        
        assert(self.currentUser == nil, "Invalid parameter not satisfying: !isCurrentUser")
        
        let newUser = QBUUser()
        
        newUser.login = UUID().uuidString
        newUser.fullName = fullName
        newUser.tags = [roomName] as? [String]
        newUser.password = QBCoreConstants.kQBDefaultPassword
        
        self.setLoginStatus("Signg up ...")
        
        QBRequest.signUp(newUser, successBlock: { response, user in
            self.profile?.synchronizeWithUserData(userData: user)
            self.currentUser = user
            self.loginWithCurrentUser()
            
        }, errorBlock: { response in
            
            self.handleError(response.error?.error, domain: ErrorDomain.ErrorDomainSignUp)
        })
    }
    
    /**
     *  login
     */
    func loginWithCurrentUser() {
        
        self.currentUser?.password = QBCoreConstants.kQBDefaultPassword
        guard let user = self.currentUser else {return}
        let password = QBCoreConstants.kQBDefaultPassword
        guard let login = self.currentUser?.login else {return}
        
        let connectToChat: () -> () = {
            
            self.setLoginStatus("Login into chat ...")
            
            QBChat.instance.connect(withUserID: user.id, password: password, completion: { error in
                
                if error != nil {
                    
                    if (error as NSError?)?.code == 401 {
                        
                        self.isAutorized = false
                        // Clean profile
                        self.clearProfile()
                        // Notify about logout
                        //add multicastDelegate metod
                        if let coreDidLogout = self.multicastDelegate?.coreDidLogout {
                            coreDidLogout(self)
                        }else {
                            debugPrint("delegate not response coreDidLogout metod ==============")
                        }
                    } else {
                        self.handleError(error, domain: ErrorDomain.ErrorDomainLogIn)
                    }
                } else {
                    //add multicastDelegate metod
                    if let delegate = self.multicastDelegate {
                        delegate.coreDidLogin(self)
                    }else {
                        debugPrint("delegate not response coreDidLogin metod")
                    }
                }
            })
        }
        
        if isAutorized == true {
            
            connectToChat()
            return
        }
        
        self.setLoginStatus("Login with current user ...")
        QBRequest.logIn(withUserLogin: login,
                        password: password,
                        successBlock: { response, user in
                            self.isAutorized = true
                            
                            connectToChat()
                            
                            self.registerForRemoteNotifications()
                            
        }, errorBlock: { response in
            
            self.handleError(response.error?.error, domain: ErrorDomain.ErrorDomainLogIn)
            
            if response.status == QBResponseStatusCode.unAuthorized {
                // Clean profile
                self.clearProfile()
            }
        })
    }
    
    /**
     *  Clear current profile (Keychain)
     */
    public func clearProfile() {
        self.profile?.clearProfile()
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
                if let coreDidLogout = self.multicastDelegate?.coreDidLogout {
                    coreDidLogout(self)
                } else {
                    debugPrint("delegate not response coreDidLogout metod!!!!!!!!!!")
                }
            }, errorBlock: { response in
                self.handleError(response.error?.error, domain: ErrorDomain.ErrorDomainLogOut)
            })
        }
    }
    
    // MARK: - Handle errors
    func handleError(_ error: Error?, domain: ErrorDomain) {
        
        if let delegate = self.multicastDelegate {
            delegate.core(self, error!, domain)
        }else {
            debugPrint("delegate not response coreWithDomain metod")
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
        
        assert(deviceToken != nil, "Invalid parameter not satisfying: deviceToken != nil")
        
        let subscription = QBMSubscription()
        subscription.notificationChannel = QBMNotificationChannel.APNS
        subscription.deviceUDID = UIDevice.current.identifierForVendor?.uuidString
        subscription.deviceToken = deviceToken
        
        QBRequest.createSubscription(subscription, successBlock: { response, objects in
            
        }, errorBlock: { response in
            
        })
    }
    
    func unsubscribe(fromRemoteNotifications completionBlock: @escaping () -> ()) {
        
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: (UIDevice.current.identifierForVendor?.uuidString)!, successBlock: { response in
            //if completionBlock
            completionBlock()
            
        }, errorBlock: { error in
            //if completionBlock
            completionBlock()
        })
    }
    
    // MARK: - Reachability
    /**
     *  Cheker for internet connection
     */
    public func networkConnectionStatus() -> NetworkConnectionStatus {
        let status:NetworkConnectionStatus = NetworkConnectionStatus.notConnection
        if let reachabilityRef = self.reachabilityRef {
            var flags: SCNetworkReachabilityFlags = []
            if SCNetworkReachabilityGetFlags(reachabilityRef, &flags) {
                return self.networkStatusForFlags(flags)
            }
        }
        return status
    }
    
    private func networkStatusForFlags(_ flags: SCNetworkReachabilityFlags) -> NetworkConnectionStatus{
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
        context.info = UnsafeMutableRawPointer(Unmanaged<QBCore>.passUnretained(self).toOpaque())
        
        let callbackClosure: SCNetworkReachabilityCallBack? = {
            (reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            guard let info = info else { return }
            let handler = Unmanaged<QBCore>.fromOpaque(info).takeUnretainedValue()
            
            DispatchQueue.main.async {
                handler.checkReachability(flags: flags)
            }
        }
        
        if SCNetworkReachabilitySetCallback(reachabilityRef!, callbackClosure, &context) {
            if (SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef!, self.reachabilitySerialQueue)) {
                
            }
            else {
                debugPrint("SCNetworkReachabilitySetDispatchQueue() failed: \(SCErrorString(SCError()))")
                SCNetworkReachabilitySetCallback(self.reachabilityRef!, nil, nil);
            }
        }
    }
    
    func reachabilityChanged(_ flags: SCNetworkReachabilityFlags) {
        DispatchQueue.main.async(execute: {
            if let networkStatusBlock = self.networkStatusBlock {
                networkStatusBlock!(self.networkStatusForFlags(flags))
            }
        })
    }
}


