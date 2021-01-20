//
//  ConferenceViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 16.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD

struct UserTracksStates {
    var isCameraEnabled: Bool
    var isEnabledSound: Bool
}

class ConferenceViewController: BaseCallViewController {
    private var usersStates:[UInt: UserTracksStates] = [:]
    private var chatDialogName = ""
    private var currentConferenceUserID = Profile().ID
    override var conferenceSettings: ConferenceSettings {
        didSet {
            self.chatDialogName = chatManager.storage.dialog(withID: conferenceSettings.conferenceInfo.chatDialogID)!.name!
        }
    }
    
    private lazy var membersItem = UIBarButtonItem(image: UIImage(named: "members_call"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(didTapMembers(_:)))
    
    override var muteVideo: Bool {
        didSet {
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
            usersStates[currentConferenceUserID]?.isCameraEnabled = !muteVideo
            swapCamera.isUserInteractionEnabled = !muteVideo
        }
    }
    
    // MARK: Overrides
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupNavigationBarWillAppear(false)
        invalidateHideToolbarTimer()
    }
    
    //MARK - Setup
    override func setupDelegates() {
        QBRTCConferenceClient.instance().add(self)
        QBRTCAudioSession.instance().addDelegate(self)
    }
    
    override func setupSession() {
        // creating session
        session = QBRTCConferenceClient.instance().createSession(withChatDialogID: conferenceSettings.conferenceInfo.conferenceID,
                                                                 conferenceType: .video)
        
        guard session != nil, let currentConferenceUser = createConferenceUser(userID: Profile().ID) else {
            return
        }
        let currentUserTracksStates = UserTracksStates(isCameraEnabled: false, isEnabledSound: true)
        usersStates[currentConferenceUserID] = currentUserTracksStates
        users = [currentConferenceUser]
    }
    
    override func configureNavigationBarItems() {
        title = chatDialogName
        navigationItem.rightBarButtonItem = membersItem
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_chat"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapChat(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    override func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        // adding user to the collection
        addToCollectionUser(withID: userID)
    }
    
    override func addNewPublisher(_ user: ConferenceUser) {
        users.insert(user, at: 0)
        usersStates[user.userID] = UserTracksStates(isCameraEnabled: false, isEnabledSound: true)
        reloadContent()
    }
    
    override func removeUserFromCollection(_ userID: NSNumber) {
        if let index = users.index(where: { $0.userID == userID.uintValue }) {
            users.remove(at: index)
        }
    }
    
    override func setupAudioVideoEnabledCell(_ cell: ConferenceUserCell, forUserID userID: UInt) {
        if userID == currentConferenceUserID {
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
        }
        
        if let isMute = usersStates[userID]?.isEnabledSound  {
            cell.unMute = isMute
        }
    }
    
    // MARK: Internal Methods
    @objc private func didTapMembers(_ sender: UIBarButtonItem) {
        guard let chatInfoViewController = ScreenFactory().makeInfoUsersOutput() else { return }
        chatInfoViewController.dialogID = conferenceSettings.conferenceInfo.chatDialogID
        self.callViewControllerDelegate = chatInfoViewController
        chatInfoViewController.action = ChatAction.infoFromCall
        let qbUsers = users.compactMap{ chatManager.storage.user(withID: $0.userID) }
        chatInfoViewController.users = qbUsers
        chatInfoViewController.usersStates = usersStates
        chatInfoViewController.didPressMuteUser = { [weak self] (isMuted, userId) in
            guard let self = self else {
                return
            }
            let userID = NSNumber(value: userId)
            let audioTrack = self.session?.remoteAudioTrack(withUserID: userID)
            audioTrack?.isEnabled = !isMuted
            self.usersStates[userId]?.isEnabledSound = !isMuted
            self.reloadContent()
        }
        session?.localMediaStream.videoTrack.isEnabled = false
        navigationController?.pushViewController(chatInfoViewController, animated: true)
    }
}
