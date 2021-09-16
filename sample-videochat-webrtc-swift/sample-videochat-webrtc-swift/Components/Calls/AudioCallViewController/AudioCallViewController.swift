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

class AudioCallViewController: UIViewController, CallViewControllerProtocol, CallTimerProtocol {

    //MARK: - IBOutlets
    @IBOutlet weak var vStackView: UIStackView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var actionsBar: CallActionsBar! {
        didSet {
            var actionButtons: [(ActionType, action: (_ sender: ActionButton?) -> Void)] = []
            actionButtons.append((.audio, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                self.media.audioEnabled = !self.media.audioEnabled
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
                    if audioSession.isActive == false { return }
                    let audioPort: AVAudioSession.PortOverride = speakerButton.pressed == false ? .speaker : .none
                    audioSession.overrideOutputAudioPort(audioPort)
                }))
            }
            actionsBar.setup(withActions: actionButtons)
        }
    }
    @IBOutlet weak var timerCallLabel: UILabel! {
        didSet {
            timerCallLabel.setRoundedLabel(cornerRadius: 10.0)
        }
    }
    @IBOutlet weak var statsButton: UIButton! {
        didSet {
            statsButton.isEnabled = false
            statsButton.alpha = 0.0
        }
    }

    var bottomStackView = UIStackView()

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

        showParticipants(callInfo.interlocutors)

        checkCallPermissions(.audio, completion: nil)

        callTimer.onTimeChanged = { [weak self] (duration) in
            guard let self = self else { return }
            self.timerCallLabel.text = duration
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
                
                if self.callInfo.direction == .outgoing {
                    if let isPressed = self.actionsBar.isSelected(.speaker) {
                        let audioPort: AVAudioSession.PortOverride = isPressed ? .speaker : .none
                        let audioSession = QBRTCAudioSession.instance()
                        audioSession.overrideOutputAudioPort(audioPort)
                    }
                }
                
                if self.timerCallLabel.isHidden == true {
                    self.timerCallLabel.isHidden = false
                }
                self.callTimer.activate()
                self.statsButton.isEnabled = true
                self.statsButton.alpha = 1.0
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: animated)
        if callInfo.direction != .incoming { return }
        actionsBar.select(callInfo.currentOutput() == .speaker, type: .speaker)
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

    //MARK: - Private Methods
    private func showParticipants(_ participants: [CallParticipant]) {
        for participant in participants {
            let participantView = ParticipantAudioView.loadNib()
            participantView.name = participant.fullName
            participantView.tag = Int(participant.userID)
            if participant.userID == callInfo.localParticipantId {
                participantView.callingToLabelHeight.constant = 0.0
            }
            else if callInfo.direction == .incoming  {
                participantView.callingToLabelHeight.constant = 0.0
                participantView.stateLabel.text = "Calling..."
            }

            let viewIsFull = topStackView.arrangedSubviews.count == CallConstant.viewMaxCount
            if (viewIsFull) {
                bottomStackView.alignment = .fill
                bottomStackView.distribution = .fillEqually
                bottomStackView.addArrangedSubview(participantView)
                vStackView.addArrangedSubview(bottomStackView)
                continue
            }
            topStackView.addArrangedSubview(participantView)
        }
    }

    private func participantView(userID: Int) -> ParticipantAudioView? {
        let participantsViews =  topStackView.arrangedSubviews + bottomStackView.arrangedSubviews
        guard let participantView = participantsViews.first(where: {$0.tag == userID}) as? ParticipantAudioView else {
            return nil
        }
        return participantView
    }
}
