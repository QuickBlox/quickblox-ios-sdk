//
//  CallInfo.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 24.06.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class CallParticipant {
    //MARK: - Properties
    var userID: UInt
    var fullName = ""
    var isSelected = false
    var connectionState: QBRTCConnectionState = .new
    var isEnabledSound = true
    
    //MARK: - Life Cycle
    init(userID: UInt, fullName: String) {
        self.userID = userID
        self.fullName = fullName
    }
}

typealias ChangedStateHandler = ( _ participant: CallParticipant) -> Void
typealias ChangedBitrateHandler = ( _ participant: (iD: UInt, statsString: String)) -> Void

class CallInfo: NSObject {
    //MARK: - Properties
    var onChangedState: ChangedStateHandler?
    var onChangedBitrate: ChangedBitrateHandler?
    
    private(set) var direction: CallDirection!
    private(set) var callId: String!
    /// The current call participant.
    var localParticipant: CallParticipant? {
        return participant(localParticipantId)
    }
    /// Everyone in the call
    private(set) var participants: [CallParticipant] = []
    /// Someone who participates in a conversation and represents someone else
    private(set) var interlocutors: [CallParticipant] = []
    /// Sorted participants ids.
    private var list: [UInt] = []
    /// The call participants details where the key is a user id.
    private var cache: [UInt : CallParticipant] = [:]
    /// The current user id.
    var localParticipantId: UInt {
        return profile.ID
    }
    private var profile = Profile()

    //MARK: - Life Cycle
    /// The key is a user id and the value is a user name.
    init(callId: String,members: [NSNumber: String], direction: CallDirection) {
        super.init()
        
        self.callId = callId
        self.direction = direction
        var participantsList: [UInt] = []
        var participantsDictionary: [UInt: CallParticipant] = [:]
        var interlocutors: [CallParticipant] = []
        
        for memberId in members.keys {
            let participant = CallParticipant(userID: memberId.uintValue, fullName: members[memberId] ?? "Participant")
            participantsDictionary[memberId.uintValue] = participant
            interlocutors.append(participant)
            participantsList.append(memberId.uintValue)
        }
        
        let localParticipantId = profile.ID
        let local = CallParticipant(userID: profile.ID, fullName: profile.fullName)
        participantsDictionary[localParticipantId] = local
        participantsList.append(localParticipantId)

        self.interlocutors = interlocutors
        interlocutors.append(local)
        self.participants = interlocutors
        cache = participantsDictionary
        list = participantsList
        
        QBRTCClient.instance().add(self)
    }
    
    //MARK: - Public Methods
    func updateWithMembers(_ members: [NSNumber: String]) {
        for userId in members.keys {
            guard let participant = cache[userId.uintValue],
                  let fullName = members[userId] else {continue}
            participant.fullName = fullName
        }
    }
    
    func participant(_ userID: UInt) -> CallParticipant? {
        guard let participant = cache[userID] else {return nil}
        return participant
    }
    
    func currentOutput() -> AVAudioSession.PortOverride {
        let audioSession = QBRTCAudioSession.instance()
        if audioSession.isActive {
            let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
            for output in outputs {
                switch output.portType {
                case .builtInSpeaker: return .speaker
                default: return .none
                }
            }
        }
        return .none
    }
}

//MARK: - QBRTCClientDelegate
extension CallInfo: QBRTCClientDelegate {
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        if isCurrentSession(session) == false, userID.uintValue != localParticipantId  {
            return
        }
        guard let participant = cache[userID.uintValue] else { return }
        participant.connectionState = state
        onChangedState?(participant)
    }
    
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        guard cache[userID.uintValue] != nil else { return }
        onChangedBitrate?((userID.uintValue, report.statsString()))
    }
    
    func isCurrentSession(_ session: QBRTCBaseSession) -> Bool {
        guard let qbSession = session as? QBRTCSession,
              qbSession.id == callId else { return false }
        return true
    }
}
