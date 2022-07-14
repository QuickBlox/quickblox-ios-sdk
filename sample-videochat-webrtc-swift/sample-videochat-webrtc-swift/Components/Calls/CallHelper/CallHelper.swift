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

protocol CallHelperDelegate: AnyObject {
    func helper(_ helper: CallHelper, didAcceptCall callId: String)
    func helper(_ helper: CallHelper, didUnregisterCall callId: String)
    func helper(_ helper: CallHelper,
                didRegisterCall callId: String,
                mediaListener: MediaListener,
                mediaController: MediaController,
                direction: CallDirection,
                members: [NSNumber: String],
                hasVideo: Bool)
}

class CallHelper: NSObject {
    //MARK: - Properties
    weak var delegate: CallHelperDelegate?
    var registeredCallId: String? {
        return sessionsController.activeSessionId
    }
    private let sessionsController = SessionsController()
    private let callKit = CallKitManager()
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        callKit.delegate = self
        sessionsController.delegate = self
    }
    
    //MARK: - Public Methods
    func callReceived(_ sessionID: String) -> Bool {
        return sessionsController.session(sessionID, confirmToState: .received)
    }
    
    func registerCall(withPayload payload: [String : String], completion: (() -> Void)? = nil) {
        let call = CallPayload(payload: payload)
        var state: IncommingCallState = .valid
        if call.valid == false {
            state = .invalid
        } else if call.missed || sessionsController.session(call.sessionID, confirmToState: .rejected) {
            state = .missed
        }
        if let callUUID = callKit.callUUID(), callUUID.uuidString != call.sessionID, sessionsController.session(call.sessionID, confirmToState: .new) {
            // when self.callKit.callUUID != nil
            // at that moment has the active call
            debugPrint("\(#function) Received a voip push with another session that has an active call at that moment")
            sessionsController.reject(call.sessionID, userInfo: nil)
            return
        }
        callKit.reportIncomingCall(sessionId: call.sessionID, title: call.title, hasVideo: call.hasVideo, state: state, completion: completion)
        if state != .valid {
            return
        }
        sessionsController.activate(call.sessionID, timestamp: Int64(call.timestamp))
        delegate?.helper(self, didRegisterCall: call.sessionID,
                         mediaListener: generateMediaListener(),
                         mediaController: generateMediaController(),
                         direction: .incoming,
                         members: call.members,
                         hasVideo: call.hasVideo)
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
        sessionsController.start(call.sessionID, userInfo: userInfo)
        
        delegate?.helper(self, didRegisterCall: call.sessionID,
                         mediaListener: generateMediaListener(),
                         mediaController: generateMediaController(),
                         direction: .outgoing,
                         members: call.members,
                         hasVideo: call.hasVideo)
    }
    
    func unregisterCall(_ callId: String, userInfo: [String: String]?) {
        sessionsController.reject(callId, userInfo: userInfo)
    }
    
    func updateCall(_ callId: String, title: String) {
        callKit.reportUpdateCall(sessionId: callId, title: title)
    }
    
    //MARK: - Private Methods
    private func generateMediaController() -> MediaController {
        let mediaController = MediaController()
        mediaController.delegate = sessionsController
        callKit.actionDelegate = mediaController
        return mediaController
    }

    private func generateMediaListener() -> MediaListener {
        let mediaListener = MediaListener()
        sessionsController.mediaListenerDelegate = mediaListener
        return mediaListener
    }
}

//MARK: - CallKitManagerDelegate
extension CallHelper: CallKitManagerDelegate {
    func callKit(_ callKit: CallKitManager, didTapAnswer sessionId: String) {
        sessionsController.accept(sessionId, userInfo: nil)
        delegate?.helper(self, didAcceptCall: sessionId)
    }
    
    func callKit(_ callKit: CallKitManager, didTapRedject sessionId: String) {
        sessionsController.reject(sessionId, userInfo: ["rejectCall": "CallKit"])
    }
    
    func callKit(_ callKit: CallKitManager, didEndCall sessionId: String) {
        // external ending using "reportEndCall" methods
    }
}

//MARK: - CallSessionDelegate
extension CallHelper: CallSessionDelegate {
    func controller(_ controller: SessionsController, didChangeAudioState enabled: Bool, forSession sessionId: String) {
        callKit.muteAudio(!enabled, forCall: sessionId)
    }
    
    func controller(_ controller: SessionsController, didReceiveIncomingSession payload: [String : String]) {
        registerCall(withPayload: payload, completion: nil)
    }
    
    func controller(_ controller: SessionsController, didCloseSession sessionId: String, userInfo: [String : String]?) {
        delegate?.helper(self, didUnregisterCall: sessionId)
        callKit.reportEndCall(sessionId: sessionId)
    }
    
    func controller(_ controller: SessionsController, didEndWaitSession sessionId: String) {
        delegate?.helper(self, didUnregisterCall: sessionId)
        callKit.reportEndCall(sessionId: sessionId, reason: .unanswered)
    }
    
    func controller(_ controller: SessionsController, didAcceptSession sessionId: String) {
        callKit.reportAcceptCall(sessionId: sessionId)
    }
}
