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
    
    var missed = false
    
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
    var timestamp: String = ""
    private var conferenceType: String = "1"
    
    //MARK: - Life Cycle
    init(payload: [String : String]) {
        super.init()
        
        opponentsIDs = payload["opponentsIDs"] ?? ""
        var participantsNames: [String] = []
        if let contactIdentifier = payload["contactIdentifier"] {
            self.contactIdentifier = contactIdentifier
            participantsNames = contactIdentifier.components(separatedBy: ",")
        } else {
            contactIdentifier = "Incoming call. Connecting..."
            participantsNames = opponentsIDs.components(separatedBy: ",")
        }
        sessionID = payload["sessionID"] ?? ""
        conferenceType = payload["conferenceType"] ?? "1"
        timestamp = payload["timestamp"] ?? ""
        currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        let participantsIDs = opponentsIDs.components(separatedBy: ",")
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
        
        if members.count < 1 {
            missed = true
            return
        }
        let startTimeInterval = Int64(timestamp) ?? Date().timeStamp
        let timeIntervalNow = Date().timeStamp
        let receivedTimeInterval = (timeIntervalNow - startTimeInterval) / 1000
        missed = receivedTimeInterval > Int64(QBRTCConfig.answerTimeInterval())
    }
}
