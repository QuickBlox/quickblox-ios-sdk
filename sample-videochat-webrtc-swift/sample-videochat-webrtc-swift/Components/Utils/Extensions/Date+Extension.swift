//
//  Date+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/28/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation

extension Date {
    var timeStamp: Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
