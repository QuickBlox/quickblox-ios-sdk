//
//  ConferenceUser.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QuickbloxWebRTC

class User {
    //MARK - Properties
    private var user: QBUUser!
    var connectionState: QBRTCConnectionState = .connecting
    var userName: String {
        return user.fullName ?? CallConstant.unknownUserLabel
    }
    
    var userID: UInt {
        return user.id
    }
    
    var bitrate: Double = 0.0
    
    //MARK: - Life Cycle
    required init(user: QBUUser) {
        self.user = user
    }
}
