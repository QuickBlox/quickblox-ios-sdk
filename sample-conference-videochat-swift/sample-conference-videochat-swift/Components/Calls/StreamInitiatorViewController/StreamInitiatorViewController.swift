//
//  StreamInitiatorViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 16.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

struct StreamInitiatorViewControllerConstants {
    static let refreshTimeInterval: TimeInterval = 2.0
}

class StreamInitiatorViewController: BaseCallViewController {
    lazy private var streamTitleView: StreamTitleView = {
        let streamTitleView = StreamTitleView()
        return streamTitleView
    }()
    private var lisnersTimer: Timer?
    private var listenersCount = 0

    // MARK: Overrides
    override func configureNavigationBarItems() {
        navigationItem.titleView = streamTitleView
            streamTitleView.setupStreamTitleViewOnLive(true)
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "0 members",
                                                            style: .plain,
                                                            target: self,
                                                            action: nil)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_chat"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapChat(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func setupAudioVideoEnabledCell(_ cell: ConferenceUserCell, forUserID userID: UInt) {
        cell.videoEnabled = true
        cell.unMute = !muteAudio
    }
    
    override func updateUIWithCreatedNewSession(_ session: QBRTCConferenceSession) {
        let audioSession = QBRTCAudioSession.instance()
        audioSession.initialize { configuration in
            // adding blutetooth support
            
            configuration.categoryOptions = .allowBluetoothA2DP
            configuration.categoryOptions = .allowBluetooth
            
            // adding airplay support
            configuration.categoryOptions = .allowAirPlay
            
            configuration.mode = AVAudioSession.Mode.videoChat.rawValue
        }
        
        session.localMediaStream.audioTrack.isEnabled = true
        session.localMediaStream.videoTrack.isEnabled = true
        session.localMediaStream.videoTrack.videoCapture = cameraCapture
        session.joinAsPublisher()
        createLisnersTimer()
    }
    
    override func showControls(_ isShow: Bool) {
        isShow == true ? createLisnersTimer() : invalidateLisnersTimer()
        setupControls(isShow)
    }
    
    func createLisnersTimer() {
        lisnersTimer = Timer.scheduledTimer(timeInterval: StreamInitiatorViewControllerConstants.refreshTimeInterval,
                                         target: self,
                                         selector: #selector(refreshCallTime(_:)),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    func invalidateLisnersTimer() {
        if let callTimer = lisnersTimer {
            callTimer.invalidate()
            self.lisnersTimer = nil
        }
    }
    
    override func removeUserFromCollection(_ userID: NSNumber) {
        if let index = users.index(where: { $0.userID == userID.uintValue }) {
            users.remove(at: index)
        }
    }
    
    //MARK: - Internal Methods
    @objc private func refreshCallTime(_ sender: Timer?) {
        updateNumberOfLisners()
    }
    
    private func updateNumberOfLisners() {
        session?.listOnlineParticipants(completionBlock: { [weak self] publishers, listeners in
            guard let self = self, self.listenersCount != listeners.count else {return}
            self.listenersCount = listeners.count
            let members = listeners.count == 1 ? "member" : "members"
            DispatchQueue.main.async {
                self.navigationItem.rightBarButtonItem?.title = "\(self.listenersCount) " + members
            }
        })
    }
}
