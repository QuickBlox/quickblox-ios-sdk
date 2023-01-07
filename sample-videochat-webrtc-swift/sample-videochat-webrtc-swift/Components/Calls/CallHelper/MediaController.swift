//
//  MediaController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 07.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

enum MediaType {
    case audio, video, sharing
}

enum ChangeAudioStateAction: UInt {
    case user, callKit
}

protocol MediaControllerDelegate: AnyObject {
    func mediaController(_ mediaController: MediaController, videoBroadcast enable: Bool, capture: QBRTCVideoCapture?)
    func mediaController(_ mediaController: MediaController, audioBroadcast enable: Bool, action: ChangeAudioStateAction)
    func mediaController(_ mediaController: MediaController, videoTrackForUserID userID: UInt) -> QBRTCVideoTrack?
}

class MediaController: NSObject {
    //MARK: - Properties
    weak var delegate: MediaControllerDelegate?
    var camera: QBRTCCameraCapture? = nil
    var sharing: SharingScreenCapture? = nil
    
    var videoFormat: VideoFormat!
    var sharingFormat: VideoFormat!
    
    private var _audioEnabled = true
    
    var currentAudioOutput: AVAudioSession.PortOverride {
        let audioSession = QBRTCAudioSession.instance()
        if audioSession.isActive {
            let outputs = AVAudioSession.sharedInstance().currentRoute.outputs
            for output in outputs {
                switch output.portType {
                case .builtInSpeaker: return .speaker
                default: return .none
                }
            }
        }
        return .none
    }
    
    private var appActiveStateObserver: NSObjectProtocol!
    private var appInactiveStateObserver: NSObjectProtocol!
    private var necessaryToContinueVideoBroadcast = false

    //MARK: - Life Cycle
    override init() {
        super.init()
        
        let center = NotificationCenter.default
        appActiveStateObserver = center.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                    object: nil,
                                                    queue: OperationQueue.main,
                                                    using: { [weak self] (note) in
            guard let self = self else {
                return
            }
            if self.necessaryToContinueVideoBroadcast == false {
                return
            }
            self.necessaryToContinueVideoBroadcast = false
            self.delegate?.mediaController(self, videoBroadcast: true, capture: nil)
        })
        
        appInactiveStateObserver = center.addObserver(forName: UIApplication.willResignActiveNotification,
                                                      object: nil,
                                                      queue: OperationQueue.main,
                                                      using: { [weak self] (note) in
            guard let self = self else {
                return
            }
            if self.videoEnabled == false, self.sharingEnabled == false {
                return
            }
            self.delegate?.mediaController(self, videoBroadcast: false, capture: nil)
            self.necessaryToContinueVideoBroadcast = true
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
            delegate?.mediaController(self, videoBroadcast: videoEnabled, capture: camera)
            
        }
    }
    
    /// Audio broadcast
    var audioEnabled: Bool {
        get {
            return self._audioEnabled
        }
        set {
            self._audioEnabled = newValue
            
            delegate?.mediaController(self, audioBroadcast: newValue, action: .user)
        }
    }
    
    /// Sharing broadcast
    var sharingEnabled = false {
        didSet {
            if sharingEnabled == true {
                sharing = SharingScreenCapture(sharingFormat: sharingFormat)
                delegate?.mediaController(self, videoBroadcast: true, capture: sharing)
                return
            }
            delegate?.mediaController(self, videoBroadcast: videoEnabled, capture: camera)
            sharing = nil
        }
    }
    
    func sendScreenContent(_ content: CVPixelBuffer) {
        guard let sharing = sharing else {
            return
        }
        
        let videoFrame = QBRTCVideoFrame(pixelBuffer: content, videoRotation: QBRTCVideoRotation._0)
        sharing.send(videoFrame)
    }
    
    func videoTrack(for userId: UInt) -> QBRTCVideoTrack? {
        return delegate?.mediaController(self, videoTrackForUserID: userId)
    }
}

extension MediaController: CallKitManagerActionDelegate {
    func callKit(_ callKit: CallKitManager, didTapMute isMuted: Bool) {
        if audioEnabled == !isMuted {
            return
        }
        self._audioEnabled = !isMuted
        
        delegate?.mediaController(self, audioBroadcast: !isMuted, action: .callKit)
    }
}
