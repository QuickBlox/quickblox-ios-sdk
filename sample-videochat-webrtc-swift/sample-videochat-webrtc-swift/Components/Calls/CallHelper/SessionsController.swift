//
//  SessionsController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 31.03.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC
import Quickblox

protocol CallSessionDelegate: AnyObject {
    func controller(_ controller: SessionsController, didEndWaitCallSession sessionId: String)
    func controller(_ controller: SessionsController, didAcceptCallSession sessionId: String)
    func controller(_ controller: SessionsController,
                    didReceiveIncomingCallSession sessionId: String,
                    membersIDs: [NSNumber],
                    conferenceType: QBRTCConferenceType)
    func controller(_ controller: SessionsController, didCloseCallSession sessionId: String, userInfo: [String: String]?)
}


class SessionsController: NSObject {
    
    //MARK: - Properties
    weak var delegate: CallSessionDelegate?
    
    private(set) var activeSessionId = ""
    private(set) var media = MediaRouter()
    
    private var receivedSessions: [String: QBRTCSession] = [:]
    private var activeSession: QBRTCSession?
    private var waitSessions: [String: SessionTimer] = [:]
    private var approvedSessions: [String] = []
    var rejectedSessions: Set<String> = []
    private var soundTimer: Timer? = nil
    
    //MARK: - Life Cycle
    override init() {
        super.init()
        
        QBRTCClient.instance().add(self)
        media.delegate = self
    }
    
    //MARK: Actions
    func activateNewSession(withMembers members: [NSNumber: String], hasVideo: Bool) -> [String: String] {
        let type: QBRTCConferenceType = hasVideo ? .video : .audio;
        let opponentsIDs: [NSNumber] = Array(members.keys)
        let opponentsNamesArray: [String] = Array(members.values)
        let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: type)
    
        guard session.id.isEmpty == false,
              let currentUser = QBSession.current.currentUser else {
            return [:]
        }

        self.receivedSessions[session.id] = session
        activate(session.id)
        
        let initiatorName = currentUser.fullName ?? "\(currentUser.id)"
        let membersNames = opponentsNamesArray.joined(separator: ",")
        let participantsNames = initiatorName + "," + membersNames
        let arrayUserIDs = opponentsIDs.map({ $0.stringValue })
        let membersIds = arrayUserIDs.joined(separator: ",")
        let participantsIds = NSNumber(value: currentUser.id).stringValue + "," + membersIds
        let timeStamp = Int((Date().timeIntervalSince1970 * 1000.0).rounded())
        let payload = ["message": "\(initiatorName) is calling you.",
                       "ios_voip": "1",
                       "VOIPCall": "1",
                       "sessionID": session.id,
                       "opponentsIDs": participantsIds,
                       "contactIdentifier": participantsNames,
                       "conferenceType" : NSNumber(value: type.rawValue).stringValue,
                       "timestamp" : "\(timeStamp)"
        ]
        
        return payload
    }
    
    func isValid(_ sessionID: String) -> Bool {
        if receivedSessions[sessionID] != nil {
            return false
        }
        return true
    }
    
    func activate(_ sessionId: String) {
        debugPrint("\(#function)")
        if sessionId.isEmpty { return }
        if activeSessionId.isEmpty == false { return }
        
        activeSessionId = sessionId
        if let session = receivedSessions[sessionId] {
            activeSession = session
            return
        }
        addTimer(.active, waitTime: 10.0, sessionId: sessionId, userInfo: nil)
    }
    
    func deactivate(_ sessionId: String) {
        if sessionId.isEmpty { return }
        if activeSessionId != sessionId { return }

        stopPlayCallingSound()
        activeSession = nil
        activeSessionId = ""
        media.reload()
    }
    
    func startCall(_ sessionId: String, userInfo: [String: String]?) {
       guard sessionId.isEmpty == false,
             activeSessionId == sessionId,
             let session = activeSession else { return }
        session.startCall(userInfo)
        setupCamera(session)
        approvedSessions.append(sessionId)
        removeTimer(withId: sessionId)
    }
    
    func acceptCall(_ sessionId: String, userInfo: [String: String]?) {
        if sessionId.isEmpty { return }
        if let session = receivedSessions[sessionId] {
            setupCamera(session)
            session.acceptCall(userInfo)
            approvedSessions.append(sessionId)
            
            if let timer = waitSessions[session.id], timer.type == .actions {
                //did Accept New Session Without Push
                removeTimer(withId: session.id)
                timer.invalidate()
                waitSessions.removeValue(forKey: session.id)
            }
            delegate?.controller(self, didAcceptCallSession: sessionId)
        } else {
            addTimer(.accept, waitTime: QBRTCConfig.answerTimeInterval(), sessionId: sessionId, userInfo: userInfo)
        }
    }
    
    func rejectCall(_ sessionId: String, userInfo: [String: String]?) {
        if sessionId.isEmpty { return }
        rejectedSessions.insert(sessionId)
        if let session = receivedSessions[sessionId] {
            approvedSessions.contains(sessionId) ? session.hangUp(userInfo) : session.rejectCall(userInfo)
        } else {
            removeSession(sessionId, userInfo: nil)
        }
    }
    
    @objc private func removeSession(_ sessionId: String, userInfo: [String: String]? = nil) {
        if receivedSessions[sessionId] != nil {
            receivedSessions.removeValue(forKey: sessionId)
        }
        removeTimer(withId: sessionId)
        if let index = approvedSessions.firstIndex(where: { $0 == sessionId }) {
            approvedSessions.remove(at: index)
        }
        if activeSessionId == sessionId {
            delegate?.controller(self, didCloseCallSession: sessionId, userInfo: userInfo)
            deactivate(sessionId)
        }
    }
    
    private func turnAudioBroadcast(enable: Bool, fromUser userID: NSNumber) {
        guard let session = activeSession else {
            return
        }
        let audioTrack = session.remoteAudioTrack(withUserID: userID)
        audioTrack.isEnabled = enable
    }
    
    private func setupCamera(_ session: QBRTCSession) {
        guard session == activeSession,
              session.conferenceType == .video,
              media.videoEnabled == true else {
            return
        }
        if let sharing = media.sharing {
            session.localMediaStream.videoTrack.videoCapture = sharing
            return
        }
        session.localMediaStream.videoTrack.videoCapture = media.camera
    }
    
    private func removeTimer(withId sessionId: String) {
        guard let timer = waitSessions[sessionId] else { return }
        timer.invalidate()
        waitSessions.removeValue(forKey: sessionId)
    }
    
    private func addTimer( _ type: SessionTimerType,
                           waitTime: TimeInterval,
                           sessionId: String,
                           userInfo: [String: String]? = nil) {
        removeTimer(withId: sessionId)
        let timer = SessionTimer.waitSession(sessionId: sessionId, type: type, waitingTime: waitTime)
        timer.delegate = self
        timer.userInfo = userInfo
        waitSessions[sessionId] = timer
    }
    
    func startPlayCallingSound() {
        soundTimer = Timer.scheduledTimer(timeInterval: 5.0,
                                          target: self,
                                          selector: #selector(playCallingSound(_:)),
                                          userInfo: nil,
                                          repeats: true)
        playCallingSound(nil)
    }
    
    @objc func playCallingSound(_ sender: Any?) {
        SoundProvider.playSound(type: .calling)
    }
    
    private func stopPlayCallingSound() {
        guard let soundTimer = soundTimer else {
            return
        }
        soundTimer.invalidate()
        self.soundTimer = nil
        SoundProvider.stopSound()
    }
}

//MARK: - QBRTCClientDelegate
extension SessionsController: QBRTCClientDelegate {
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if activeSession != nil {
            session.rejectCall(["reject": "busy"])
            rejectedSessions.insert(session.id)
            return
        }
        if rejectedSessions.contains(session.id) {
            session.rejectCall(userInfo)
            return
        }
        
        receivedSessions[session.id] = session

        if let timer = waitSessions[session.id] {
            timer.invalidate()
            waitSessions.removeValue(forKey: session.id)

            //did Receive New Session by Push
            switch timer.type {
            case .active:
                activeSession = session
                addTimer(.actions, waitTime: QBRTCConfig.answerTimeInterval(), sessionId: session.id, userInfo: nil)
            case .accept:
                activeSession = session
                setupCamera(session)
                session.acceptCall(timer.userInfo)
                approvedSessions.append(timer.sessionId)
                delegate?.controller(self, didAcceptCallSession: session.id)
            case .actions: break
            case .none: break
            }
            
            return
        }
        
        //did Receive New Session without Push
        let membersIDs = [session.initiatorID] + session.opponentsIDs
        delegate?.controller(self,
                             didReceiveIncomingCallSession: session.id,
                             membersIDs: membersIDs,
                             conferenceType: session.conferenceType)
        addTimer(.actions, waitTime: QBRTCConfig.answerTimeInterval(), sessionId: session.id, userInfo: nil)
    }
    
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        setupCamera(session)
        stopPlayCallingSound()
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if userID == session.initiatorID,
           let timer = waitSessions[session.id],
           timer.type == .actions {
            removeSession(session.id, userInfo: nil)
            return
        }
        if session.opponentsIDs.count == 1 {
            removeSession(session.id, userInfo: nil)
        }
    }
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if session.opponentsIDs.count == 1 {
            removeSession(session.id, userInfo: nil)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        removeSession(session.id, userInfo: nil)
    }
    
    /**
     *  Called in case when receive remote video track from opponent
     */
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        
        if session != activeSession {
            return
        }
        
        media.receivedRemoteVideoTrack(videoTrack, fromUser: userID)
    }
}

//MARK: - MediaDelegate
extension SessionsController: MediaDelegate {
    func router(_ router: MediaRouter, audioBroadcast enable: Bool, fromUser userID: NSNumber) {
        turnAudioBroadcast(enable: enable, fromUser: userID)
    }
    
    func router(_ router: MediaRouter, audioBroadcast enable: Bool) {
        guard let activeSession = activeSession else {
            return
        }
        activeSession.localMediaStream.audioTrack.isEnabled = enable
    }
    
    func router(_ router: MediaRouter, videoBroadcast enable: Bool, capture: QBRTCVideoCapture?) {
        guard let activeSession = activeSession else {
            return
        }
        
        if let capture = capture, activeSession.localMediaStream.videoTrack.videoCapture != capture {
            activeSession.localMediaStream.videoTrack.videoCapture = capture
        }
        
        if (activeSession.localMediaStream.videoTrack.isEnabled != enable) {
            activeSession.localMediaStream.videoTrack.isEnabled = enable
        }
    }
    
    func router(_ router: MediaRouter, videoTrackForUser userID: NSNumber) -> QBRTCVideoTrack? {
        guard let activeSession = activeSession else {
            return nil
        }
        return activeSession.remoteVideoTrack(withUserID: userID)
    }
}

//MARK: - SessionTimerDelegate
extension SessionsController: SessionTimerDelegate {
    func timerDidEndWaiting(_ timer: SessionTimer) {
        guard let sessionId = timer.sessionId else {
            return
        }
        if activeSessionId == sessionId, self.delegate != nil {
            deactivate(sessionId)
            delegate?.controller(self, didEndWaitCallSession: sessionId)
            return
        }
        timer.invalidate()
        waitSessions.removeValue(forKey: sessionId)
    }
}
