//
//  MediaRouter.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 31.03.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

typealias ReceivedRemoteVideoTrackHandler = ( _ videoTrack: QBRTCVideoTrack, _ userID: NSNumber) -> Void

protocol MediaDelegate: AnyObject {
    func router(_ router: MediaRouter, videoBroadcast enable: Bool, capture: QBRTCVideoCapture?)
    func router(_ router: MediaRouter, audioBroadcast enable: Bool)
    func router(_ router: MediaRouter, audioBroadcast enable: Bool, fromUser userID: NSNumber)
}

class MediaRouter: NSObject {
    //MARK: - Properties
    var onReceivedRemoteVideoTrack: ReceivedRemoteVideoTrackHandler?
    var onReload: (() -> Void)?
    
    weak var delegate: MediaDelegate?
    var camera: QBRTCCameraCapture? = nil
    var sharing: SharingScreenCapture? = nil
    
    var isSetVideoFormat = false
    
    private var appActiveStateObserver: NSObjectProtocol!
    private var appInactiveStateObserver: NSObjectProtocol!
    private var didDiactivatedOutside = false
    
    override init() {
        super.init()

        let center = NotificationCenter.default
        appActiveStateObserver = center.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                    object: nil,
                                                    queue: OperationQueue.main,
                                                    using: { [weak self] (note) in
                                                        guard let self = self else { return }
                                                        if self.didDiactivatedOutside == false { return }
                                                        self.didDiactivatedOutside = false
                                                        self.delegate?.router(self, videoBroadcast: true, capture: nil)
                                                    })
        
        appInactiveStateObserver = center.addObserver(forName: UIApplication.willResignActiveNotification,
                                                      object: nil,
                                                      queue: OperationQueue.main,
                                                      using: { [weak self] (note) in
                                                        guard let self = self else { return }
                                                        if self.videoEnabled == false, self.sharingEnabled == false {
                                                            return
                                                        }
                                                        self.delegate?.router(self, videoBroadcast: false, capture: nil)
                                                        self.didDiactivatedOutside = true
                                                      })
    }
    
    /// Video broadcast
    var videoEnabled = false {
        didSet {
            if videoEnabled == true, camera == nil {
                let settings = Settings()
                camera = QBRTCCameraCapture(videoFormat: settings.videoFormat,
                                            position: settings.preferredCameraPostion)
            }
            delegate?.router(self, videoBroadcast: videoEnabled, capture: camera)
        }
    }
    
    func switchCamera() {
        guard let camera = camera else {
            return
        }
        let position: AVCaptureDevice.Position = camera.position == .back ? .front : .back
        guard camera.hasCamera(for: position) == true else {
            return
        }

        camera.position = position
    }
    
    func receivedRemoteVideoTrack(_ videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        onReceivedRemoteVideoTrack?(videoTrack, userID)
    }
    
    /// Audio broadcast
    var audioEnabled = false {
        didSet {
            delegate?.router(self, audioBroadcast: audioEnabled)
        }
    }
    
    func turnAudioBroadcast(enable: Bool, fromUser userID: NSNumber) {
        delegate?.router(self, audioBroadcast: enable, fromUser: userID)
    }
    
    
    /// Sharing broadcast
    var sharingEnabled = false {
        didSet {
            if sharingEnabled == true {
                self.delegate?.router(self, videoBroadcast: true, capture: sharing)
                return
            }
            delegate?.router(self, videoBroadcast: videoEnabled, capture: camera)
            sharing = nil
        }
    }
    
    func startScreenSharing(withFormat videoFormat: VideoFormat) {
        sharing = SharingScreenCapture(videoFormat: videoFormat)
        sharingEnabled = true
    }
    
    func sendScreenContent(_ content: CVPixelBuffer) {
        guard let sharing = sharing else {
            return
        }
        
        let videoFrame = QBRTCVideoFrame(pixelBuffer: content, videoRotation: QBRTCVideoRotation._0)
        sharing.send(videoFrame)
    }
    
    /// Set router to default state
    ///
    /// Stopping camera when it running
    func reload() {
        onReload?()
        didDiactivatedOutside = false
        audioEnabled = true
        sharingEnabled = false
        videoEnabled = false
        if let camera = camera, camera.isRunning {
            camera.stopSession(nil)
        }
        camera = nil
    }
}
