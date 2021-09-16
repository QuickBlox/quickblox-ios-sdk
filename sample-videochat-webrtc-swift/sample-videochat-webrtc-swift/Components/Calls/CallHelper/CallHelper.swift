//
//  CallHelper.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 01.04.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

enum CallDirection {
    case incoming
    case outgoing
}

typealias CallMuteAction = ((Bool) -> Void)

protocol CallHelperDelegate: AnyObject {
    func helper(_ helper: CallHelper, didAcceptCall callId: String)
    func helper(_ helper: CallHelper, didUnregisterCall callId: String, userInfo: [String : String]?)
    func helper(_ helper: CallHelper, didRegisterCall callId: String, direction: CallDirection, members: [NSNumber: String], hasVideo: Bool)
    func helper(_ helper: CallHelper, didReciveIncomingCallWithMembers callMembers: [NSNumber], completion:@escaping (String) -> Void)
}

class CallHelper: NSObject {
    //MARK: - Properties
    weak var delegate: CallHelperDelegate?
    var registeredCallId: String? {
        return sessionsController.activeSessionId
    }
    var onMute: CallMuteAction?
    var media: MediaRouter? {
        return sessionsController.media
    }
    
    private let callKit = CallKit()
    private lazy var sessionsController: SessionsController = {
        let sessionsController = SessionsController()
        return sessionsController
    }()
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        callKit.delegate = self
        sessionsController.delegate = self
    }
    
    //MARK: - Public Methods
    func isValid(_ sessionID: String) -> Bool {
        return sessionsController.isValid(sessionID)
    }
    
    func registerCall(withPayload payload: [String : String], completion: (() -> Void)? = nil) {
        let call = CallPayload(payload: payload)
        
        var state: IncommingCallState = .valid
        if call.valid == false {
            state = .invalid
        } else if call.missed || sessionsController.rejectedSessions.contains(call.sessionID) == true {
            state = .missed
        }
        if let callUUID = callKit.callUUID(), callUUID.uuidString != call.sessionID  {
            // when self.callKit.callUUID != nil
            // at that moment has the active call
            debugPrint("\(#function) Received a voip push with another session that has an active call at that moment")
            sessionsController.rejectedSessions.insert(call.sessionID)
            return
        }
        
        callKit.reportIncomingCall(sessionId: call.sessionID, title: call.title, hasVideo: call.hasVideo, state: state, completion: completion)
        if state != .valid {
            return
        }
        sessionsController.activate(call.sessionID)
        delegate?.helper(self, didRegisterCall: call.sessionID, direction: .incoming, members: call.members, hasVideo: call.hasVideo)
    }
    
    
    func registerCall(withMembers members: [NSNumber: String], hasVideo:Bool, userInfo: [String: String]?) {
        // Prepare call
        let payload = sessionsController.activateNewSession(withMembers: members, hasVideo: hasVideo)
        
        if payload.isEmpty {
            debugPrint("\(#function) You should login to use VideoChat API. Session hasn’t been created. Please try to relogin.")
            return
        }
        
        let call = CallPayload(payload: payload)
        
        //Showing CallKit screen
        callKit.reportOutgoingCall(sessionId: call.sessionID, title: call.title, hasVideo: call.hasVideo, completion: nil)
        
        //Sending VOIP call event
        let data = try? JSONSerialization.data(withJSONObject: payload,
                                               options: .prettyPrinted)
        var message = ""
        if let data = data {
            message = String(data: data, encoding: .utf8) ?? ""
        }
        
        let arrayUserIDs = members.keys.map({"\($0)"})
        let usersIDsString = arrayUserIDs.joined(separator: ",")
        
        let event = QBMEvent()
        event.notificationType = QBMNotificationType.push
        event.usersIDs = usersIDsString
        event.type = .oneShot
        event.message = message
        QBRequest.createEvent(event, successBlock: { response, events in
            debugPrint("\(#function) Send voip push - Success")
        }, errorBlock: { response in
            debugPrint("\(#function) Send voip push Error: \(response.error?.error?.localizedDescription ?? "")")
        })
        
        // Start call
        sessionsController.startCall(call.sessionID, userInfo: userInfo)
        delegate?.helper(self, didRegisterCall: call.sessionID, direction: .outgoing, members: call.members, hasVideo: call.hasVideo)
    }
    
    func unregisterCall(_ callId: String, userInfo: [String: String]?) {
        sessionsController.rejectCall(callId, userInfo: userInfo)
    }
    
    func updateCall(_ callId: String, title: String) {
        callKit.reportUpdateCall(sessionId: callId, title: title)
    }
}

//MARK: - CallKitDelegate
extension CallHelper: CallKitDelegate {
    func callKit(_ callKit: CallKit, didActivate audioSession: QBRTCAudioSession, reason: CallKitActiveteAudioReason) {
        if reason == .startCall {
            sessionsController.startPlayCallingSound()
        }
    }
    
    func callKit(_ callKit: CallKit, didTapAnswer sessionId: String) {
        sessionsController.acceptCall(sessionId, userInfo: nil)
        delegate?.helper(self, didAcceptCall: sessionId)
    }
    
    func callKit(_ callKit: CallKit, didTapRedject sessionId: String) {
        sessionsController.rejectCall(sessionId, userInfo: ["rejectCall": "CallKit"])
    }
    
    func callKit(_ callKit: CallKit, didTapMute enable: Bool) {
        onMute?(enable)
    }
    
    func callKit(_ callKit: CallKit, didEndCall sessionId: String) {
        // external ending using "reportEndCall" methods
    }
}

//MARK: - CallSessionDelegate
extension CallHelper: CallSessionDelegate {
    func controller(_ controller: SessionsController, didReceiveIncomingCallSession sessionId: String, membersIDs: [NSNumber], conferenceType: QBRTCConferenceType) {
        let arrayUserIDs = membersIDs.map({ $0.stringValue })
        let opponentsIDs = arrayUserIDs.joined(separator: ",")
        let timeStamp = Int((Date().timeIntervalSince1970 * 1000.0).rounded())
        delegate?.helper(self, didReciveIncomingCallWithMembers: membersIDs, completion: { [weak self] (contactIdentifier) in
            let payload = ["opponentsIDs": opponentsIDs,
                                     "contactIdentifier": contactIdentifier,
                                     "sessionID": sessionId,
                                     "conferenceType": NSNumber(value: conferenceType.rawValue).stringValue,
                                     "timestamp": "\(timeStamp)"
            ]
            self?.registerCall(withPayload: payload, completion: nil)
        })
    }
    
    func controller(_ controller: SessionsController, didCloseCallSession sessionId: String, userInfo: [String : String]?) {
        delegate?.helper(self, didUnregisterCall: sessionId, userInfo: userInfo)
        callKit.reportEndCall(sessionId: sessionId)
    }
    
    func controller(_ controller: SessionsController, didEndWaitCallSession sessionId: String) {
        delegate?.helper(self, didUnregisterCall: sessionId, userInfo: nil)
        callKit.reportEndCall(sessionId: sessionId, reason: .unanswered)
    }
    
    func controller(_ controller: SessionsController, didAcceptCallSession sessionId: String) {
        callKit.reportAcceptCall(sessionId: sessionId)
    }
}
