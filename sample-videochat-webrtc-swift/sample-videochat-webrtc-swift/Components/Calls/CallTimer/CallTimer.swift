//
//  CallTimer.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 16.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import Foundation

protocol CallTimerProtocol {
    //MARK: - Properties
    var callTimer: CallTimer { get set }
}

struct CallTimerConstant {
    static let refreshTimeInterval: TimeInterval = 1
}

class CallTimer {
    //MARK: - Properties
    var isActive = false
    var onTimeChanged: ((_ duration: String) -> Void)?
    private var timer: Timer? = nil
    private var duration: TimeInterval = 0.0
    
    //MARK: - Public Methods
    func activate() {
        timer = Timer.scheduledTimer(timeInterval: CallTimerConstant.refreshTimeInterval,
                                         target: self,
                                         selector: #selector(self.refreshCallTime),
                                         userInfo: nil,
                                         repeats: true)
        isActive = true
        refreshCallTime()
    }
    
    func deactivate() {
        isActive = true
        if timer == nil { return }
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: - Private Methods
    @objc private func refreshCallTime() {
        duration += CallTimerConstant.refreshTimeInterval
        onTimeChanged?(duration.string())
    }
}
