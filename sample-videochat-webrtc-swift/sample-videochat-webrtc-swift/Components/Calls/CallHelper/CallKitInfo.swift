//
//  CallKitInfo.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 30.03.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import Foundation

struct CallKitInfo {
    //MARK: - Properties
    var sessionID = ""
    var hasVideo: Bool
    var uuid: UUID
    
    //MARK: - Life Cycle
    init(sessionID: String, hasVideo: Bool) {
        self.sessionID = sessionID
        self.hasVideo = hasVideo
        if sessionID.isEmpty == false, let callUuid = UUID(uuidString: sessionID) {
            self.uuid = callUuid
            return
        }
        self.uuid = UUID()
    }
}
