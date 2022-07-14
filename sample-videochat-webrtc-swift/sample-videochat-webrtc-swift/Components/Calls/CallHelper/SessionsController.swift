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

enum SessionState {
    case new, wait, received, approved, rejected
}

protocol CallSessionDelegate: AnyObject {
    func controller(_ controller: SessionsController, didEndWaitSession sessionId: String)
    func controller(_ controller: SessionsController, didAcceptSession sessionId: String)
    func controller(_ controller: SessionsController,
                    didReceiveIncomingSession payload: [String : String])
    func controller(_ controller: SessionsController, didCloseSession sessionId: String, userInfo: [String: String]?)
    func controller(_ controller: SessionsController, didChangeAudioState enabled: Bool, forSession sessionId: String)
}

protocol SessionsMediaListenerDelegate: AnyObject {
    func controller(_ controller: SessionsController, didBroadcastMediaType mediaType: MediaType, enabled: Bool)
    func controller(_ controller: SessionsController, didReceivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber)
}


class SessionsController: NSObject {

    //MARK: - Properties
    weak var delegate: CallSessionDelegate?
    weak var mediaListenerDelegate: SessionsMediaListenerDelegate?
    
    private var activeSession: Session?
    var activeSessionId: String {
        return activeSession?.id ?? ""
    }
    private var receivedSessions: [String] = []
    private var waitSessions: [String: SessionTimer] = [:]
    private var approvedSessions: [String] = []
    private var rejectedSessions: Set<String> = []
    
    let audioURL = URL(fileURLWithPath: Bundle.main.path(forResource: "calling", ofType: "wav")!)
    private var soundTimer: Timer? = nil
    private var player: AVAudioPlayer?
    
    //MARK: - Life Cycle
    override init() {
        super.init()
        
        QBRTCClient.instance().add(self)
    }
    
    //MARK: Actions
    func session(_ sessionId :String, confirmToState state: SessionState) -> Bool {
        switch state {
        case .wait:
            return waitSessions[sessionId] != nil
        case .received:
            return receivedSessions.contains(sessionId)
        case .approved:
            return approvedSessions.contains(sessionId)
        case .rejected:
            return rejectedSessions.contains(sessionId)
        case .new:
            if waitSessions[sessionId] == nil,
               receivedSessions.contains(sessionId) == false,
               approvedSessions.contains(sessionId) == false,
               rejectedSessions.contains(sessionId) == false {
                return true
            }
            return false
        }
    }
    
    func activateNewSession(withMembers members: [NSNumber: String], hasVideo: Bool) -> [String: String] {
        let type: QBRTCConferenceType = hasVideo ? .video : .audio;
        let opponentsIDs: [NSNumber] = Array(members.keys)
        let opponentsNamesArray: [String] = Array(members.values)
        let session = QBRTCClient.instance().createNewSession(withOpponents: opponentsIDs, with: type)
    
        guard session.id.isEmpty == false,
              let currentUser = QBSession.current.currentUser else {
            return [:]
        }

        receivedSessions.append(session.id)
        let timeStamp = Date().timeStamp
        activeSession = Session(qbSession: session, startTime: timeStamp)
        activate(session.id, timestamp: nil)
        
        let initiatorName = currentUser.fullName ?? "\(currentUser.id)"
        let membersNames = opponentsNamesArray.joined(separator: ",")
        let participantsNames = initiatorName + "," + membersNames
        let arrayUserIDs = opponentsIDs.map({ $0.stringValue })
        let membersIds = arrayUserIDs.joined(separator: ",")
        let participantsIds = NSNumber(value: currentUser.id).stringValue + "," + membersIds
        
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
    
    func activate(_ sessionId: String, timestamp: Int64?) {
        if sessionId.isEmpty {
            return
        }
        let startTime = timestamp ?? Date().timeStamp
        if activeSession?.established == true {
            addTimer(.actions, waitTime: activeSession?.waitTimeInterval ?? 30.0, sessionId: sessionId, userInfo: nil)
            return
        }
        activeSession = Session(id: sessionId, startTime: startTime)
        addTimer(.active, waitTime: activeSession?.waitTimeInterval ?? 30.0, sessionId: sessionId, userInfo: nil)
    }
    
    func deactivate(_ sessionId: String) {
        if sessionId.isEmpty {
            return
        }
        if activeSessionId != sessionId {
            return
        }
        rejectedSessions.insert(sessionId)
        stopPlayCallingSound()
        activeSession = nil
    }
    
    func start(_ sessionId: String, userInfo: [String: String]?) {
       guard sessionId.isEmpty == false,
             activeSessionId == sessionId,
             let session = activeSession else {
            return
        }
        
        session.start(userInfo)
        approvedSessions.append(sessionId)
        removeTimer(withId: sessionId)
        startPlayCallingSound()
    }
    
    func accept(_ sessionId: String, userInfo: [String: String]?) {
        if sessionId.isEmpty {
            return
        }
        if activeSession?.established == true, let session = activeSession, sessionId == session.id {
            session.accept(userInfo)
            approvedSessions.append(sessionId)
            delegate?.controller(self, didAcceptSession: sessionId)
            removeTimer(withId: session.id)
        } else {
            addTimer(.accept, waitTime: activeSession?.waitTimeInterval ?? 30.0, sessionId: sessionId, userInfo: userInfo)
        }
    }
    
    func reject(_ sessionId: String, userInfo: [String: String]?) {
        if sessionId.isEmpty {
            return
        }
        rejectedSessions.insert(sessionId)
        if activeSession?.established == true {
            approvedSessions.contains(sessionId) ? activeSession?.hangUp(userInfo) : activeSession?.reject(userInfo)
        } else {
            removeSession(sessionId)
        }
    }
    
    private func removeSession(_ sessionId: String) {
        removeTimer(withId: sessionId)
        if let index = approvedSessions.firstIndex(where: { $0 == sessionId }) {
            approvedSessions.remove(at: index)
        }
        if activeSessionId == sessionId {
            delegate?.controller(self, didCloseSession: sessionId, userInfo: nil)
            deactivate(sessionId)
        }
    }
    
    private func removeTimer(withId sessionId: String) {
        guard let timer = waitSessions[sessionId] else {
            return
        }
        timer.invalidate()
        waitSessions[sessionId] = nil
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
    
    private func startPlayCallingSound() {
        soundTimer = Timer.scheduledTimer(timeInterval: 3.0,
                                          target: self,
                                          selector: #selector(playCallingSound(_:)),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    @objc private func playCallingSound(_ sender: Any?) {
        do {
            player?.stop()
            player = try AVAudioPlayer(contentsOf: audioURL)
            player?.play()
        } catch {
            debugPrint("Couldn't load file")
        }
    }
    
    private func stopPlayCallingSound() {
        guard let soundTimer = soundTimer else {
            return
        }
        soundTimer.invalidate()
        self.soundTimer = nil
        player?.stop()
    }
}

//MARK: - QBRTCClientDelegate
extension SessionsController: QBRTCClientDelegate {
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        if activeSession?.established == true {
            session.rejectCall(["reject": "busy"])
            rejectedSessions.insert(session.id)
            return
        }
        if rejectedSessions.contains(session.id) {
            session.rejectCall(userInfo)
            return
        }
        
        receivedSessions.append(session.id)

        if let timer = waitSessions[session.id] {
            //did Receive New Session by Push
            switch timer.type {
            case .active:
                activeSession?.setup(qbSession: session)
            case .accept:
                activeSession?.setup(qbSession: session)
                accept(session.id, userInfo: timer.userInfo)
            case .actions: break
            case .none: break
            }
            return
        }
        
        let timestamp = userInfo?["timestamp"] ?? "\((Date().timeStamp))"
        activeSession = Session(qbSession: session, startTime: Int64(timestamp)!)
        
        //did Receive New Session without Push
        let membersIDs = [session.initiatorID] + session.opponentsIDs
        let arrayUserIDs = membersIDs.map({ $0.stringValue })
        let participantsIds = arrayUserIDs.joined(separator: ",")
        
        let payload = ["opponentsIDs": participantsIds,
                       "sessionID": session.id,
                       "conferenceType": NSNumber(value: session.conferenceType.rawValue).stringValue,
                       "timestamp": timestamp
        ]
        delegate?.controller(self, didReceiveIncomingSession: payload)
    }
    
    func session(_ session: QBRTCSession, acceptedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        stopPlayCallingSound()
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if userID == session.initiatorID,
           approvedSessions.contains(session.id) == false {
            removeSession(session.id)
            return
        }
        if session.opponentsIDs.count == 1 {
            removeSession(session.id)
        }
    }
    
    func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        if session.opponentsIDs.count == 1 {
            removeSession(session.id)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        removeSession(session.id)
    }
    
    /**
     *  Called in case when receive remote video track from opponent
     */
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        guard let qbrtcSession = session as? QBRTCSession,
              qbrtcSession.id == activeSession?.id else {
            return
        }
        
        mediaListenerDelegate?.controller(self, didReceivedRemoteVideoTrack: videoTrack, fromUser: userID)
    }
}

//MARK: - MediaDelegate
extension SessionsController: MediaControllerDelegate {
    func mediaController(_ mediaController: MediaController, videoTrackForUserID userID: UInt) -> QBRTCVideoTrack? {
        guard let activeSession = activeSession, activeSession.established == true else {
            return nil
        }
        return activeSession.remoteVideoTrack(withUserID: NSNumber(value: userID))
    }
    
    func mediaController(_ mediaController: MediaController, videoBroadcast enable: Bool, capture: QBRTCVideoCapture?) {
        if let capture = capture {
            activeSession?.videoCapture = capture
        } 
        if activeSession?.videoEnabled == enable {
            return
        }
        activeSession?.videoEnabled = enable
        mediaListenerDelegate?.controller(self, didBroadcastMediaType: .video, enabled: enable)
    }
    
    func mediaController(_ mediaController: MediaController, audioBroadcast enable: Bool, action: ChangeAudioStateAction) {
        if activeSession?.audioEnabled == enable {
            return
        }
        activeSession?.audioEnabled = enable
        mediaListenerDelegate?.controller(self, didBroadcastMediaType: .audio, enabled: enable)
        //Change audio state on CallKit Native Screen
        if action == .callKit {
            return
        }
        delegate?.controller(self, didChangeAudioState: enable, forSession: activeSessionId)
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
            delegate?.controller(self, didEndWaitSession: sessionId)
            return
        }
        timer.invalidate()
        waitSessions.removeValue(forKey: sessionId)
    }
}
