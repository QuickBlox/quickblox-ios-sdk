//
//  SharingScreenCapture.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 30.06.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

struct VideoFormat {
    var width: UInt
    var height: UInt
    var fps: UInt
}

class SharingScreenCapture: QBRTCVideoCapture {
    //MARK: - Properties
    var videoformat: VideoFormat!
    //MARK: - Life Cycle
    init(videoFormat: VideoFormat) {
        super.init()
        
        self.videoformat = videoFormat
    }
    
    // MARK: - <QBRTCVideoCapture>
    override func didSet(to videoTrack: QBRTCLocalVideoTrack?) {
        super.didSet(to: videoTrack)
        
        adaptOutputFormat(toWidth: videoformat.width, height: videoformat.height, fps: videoformat.fps)
    }
}
