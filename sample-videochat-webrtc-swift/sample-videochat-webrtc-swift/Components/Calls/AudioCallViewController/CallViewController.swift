//
//  AudioCallViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 27.04.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import Foundation
import UIKit
import QuickbloxWebRTC

class CallViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var headerView: CallGradientView!
    @IBOutlet weak var bottomView: CallGradientView!
    @IBOutlet weak var actionsBar: CallActionsBar! {
        didSet {
            var actionButtons: [(ActionType, action: (_ sender: ActionButton?) -> Void)] = []
            actionButtons.append((.audio, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                self.mediaController.audioEnabled = !self.mediaController.audioEnabled
            }))
            
            actionButtons.append((.decline, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                sender?.isEnabled = false
                self.hangUp?(self.callInfo.callId)
            }))
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                actionButtons.append((.speaker, action: { sender in
                    guard let speakerButton = sender else { return}
                    let audioSession = QBRTCAudioSession.instance()
                    if audioSession.isActive == false {
                        return
                    }
                    let audioPort: AVAudioSession.PortOverride = speakerButton.pressed == false ? .speaker : .none
                    audioSession.overrideOutputAudioPort(audioPort)
                }))
            }
            actionsBar.setup(withActions: actionButtons)
            
            let selectedState = mediaController.currentAudioOutput == AVAudioSession.PortOverride.speaker
            actionsBar.select(selectedState, type: .speaker)
            actionsBar.select(!mediaController.audioEnabled, type: .audio)
        }
    }
    @IBOutlet weak var participantsView: ParticipantsView!
    
    @IBOutlet weak var statsButton: UIButton! {
        didSet {
            statsButton.isEnabled = false
            statsButton.alpha = 0.0
        }
    }
    
    @IBOutlet weak var callTimer: CallTimerView!
    
    lazy var statsView: StatsView = {
        let statsView = StatsView.loadNib()
        return statsView
    }()
    
    //MARK: - Properties
    var callInfo: CallInfo!
    var hangUp: CallHangUpAction?
    var mediaListener: MediaListener!
    var mediaController: MediaController!
    
    //MARK - Setup
    func setupWithCallId(_ callId: String, members: [NSNumber: String], mediaListener: MediaListener, mediaController: MediaController, direction: CallDirection) {
        callInfo = CallInfo(callId: callId, members: members, direction: direction)
        self.mediaListener = mediaListener
        self.mediaController = mediaController
        
        self.mediaListener.onAudio = { [weak self] enable in
            if self?.actionsBar == nil {
                return
            }
            self?.actionsBar.select(!enable, type: .audio)
        }
    }
    
    func setupViews() {
        participantsView.setup(callInfo: callInfo, conferenceType: .audio)
        checkCallPermissions(.audio, completion: nil)

        callInfo.onChangedState = { [weak self] (participant) in
            self?.participantsView.setConnectionState(participant.connectionState, participantId: participant.id)
            
            if self?.callTimer.isActive == false, participant.connectionState == .connected {
                self?.callTimer.isActive = true
                self?.statsButton.isEnabled = true
                self?.statsButton.alpha = 1.0
                
                if self?.callInfo.direction == .outgoing,
                   let isPressed = self?.actionsBar.isSelected(.speaker) {
                    let audioPort: AVAudioSession.PortOverride = isPressed ? .speaker : .none
                    let audioSession = QBRTCAudioSession.instance()
                    audioSession.overrideOutputAudioPort(audioPort)
                }
            }
        }
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @IBAction func didTapStatsButton(_ sender: UIButton) {
        statsView.callInfo = callInfo
        
        view.addSubview(statsView)
        statsView.translatesAutoresizingMaskIntoConstraints = false
        statsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        statsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        statsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        statsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
    }
    
    func checkCallPermissions(_ conferenceType: QBRTCConferenceType, completion:((_ videoGranted: Bool) -> Void)?) {
        CallPermissions.check(with: .audio, presentingViewController: self) { [weak self] audioGranted in
            if audioGranted == false {
                self?.mediaController.audioEnabled = false
                self?.actionsBar.select(true, type: .audio)
                self?.actionsBar.setUserInteractionEnabled(false, type: .audio)
            }
            if conferenceType == .audio {
                completion?(audioGranted)
                return
            }
        }
        
        if conferenceType == .video {
            CallPermissions.check(with: .video, presentingViewController: self) { [weak self] videoGranted in
                if videoGranted == false {
                    self?.actionsBar.select(true, type: .video)
                    self?.actionsBar.select(true, type: .switchCamera)
                    self?.actionsBar.setUserInteractionEnabled(false, type: .video)
                    self?.actionsBar.setUserInteractionEnabled(false, type: .switchCamera)
                }
                self?.mediaController.videoEnabled = videoGranted
                completion?(videoGranted)
            }
        }
    }
}
