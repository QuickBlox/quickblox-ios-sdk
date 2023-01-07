//
//  VideoCallViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 16.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

struct CallConstant {
    static let viewMaxCount: Int = 2
}

class VideoCallViewController: CallViewController {
    
    //MARK: - Setup
    override func setupWithCallId(_ callId: String, members: [NSNumber: String], mediaListener: MediaListener, mediaController: MediaController, direction: CallDirection) {
        super.setupWithCallId(callId, members: members, mediaListener: mediaListener, mediaController: mediaController, direction: direction)
        
        self.mediaListener.onVideo = { [weak self] enable in
            if self?.actionsBar == nil {
                return
            }
            self?.actionsBar.select(!enable, type: .video)
        }
        
        self.mediaListener.onSharing = { [weak self] enable in
            if self?.actionsBar == nil {
                return
            }
            self?.actionsBar.select(!enable, type: .share)
        }
    }
    
    override func setupViews() {
        participantsView.setup(callInfo: callInfo, conferenceType: .video)
        checkCallPermissions(.video) { [weak self] videoGranted in
            self?.callInfo.direction == .incoming ? self?.setupCallScreen() : self?.setupCallingScreen()
        }
        callInfo.onChangedState = { [weak self] (participant) in
            
            self?.participantsView.setConnectionState(participant.connectionState, participantId: participant.id)
            
            if participant.connectionState != .connected {
                return
            }
            
            if self?.callTimer.isActive == false {
                self?.callTimer.isActive = true
                self?.statsButton.isEnabled = true
                self?.statsButton.alpha = 1.0
                
                if self?.callInfo.direction == .outgoing {
                    DispatchQueue.main.async {
                        self?.setupCallScreen()
                    }
                }
                return
            }
            
            //setup after reconnect
            if let videoTrack = self?.mediaController.videoTrack(for: participant.id) {
                self?.participantsView.setupVideoTrack(videoTrack, participantId: participant.id)
            }
        }
    }
    
    //MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.actionsBar.select(false, type: .share)
    }
    
    //MARK: - Private Methods
    private func camera(enable:Bool) {
        if  mediaController.camera?.hasStarted == false,
            mediaController.camera?.isRunning == false, enable == true {
            mediaController.camera?.startSession(nil)
        }
        participantsView.hideVideo(!enable, participantId: callInfo.localParticipantId)
        actionsBar.setUserInteractionEnabled(enable, type: .switchCamera)
    }
    
    private func setupCallingScreen() {
        self.statsButton.isEnabled = false
        self.statsButton.alpha = 0.0
        
        actionsBar.setup(withActions: [
            
            (.audio, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                self.mediaController.audioEnabled = !self.mediaController.audioEnabled
            }),
            
            (.decline, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                sender?.isEnabled = false
                self.hangUp?(self.callInfo.callId)
            }),
            
            (.video, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                self.mediaController.videoEnabled = !self.mediaController.videoEnabled
                self.camera(enable: self.mediaController.videoEnabled)
            })
        ])
    }
    
    private func setupCallScreen() {
        headerView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.7),
                                 secondColor: UIColor.black.withAlphaComponent(0.0))
        bottomView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.0),
                                 secondColor: UIColor.black.withAlphaComponent(0.7))
        actionsBar.setup(withActions: [
            
            (.audio, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                
                self.mediaController.audioEnabled = !self.mediaController.audioEnabled
            }),
            
            (.video, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                
                self.mediaController.videoEnabled = !self.mediaController.videoEnabled
                self.camera(enable: self.mediaController.videoEnabled)
            }),
            
            (.decline, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                
                sender?.isEnabled = false
                self.hangUp?(self.callInfo.callId)
            }),
            
            (.share, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                
                guard let sharingVC = Screen.sharingViewController() else {
                    return
                }
                sharingVC.mediaController = self.mediaController
                self.navigationController?.pushViewController(sharingVC, animated: false)
            }),
            
            (.switchCamera, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                
                let animation = CATransition()
                animation.duration = 0.75
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.type = CATransitionType(rawValue: "oglFlip")
                animation.subtype = self.mediaController.camera?.position == .back ? .fromLeft : .fromRight
                self.participantsView.videoAnimation(animation, participantId: self.callInfo.localParticipantId)
                let position: AVCaptureDevice.Position = self.mediaController.camera?.position == .back ? .front : .back
                guard self.mediaController.camera?.hasCamera(for: position) == true else {
                    return
                }
                self.mediaController.camera?.position = position
            })
        ])
        
        actionsBar.select(!mediaController.audioEnabled, type: .audio)
        actionsBar.select(false, type: .share)
        
        if let cameraPreviewLayer = mediaController.camera?.previewLayer {
            let localVideoView = LocalVideoView(previewlayer: cameraPreviewLayer)
            participantsView.addLocalVideo(localVideoView)
        }
        if mediaController.videoEnabled {
            camera(enable: true)
        }
        
        for participant in callInfo.interlocutors {
            if let videoTrack = mediaController.videoTrack(for: participant.id) {
                participantsView.setupVideoTrack(videoTrack, participantId: participant.id)
            }
        }
        
        mediaListener.onReceivedRemoteVideoTrack = { [weak self] (videoTrack, userID) in
            self?.participantsView.setupVideoTrack(videoTrack, participantId: userID.uintValue)
        }
    }
}
