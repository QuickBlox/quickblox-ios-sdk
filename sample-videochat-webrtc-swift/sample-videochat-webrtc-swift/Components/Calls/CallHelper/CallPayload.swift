//
//  CallPayload.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 01.04.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class CallPayload: NSObject {
    //MARK: - Properties
    /// Some call data wrong or absent
    var valid: Bool {
        return sessionID.isEmpty == false
    }
    
    var missed: Bool {
        if members.count < 1 {
            return true
        }
        
        guard let startTimeInterval = Double(timestamp) else { return true }
        let timeIntervalNow = (Date().timeIntervalSince1970 * 1000.0).rounded()
        return (timeIntervalNow - startTimeInterval) / 1000 > QBRTCConfig.answerTimeInterval()
    }
    
    var hasVideo: Bool {
        return conferenceType == "1"
    }
    
    private(set) var sessionID: String = ""
    /// The call participants without a current user. The key is a user id and the value is a user name.
    private(set) var members: [NSNumber: String] = [:]
    var title: String {
        if members.values.isEmpty == false {
            return members.values.joined(separator: ", ")
        }
        return contactIdentifier
    }
    private var currentUser = Profile()
    
    private var opponentsIDs: String = ""
    private var contactIdentifier: String = ""
    private var timestamp: String = ""
    private var conferenceType: String = "1"
    
    //MARK: - Life Cycle
    init(payload: [String : String]) {
        super.init()
        
        opponentsIDs = payload["opponentsIDs"] ?? ""
        contactIdentifier = payload["contactIdentifier"] ?? "Incoming call. Connecting..."
        sessionID = payload["sessionID"] ?? ""
        conferenceType = payload["conferenceType"] ?? "1"
        timestamp = payload["timestamp"] ?? ""
        currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        let participantsIDs = opponentsIDs.components(separatedBy: ",")
        let participantsNames = contactIdentifier.components(separatedBy: ",")
        if participantsIDs.count == participantsNames.count {
            let ids = participantsIDs.compactMap({NSNumber(value: Int($0)!)})
            var participants: [NSNumber: String] = [:]
            for i in 0...ids.count - 1 {
                participants[ids[i]] = participantsNames[i]
            }
            participants.removeValue(forKey: NSNumber(value: currentUser.ID))
            if participants.isEmpty == false {
                members = participants
            }
        }
    }
}
