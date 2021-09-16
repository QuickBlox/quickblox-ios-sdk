//
//  TimeInterval+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 05.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import Foundation

extension TimeInterval {
    func string() -> String {
        let hours = Int(self / 3600)
        let minutes = Int(self / 60)
        let seconds = Int(self) % 60
        
        var timeStr = ""
        if hours > 0 {
            let minutes = Int((self - Double(3600 * hours)) / 60);
            timeStr = "\(hours):\(minutes):\(seconds)"
        } else {
            if (seconds < 10) {
                timeStr = "\(minutes):0\(seconds)"
            } else {
                timeStr = "\(minutes):\(seconds)"
            }
        }
        return timeStr
    }
}
