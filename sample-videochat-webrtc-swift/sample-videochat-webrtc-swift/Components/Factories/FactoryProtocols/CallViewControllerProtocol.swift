//
//  CallViewControllerProtocol.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 01.09.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

protocol CallViewControllerProtocol: UIViewController {
    //MARK: - Properties
    var callInfo: CallInfo! { get set }
    var media: MediaRouter! { get set }
    var actionsBar: CallActionsBar! { get }
    var hangUp: CallHangUpAction? { get set }
    //MARK: - Public Methods
    func setupWithCallId(_ callId: String,members: [NSNumber: String], media: MediaRouter, direction: CallDirection)
    func update(withMembers members: [NSNumber: String])
    func onMute(_ enable: Bool)
    func checkCallPermissions(_ conferenceType: QBRTCConferenceType, completion:((_ videoGranted: Bool) -> Void)?)
}

//MARK: - CallViewProtocol
extension CallViewControllerProtocol {
    func setupWithCallId(_ callId: String, members: [NSNumber: String], media: MediaRouter, direction: CallDirection) {
        callInfo = CallInfo(callId: callId, members: members, direction: direction)
        self.media = media
    }
    
    func update(withMembers members: [NSNumber: String]) {
        callInfo.updateWithMembers(members)
    }
    
    func onMute(_ enable: Bool) {
        actionsBar.select(enable, type: .audio)
        media.audioEnabled = !enable
    }
    
    func checkCallPermissions(_ conferenceType: QBRTCConferenceType, completion:((_ videoGranted: Bool) -> Void)?) {
        CallPermissions.check(with: .audio, presentingViewController: self) { [weak self] audioGranted in
            guard let self = self else { return }
            self.media.audioEnabled = audioGranted
            self.actionsBar.select(!audioGranted, type: .audio)
            self.actionsBar.setUserInteractionEnabled(audioGranted, type: .audio)
        }

        if conferenceType == .video {
            CallPermissions.check(with: .video, presentingViewController: self) { [weak self] videoGranted in
                guard let self = self else { return }
                self.actionsBar.select(!videoGranted, type: .video)
                self.actionsBar.select(!videoGranted, type: .switchCamera)
                self.actionsBar.setUserInteractionEnabled(videoGranted, type: .video)
                self.actionsBar.setUserInteractionEnabled(videoGranted, type: .switchCamera)
                self.media.videoEnabled = videoGranted
                completion?(videoGranted)
            }
        }
    }
}
