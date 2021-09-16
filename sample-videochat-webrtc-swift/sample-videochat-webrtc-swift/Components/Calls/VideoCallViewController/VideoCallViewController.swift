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

class VideoCallViewController: UIViewController, CallViewControllerProtocol, CallTimerProtocol {
    
    //MARK: - IBOutlets
    @IBOutlet weak var headerView: CallGradientView!
    @IBOutlet weak var bottomView: CallGradientView!
    @IBOutlet weak var actionsBar: CallActionsBar!
    @IBOutlet weak var statsButton: UIButton! {
        didSet {
            statsButton.isEnabled = false
            statsButton.alpha = 0.0
        }
    }
    @IBOutlet weak var vStackView: UIStackView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var timerCallLabel: UILabel! {
        didSet {
            timerCallLabel.setRoundedLabel(cornerRadius: 10.0)
        }
    }
    
    lazy private var statsView: StatsView = {
        let statsView = StatsView.loadNib()
        return statsView
    }()
    
    //MARK: - Properties
    var callInfo: CallInfo!
    var hangUp: CallHangUpAction?
    var media: MediaRouter!
    
    internal var callTimer = CallTimer()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callInfo.direction == .incoming ? setupCallScreen() : setupCallingScreen()
        
        showParticipants(callInfo.participants)

        checkCallPermissions(.video, completion: nil)
        
        callTimer.onTimeChanged = { [weak self] (duration) in
            guard let self = self else { return }
            self.timerCallLabel.text = duration
        }
        
        media.onReceivedRemoteVideoTrack = { [weak self] (videoTrack, userID) in
            guard let self = self,
                  let participantView = self.participantView(userID: userID.intValue) else { return }
            
            let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
            remoteVideoView.setVideoTrack(videoTrack)
            participantView.videoView = remoteVideoView
        }
        
        media.onReload = { [weak self] in
            self?.callTimer.deactivate()
            self?.callInfo = nil
        }
        
        callInfo.onChangedState = { [weak self] (participant) in
            guard let self = self,
                  let participantView = self.participantView(userID: Int(participant.userID)) else { return }
            participantView.connectionState = participant.connectionState
            
            if self.callTimer.isActive == false, participant.connectionState == .connected {
                if self.timerCallLabel.isHidden == true {
                    self.timerCallLabel.isHidden = false
                }
                self.callTimer.activate()
                
                self.statsButton.isEnabled = true
                self.statsButton.alpha = 1.0

                if let localParticipant = self.callInfo.localParticipant {
                    if self.callInfo.direction == .outgoing {
                        self.setupCallScreen()
                        let localParticipantView = self.setupParticipantView(localParticipant)
                        self.bottomStackView.addArrangedSubview(localParticipantView)
                    }
                    if self.media.videoEnabled {
                        self.camera(enable:self.media.videoEnabled)
                    }
                }
            }
            
            if participant.connectionState == .connected {
                guard let participantVideoView = self.participantView(userID: Int(participant.userID))?.videoView as? QBRTCRemoteVideoView
                else { return }
                participantVideoView.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        self.actionsBar.select(false, type: .share)
    }
    
    //MARK: - Actions
    @IBAction func didTapStatsButton(_ sender: UIButton) {
        statsView.callInfo = callInfo
        
        view.addSubview(statsView)
        statsView.translatesAutoresizingMaskIntoConstraints = false
        statsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        statsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        statsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        statsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
    }

    //MARK: - Private Methods
    private func showParticipants(_ participants: [CallParticipant]) {
        for participant in participants {
            
            if self.callInfo.direction == .outgoing, participant.userID == callInfo.localParticipantId {
                continue
            }
            
            let participantView = setupParticipantView(participant)
            let viewIsFull = topStackView.arrangedSubviews.count == CallConstant.viewMaxCount
            if (viewIsFull || participant.userID == callInfo.localParticipantId) {
                bottomStackView.addArrangedSubview(participantView)
                continue
            }
            topStackView.addArrangedSubview(participantView)
        }
    }
    
    private func setupParticipantView(_ participant: CallParticipant) -> ParticipantVideoView {
        let participantView = ParticipantVideoView.loadNib()
        participantView.name = participant.fullName
        participantView.tag = Int(participant.userID)
        participantView.connectionState = participant.connectionState
        participantView.nameLabel.isHidden = participant.userID == callInfo.localParticipantId
        if participant.userID == callInfo.localParticipantId {
            participantView.callingToLabelHeight.constant = 0.0
        }
         else if callInfo.direction == .incoming  {
            participantView.callingToLabelHeight.constant = 0.0
            participantView.stateLabel.text = "Calling..."
        }
        
        return participantView
    }
    
    private func participantView(userID: Int) -> ParticipantVideoView? {
        let participantsViews =  topStackView.arrangedSubviews + bottomStackView.arrangedSubviews
        guard let participantView = participantsViews.first(where: {$0.tag == userID}) as? ParticipantVideoView else {return nil}
        return participantView
    }
    
    private func camera(enable:Bool) {
        
        if enable == true, callTimer.isActive == true,
           participantView(userID: Int(callInfo.localParticipantId))?.videoView == nil {
                setupLocalVideoView()
        }
        
        if let localVideoView = participantView(userID: Int(callInfo.localParticipantId))?.videoView {
            if media.camera?.isRunning == false, enable == true {
                media.camera?.startSession(nil)
            }
            localVideoView.isHidden = !enable
        }
        actionsBar.setUserInteractionEnabled(enable, type: .switchCamera)
    }
    
    private func setupLocalVideoView() {
        guard let cameraPreviewLayer = media.camera?.previewLayer,
              let participantView = participantView(userID: Int(callInfo.localParticipantId)) else { return }
               let localVideoView = LocalVideoView(previewlayer: cameraPreviewLayer)
               participantView.videoView = localVideoView
    }

    private func setupCallingScreen() {
        self.statsButton.isEnabled = false
        self.statsButton.alpha = 0.0

        actionsBar.setup(withActions: [
            
            (.audio, action: { [weak self] sender in
                guard let self = self else { return }
                self.media.audioEnabled = !self.media.audioEnabled
            }),
            
            (.decline, action: { [weak self] sender in
                guard let self = self else { return }
                sender?.isEnabled = false
                self.hangUp?(self.callInfo.callId)
            }),
            
            (.video, action: { [weak self] sender in
                guard let self = self else { return }
                self.media.videoEnabled = !self.media.videoEnabled
                self.camera(enable: self.media.videoEnabled)
            })
        ])
    }
    
    private func setupCallScreen() {
        self.headerView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.7),
                                 secondColor: UIColor.black.withAlphaComponent(0.0))
        self.bottomView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.0),
                                 secondColor: UIColor.black.withAlphaComponent(0.7))
        actionsBar.setup(withActions: [
            
            (.audio, action: { [weak self] sender in
                guard let self = self else { return }
                
                self.media.audioEnabled = !self.media.audioEnabled
            }),
            
            (.video, action: { [weak self] sender in
                guard let self = self else { return }
                
                self.media.videoEnabled = !self.media.videoEnabled
                self.camera(enable: self.media.videoEnabled)
            }),
            
            (.decline, action: { [weak self] sender in
                guard let self = self else { return }
                
                sender?.isEnabled = false
                self.hangUp?(self.callInfo.callId)
            }),
            
            (.share, action: { [weak self] sender in
                guard let self = self else { return }
                
                guard let sharingVC = Screen.sharingViewController() else { return }
                sharingVC.media = self.media
                self.navigationController?.pushViewController(sharingVC, animated: false)
            }),
            
            (.switchCamera, action: { [weak self] sender in
                guard let self = self else { return }

                guard let localVideoView = self.participantView(userID: Int(self.callInfo.localParticipantId))?.videoView else { return }
                let animation = CATransition()
                animation.duration = 0.75
                animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animation.type = CATransitionType(rawValue: "oglFlip")
                animation.subtype = self.media.camera?.position == .back ? .fromLeft : .fromRight
                
                localVideoView.superview?.layer.add(animation, forKey: nil)
                self.media.switchCamera()
            })
        ])
    }
}
