//
//  ConferenceUser.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 07.11.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import Quickblox
import QuickbloxWebRTC

class ConferenceUser {
    //MARK - Properties
    private var user: QBUUser!
    var connectionState: QBRTCConnectionState = .connecting
    var userName: String {
        return user.fullName ?? CallConstants.unknownUserLabel
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
