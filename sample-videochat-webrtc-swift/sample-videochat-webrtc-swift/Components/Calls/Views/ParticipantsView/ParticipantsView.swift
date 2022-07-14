//
//  ParticipantsView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 16.12.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

class ParticipantsView: UIView {
    //MARK: - IBOutlets
    @IBOutlet private weak var topStackView: UIStackView!
    @IBOutlet private weak var bottomStackView: UIStackView!
    //MARK: - Properties
    var callInfo: CallInfo!
    var conferenceType: QBRTCConferenceType = .video
    private var viewCache:[UInt: ParticipantView] = [:]
    
    //MARK: - Public Methods
    func setup(callInfo: CallInfo, conferenceType: QBRTCConferenceType) {
        self.conferenceType = conferenceType
        self.callInfo = callInfo
        
        callInfo.onUpdatedParticipant = { [weak self] (participant) in
            guard let participantView = self?.viewCache[participant.id] else {
                return
            }
            participantView.name = participant.fullName
        }
        
        let participants = conferenceType == .video ? callInfo.participants : callInfo.interlocutors
        for participant in participants {
            if conferenceType == .video,
               callInfo.direction == .outgoing,
               participant.id == callInfo.localParticipantId {
                continue
            }
            let participantView = createView(participant)
            let viewIsFull = topStackView.arrangedSubviews.count == 2
            if conferenceType == .video,
               participant.id == callInfo.localParticipantId {
                bottomStackView.addArrangedSubview(participantView)
                continue
            }
            
            if viewIsFull {
                bottomStackView.addArrangedSubview(participantView)
                return
            }
            topStackView.addArrangedSubview(participantView)
        }
    }
    
    func addLocalVideo(_ videoView: UIView) {
        if let participantView = viewCache[callInfo.localParticipantId] as? ParticipantVideoView {
            if participantView.videoView != nil {
                return
            }
            participantView.videoView = videoView
            return
        }
        guard let participant = callInfo.participant(callInfo.localParticipantId),
              let participantView = createView(participant) as? ParticipantVideoView else {
            return
        }
        bottomStackView.addArrangedSubview(participantView)
        participantView.videoView = videoView
        participantView.videoContainerView.isHidden = false
    }
    
    func setupVideoTrack(_ videoTrack: QBRTCVideoTrack, participantId: UInt) {
        guard let participantView = viewCache[participantId] as? ParticipantVideoView,
              let participantVideoView = participantView.videoView as? QBRTCRemoteVideoView else {
            return
        }
        participantVideoView.setVideoTrack(videoTrack)
        participantView.videoContainerView.isHidden = false
    }
    
    func hideVideo(_ hidden: Bool, participantId: UInt) {
        guard let participantView = viewCache[participantId] as? ParticipantVideoView else {
            return
        }
        participantView.videoContainerView.isHidden = hidden
    }
    
    func videoAnimation(_ animation: CATransition, participantId: UInt) {
        guard let participantView = viewCache[participantId] as? ParticipantVideoView,
              let videoView = participantView.videoView else {
            return
        }
        videoView.superview?.layer.add(animation, forKey: nil)
    }
    
    func setConnectionState(_ connectionState: QBRTCConnectionState, participantId: UInt) {
        guard let participantView = viewCache[participantId] else {
            return
        }
        participantView.connectionState = connectionState
    }
    
    //MARK: - Private Methods
    private func createView(_ participant: CallParticipant) -> ParticipantView {
        if conferenceType == .video {
            let participantView = ParticipantVideoView.loadNib()
            participantView.name = participant.fullName
            participantView.ID = participant.id
            participantView.connectionState = participant.connectionState
            participantView.nameLabel.isHidden = participant.id == callInfo.localParticipantId
            if participant.id == callInfo.localParticipantId {
                participantView.isCallingInfo = false
            } else if callInfo.direction == .incoming  {
                participantView.isCallingInfo = false
                participantView.stateLabel.text = "Calling..."
            }
            
            if participant.id != callInfo.localParticipantId {
                let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
                remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
                participantView.videoView = remoteVideoView
            }
            
            viewCache[participant.id] = participantView
            return participantView
        }
        let participantView = ParticipantView.loadNib()
        
        participantView.name = participant.fullName
        participantView.ID = participant.id
        if participant.id == callInfo.localParticipantId {
            participantView.isCallingInfo = false
        } else if callInfo.direction == .incoming  {
            participantView.isCallingInfo = false
            participantView.stateLabel.text = "Calling..."
        }
        viewCache[participant.id] = participantView
        return participantView
    }
}
