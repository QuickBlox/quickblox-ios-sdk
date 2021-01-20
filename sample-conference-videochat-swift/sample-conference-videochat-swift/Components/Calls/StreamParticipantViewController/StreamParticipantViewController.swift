//
//  StreamParticipantViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 16.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class StreamParticipantViewController: BaseCallViewController {
    lazy private var streamTitleView: StreamTitleView = {
        let streamTitleView = StreamTitleView()
        return streamTitleView
    }()
    
    // MARK: Overrides
    override func setupSession() {
        // creating session
        session = QBRTCConferenceClient.instance().createSession(withChatDialogID: conferenceSettings.conferenceInfo.conferenceID,
                                                                 conferenceType: .video)
        
        guard session != nil else {
            return
        }

        addToCollectionUser(withID: NSNumber(value: conferenceSettings.conferenceInfo.initiatorID))
        reloadContent()
        localVideoView = nil
    }
    
    override func setupLocalMediaStreamVideoCapture() {
        // Listner cannot stream his video
        session?.localMediaStream.videoTrack.videoCapture = nil
    }
    
    override func configureNavigationBarItems() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_chat"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapChat(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        navigationItem.titleView = streamTitleView
        navigationItem.rightBarButtonItem = nil
    }
    
    override func configureToolBar() {
        self.muteAudio = true
        self.muteVideo = true
        toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
            guard let self = self else {
                return
            }
            self.setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
            self.leaveFromCallAnimated(true)
        })
        toolbar.updateItems()
    }
    
    override func setupAudioVideoEnabledCell(_ cell: ConferenceUserCell, forUserID userID: UInt) {
        cell.videoEnabled = true
        cell.unMute = true
    }
    
    override func updateUIWithCreatedNewSession(_ session:QBRTCConferenceSession) {
        session.listOnlineParticipants(completionBlock: { [weak self] publishers, listeners in
            for userID in publishers {
                session.subscribeToUser(withID: userID)
            }
            DispatchQueue.main.async {
                self?.streamTitleView.setupStreamTitleViewOnLive(publishers.isEmpty == false)
            }
        })
    }
    
    override func session(_ session: QBRTCConferenceSession?, didReceiveNewPublisherWithUserID userID: NSNumber?) {
        guard let session = session, session == self.session, let userId = userID else {
            return
        }
            session.subscribeToUser(withID: userId)
            DispatchQueue.main.async {
                self.streamTitleView.setupStreamTitleViewOnLive(true)
                self.showControls(true)
            }
        reloadContent()
    }
    
    override func removeUserFromCollection(_ userID: NSNumber) {
        
        DispatchQueue.main.async {
            self.streamTitleView.setupStreamTitleViewOnLive(false)
            self.showControls(true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showControls(true)
    }
    
    override func userView(userID: UInt) -> UIView? {
        if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: userID)) {
            //Opponents
            if let remoteVideoView = videoViews[userID] as? QBRTCRemoteVideoView {
                return remoteVideoView
            } else {
                let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
                remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
                videoViews[userID] = remoteVideoView
                remoteVideoView.setVideoTrack(remoteVideoTraсk)
                
                return remoteVideoView
            }
    }
        return nil
    }
}
