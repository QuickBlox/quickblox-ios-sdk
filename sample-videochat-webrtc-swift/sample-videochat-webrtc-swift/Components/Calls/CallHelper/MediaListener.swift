//
//  MediaListener.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 07.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import Foundation
import QuickbloxWebRTC

typealias ReceivedRemoteVideoTrackHandler = ( _ videoTrack: QBRTCVideoTrack, _ userID: NSNumber) -> Void
typealias BroadcastHandler = ( _ enabled: Bool) -> Void

class MediaListener {
    //MARK: - Properties
    var onReceivedRemoteVideoTrack: ReceivedRemoteVideoTrackHandler?
    var onAudio: BroadcastHandler?
    var onVideo: BroadcastHandler?
    var onSharing: BroadcastHandler?
}

extension MediaListener: SessionsMediaListenerDelegate {
    func controller(_ controller: SessionsController, didBroadcastMediaType mediaType: MediaType, enabled: Bool) {
        
        switch mediaType {
        case .audio: onAudio?(enabled)
        case .video:onVideo?(enabled)
        case .sharing: onSharing?(enabled)
        }
    }
    
    func controller(_ controller: SessionsController, didReceivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        onReceivedRemoteVideoTrack?(videoTrack, userID)
    }
}
