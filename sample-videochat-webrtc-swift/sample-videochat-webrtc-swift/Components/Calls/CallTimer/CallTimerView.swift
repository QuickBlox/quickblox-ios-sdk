//
//  CallTimerView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 23.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

struct CallTimerConstant {
    static let refreshTimeInterval: TimeInterval = 1
}


class CallTimerView: UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setRoundedLabel(cornerRadius: 10.0)
        isHidden = true
    }
    
    //MARK: - Properties
    var isActive = false {
        didSet {
            isActive == true ? activate() : deactivate()
        }
    }
    private var timer: Timer? = nil
    private var duration: TimeInterval = 0.0
    
    //MARK: - Private Methods
    private func activate() {
        timer = Timer.scheduledTimer(timeInterval: CallTimerConstant.refreshTimeInterval,
                                         target: self,
                                         selector: #selector(self.refreshCallTime),
                                         userInfo: nil,
                                         repeats: true)
        isHidden = false
        refreshCallTime()
    }
    
    private func deactivate() {
        isActive = true
        if timer == nil {
            return
        }
        timer?.invalidate()
        timer = nil
        isHidden = true
        removeFromSuperview()
    }
    
    //MARK: - Private Methods
    @objc private func refreshCallTime() {
        duration += CallTimerConstant.refreshTimeInterval
        text = duration.string()
    }
}
