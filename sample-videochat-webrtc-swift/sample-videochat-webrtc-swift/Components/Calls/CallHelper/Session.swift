//
//  Session.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 16.06.2022.
//  Copyright © 2022 QuickBlox. All rights reserved.
//

import Foundation
import QuickbloxWebRTC

class Session {
    //MARK - Properties
    private(set) var id = ""
    private var qbSession: QBRTCSession? = nil
    private var _audioEnabled = true
    private var _videoEnabled = false
    private weak var _videoCapture: QBRTCVideoCapture?
    private var stopWaitTime: Int64 = 0
    var waitTimeInterval: TimeInterval {
        let timeNow = Date().timeStamp
        return Double((stopWaitTime - timeNow) / 1000)
    }
    
    var videoEnabled: Bool {
        get {
            return _videoEnabled
        }
        set {
            if _videoEnabled != newValue {
                _videoEnabled = newValue
                qbSession?.localMediaStream.videoTrack.isEnabled = newValue
            }
        }
    }
    var audioEnabled: Bool {
        get {
            return _audioEnabled
        }
        set {
            if self._audioEnabled != newValue {
                _audioEnabled = newValue
                qbSession?.localMediaStream.audioTrack.isEnabled = newValue
            }
        }
    }
    
    weak var videoCapture: QBRTCVideoCapture? {
        get {
            return _videoCapture ?? nil
        }
        set {
            if _videoCapture != newValue {
                _videoCapture = newValue
                qbSession?.localMediaStream.videoTrack.videoCapture = newValue
            }
        }
    }
    
    var established: Bool {
        return qbSession != nil
    }
    
    //MARK: - Life Cycle
    init(id: String, startTime: Int64) {
        self.id = id
        self.stopWaitTime = startTime + Int64((QBRTCConfig.answerTimeInterval() - 1) * 1000)
    }
    
    init(qbSession: QBRTCSession, startTime: Int64) {
        self.qbSession = qbSession
        self.id = qbSession.id
        self.stopWaitTime = startTime + Int64((QBRTCConfig.answerTimeInterval() - 1) * 1000)
    }
    
    //MARK: - Public Methods
    func setup(qbSession: QBRTCSession) {
        if id != qbSession.id {
            return
        }
        if id == qbSession.id, established == true {
            return
        }
        self.qbSession = qbSession
        self.qbSession?.localMediaStream.audioTrack.isEnabled = self._audioEnabled
        self.qbSession?.localMediaStream.videoTrack.videoCapture = self._videoCapture
        self.qbSession?.localMediaStream.videoTrack.isEnabled = self._videoEnabled
    }

    func start(_ userInfo: [String : String]? = nil) {
        qbSession?.startCall(userInfo)
    }
    
    func accept(_ userInfo: [String : String]? = nil) {
        qbSession?.acceptCall(userInfo)
    }
    
    func reject(_ userInfo: [String : String]? = nil) {
        qbSession?.rejectCall(userInfo)
    }
    
    func hangUp(_ userInfo: [String : String]? = nil) {
        qbSession?.hangUp(userInfo)
    }
    
    func remoteVideoTrack(withUserID userID: NSNumber) -> QBRTCVideoTrack? {
        return qbSession?.remoteVideoTrack(withUserID: userID)
    }
}
