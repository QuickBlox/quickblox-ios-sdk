//
//  ConnectionModule.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 02.04.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SystemConfiguration

struct ConnectionConstant {
    static let connectingState = "Still in connecting state, please wait"
    static let reconnectingState = "Reconnecting state, please wait"
    static let connectionEstablished = "Connection established"
    static let noInternetConnection = "No Internet Connection"
}

typealias CompletionAction = (() -> Void)

@objc protocol ConnectionModuleDelegate: AnyObject {
    @objc optional func connectionModuleWillConnect(_ connectionModule: ConnectionModule)
    @objc optional func connectionModuleDidConnect(_ connectionModule: ConnectionModule)
    @objc optional func connectionModuleDidNotConnect(_ connectionModule: ConnectionModule, error: Error)
    @objc optional func connectionModuleWillReconnect(_ connectionModule: ConnectionModule)
    @objc optional func connectionModuleDidReconnect(_ connectionModule: ConnectionModule)
    @objc optional func connectionModuleTokenHasExpired(_ connectionModule: ConnectionModule)
}

/// The module is responsible for automatic connection establishment with QuickBlox.
///
/// The connection depends on the application state and call activity.
/// The establishing connection process can start from the authorization if the "QBSession" token was expired.
class ConnectionModule: NSObject {
    //MARK: - Properties
    weak var delegate: ConnectionModuleDelegate?
    private var appActiveStateObserver: Any?
    /// Determining the connection state.
    ///
    /// Calling this property starts the connection process when it's not established.
    var established: Bool {
        var connected = false
        if tokenHasExpired == false, QBChat.instance.isConnected {
            connected = true
        }
        return connected
    }
    /// Determining the "QBSession" token state.
    var tokenHasExpired: Bool {
        return QBSession.current.tokenHasExpired
    }
    
    private var isReachability: SCNetworkReachability? {
        return reachability()
    }
    private var isNetwork: Bool? {
        var flags: SCNetworkReachabilityFlags = []
        guard let reachability = isReachability,
              SCNetworkReachabilityGetFlags(reachability, &flags) else {
            return nil
        }
        return flags.contains(.reachable)
    }
    
    private var activeCall: Bool = false
    
    
    //MARK: - Life Cycle
    override init() {
        super.init()
        
        QBSettings.autoReconnectEnabled = true
        QBSettings.networkIndicatorManagerEnabled = true
        QBChat.instance.addDelegate(self)
    }
    
    deinit {
        QBChat.instance.removeDelegate(self)
    }
    
    // MARK: - Public Methods
    func reachability() -> SCNetworkReachability? {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
       let isReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
       })
        return isReachability
    }
    
    func setupAppActiveStateObserver() {
        if appActiveStateObserver != nil {
            return
        }
        let center = NotificationCenter.default
        appActiveStateObserver = center.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                    object: nil,
                                                    queue: OperationQueue.main,
                                                    using: { [weak self] (note) in
            guard let self = self else { return }
            self.establish()
        })
    }
    
    /// Activating the automatic connection and disconnection process when the application state change.
    ///
    /// Calling this method starts the connection process when it's not established.
    func activateAutomaticMode() {
        setupAppActiveStateObserver()
        establish()
    }
    
    /// Stop trying connection automatically.
    func deactivateAutomaticMode() {
        NotificationCenter.default.removeObserver(appActiveStateObserver as Any)
    }
    
    /// Prevents breaking connection when the application state change.
    func activateCallMode() {
        activeCall = true
    }
    
    /// Break connection when application state is inactive.
    func deactivateCallMode() {
        activeCall = false
    }
    
    /// Establishes a connection with the Quickblox.
     func establish() {
        guard tokenHasExpired == false,
              let sessionToken = QBSession.current.sessionDetails?.token,
              let userId = QBSession.current.sessionDetails?.userID else {
            disconnect()
            delegate?.connectionModuleTokenHasExpired?(self)
            return
        }
        
        if QBChat.instance.isConnected || QBChat.instance.isConnecting {
            delegate?.connectionModuleDidConnect?(self)
            return
        }
        
        delegate?.connectionModuleWillConnect?(self)
        
        QBChat.instance.connect(withUserID: userId, password: sessionToken) { [weak self] (error) in
            guard let self = self else {
                return
            }
            if let error = error, error._code != ErrorCode.alreadyConnectedCode {
                self.delegate?.connectionModuleDidNotConnect?(self, error: error)
                return
            }
            self.delegate?.connectionModuleDidConnect?(self)
        }
    }
    
    /// Disconnects and unauthorize from the Quickblox.
    func breakConnection(withCompletion completion:@escaping CompletionAction) {
        if QBChat.instance.isConnected == false {
            completion()
            return
        }
        
        QBChat.instance.disconnect { (error) in
            completion()
        }
    }
    
    //MARK: - Internal
    private func disconnect() {
        if QBChat.instance.isConnected == false { return }
        QBChat.instance.disconnect(completionBlock: nil)
    }
}

//MARK: - QBChatDelegate
extension ConnectionModule: QBChatDelegate {
    func chatDidNotConnectWithError(_ error: Error) {
        delegate?.connectionModuleDidNotConnect?(self, error: error)
    }
    
    func chatDidDisconnectWithError(_ error: Error?) {
        if let error = error,
           error._code != ErrorCode.socketClosedRemote,
           error._code != ErrorCode.brokenPipe {
            delegate?.connectionModuleDidNotConnect?(self, error: error)
        }
    }
    
    func chatDidAccidentallyDisconnect() {
        delegate?.connectionModuleWillReconnect?(self)
    }
    
    func chatDidReconnect() {
        delegate?.connectionModuleDidReconnect?(self)
    }
}
