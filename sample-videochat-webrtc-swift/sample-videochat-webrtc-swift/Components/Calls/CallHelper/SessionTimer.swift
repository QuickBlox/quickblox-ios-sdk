//
//  SessionTimer.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 31.03.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

enum SessionTimerType {
    case active
    case accept
    case actions
}

protocol SessionTimerDelegate: AnyObject {
    func timerDidEndWaiting(_ timer: SessionTimer)
}

class SessionTimer: NSObject {
    //MARK: - Properties
    weak var delegate: SessionTimerDelegate?
    private(set) var type: SessionTimerType?
    private(set) var sessionId: String!
    var userInfo: [String: String]?
    private var timer: Timer?

    class func waitSession(sessionId: String, type: SessionTimerType, waitingTime time: TimeInterval) -> SessionTimer {
        return SessionTimer(sessionId: sessionId, type: type, waitingTime: time)
    }
    
    //MARK: - Life Cycle
    init(sessionId: String, type: SessionTimerType, waitingTime time: TimeInterval) {
        super.init()
        self.sessionId = sessionId
        self.type = type
        self.timer = Timer.scheduledTimer(timeInterval: time,
                                          target: self,
                                          selector: #selector(didEndWaiting(_:)),
                                          userInfo: nil,
                                          repeats: false)
    }

    //MARK: - Public Methods
    func invalidate() {
        timer?.invalidate()
    }
    
    //MARK: - Actions
    @objc func didEndWaiting(_ sender: Timer?) {
        delegate?.timerDidEndWaiting(self)      
    }
}
