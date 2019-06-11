//
//  Reachability.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Quickblox
import SVProgressHUD
import SystemConfiguration

enum NetworkConnectionStatus: UInt {
    case notConnection
    case viaWiFi
    case viaWWAN
}

typealias NetworkStatusBlock = ((_ status: NetworkConnectionStatus) -> Void)?

class Reachability: NSObject {
    // MARK: shared Instance
    static let instance: Reachability = {
        let instance = Reachability()
        instance.commonInit()
        return instance
    }()
    
    //MARK: - Properties
    var networkStatusBlock: NetworkStatusBlock?
    private var currentReachabilityFlags: SCNetworkReachabilityFlags?
    private let reachabilitySerialQueue = DispatchQueue.main
    var reachabilityRef: SCNetworkReachability?
    
    // MARK: - Common Init
    private func commonInit() {
        QBSettings.autoReconnectEnabled = true
        self.startReachabliyty()
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
        
        self.reachabilityRef = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        })
        
        guard let defaultRouteReachability = self.reachabilityRef else {
            return
        }
        
        var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
        
        let callbackClosure: SCNetworkReachabilityCallBack? = {
            (reachability:SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) in
            guard let info = info else {
                return
            }
            let handler = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
            
            DispatchQueue.main.async {
                handler.checkReachability(flags: flags)
            }
        }
        
        if SCNetworkReachabilitySetCallback(defaultRouteReachability, callbackClosure, &context) {
            if (SCNetworkReachabilitySetDispatchQueue(defaultRouteReachability, self.reachabilitySerialQueue)) {
            }
            else {
                SCNetworkReachabilitySetCallback(defaultRouteReachability, nil, nil);
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
