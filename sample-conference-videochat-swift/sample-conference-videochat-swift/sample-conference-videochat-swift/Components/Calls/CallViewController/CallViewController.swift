//
//  CallViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD

enum CallViewControllerState : Int {
    case disconnected
    case connecting
    case connected
    case disconnecting
}

struct CallStateConstant {
    static let disconnected = "Disconnected"
    static let connecting = "Connecting..."
    static let connected = "Connected"
    static let disconnecting = "Disconnecting..."
}

struct CallConstants {
    static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let unknownUserLabel = "Unknown user"
    static let usersSegue = "PresentUsersViewController"
    
    static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call", comment: "")
    static let conferenceDidClose = NSLocalizedString("Conference did close due to time out", comment: "")
}

class CallViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    
    var chatDialog: QBChatDialog?
    var conferenceType: QBRTCConferenceType?
    weak var usersDataSource: UsersDataSource?
    private weak var session: QBRTCConferenceSession?
    @IBOutlet private weak var opponentsCollectionView: UICollectionView!
    @IBOutlet private weak var toolbar: QBToolBar!
    private var users = [QBUUser]()
    private var cameraCapture: QBRTCCameraCapture?
    private var videoViews = [NSNumber: UIView]()
    lazy private var dynamicEnable: QBButton = {
        let dynamicEnable = QBButtonsFactory.dynamicEnable()
        return dynamicEnable
    }()
    lazy private var videoEnabled: QBButton = {
        let videoEnabled = QBButtonsFactory.videoEnable()
        return videoEnabled
    }()
    private var localVideoView: LocalVideoView?
    lazy private var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()
    private var shouldGetStats = false
    private var statsUserID: NSNumber?
    lazy private var zoomedView: ZoomedView = {
        let zoomedView = ZoomedView()
        return zoomedView
    }()
    private weak var originCell: OpponentCollectionViewCell?
    private var state: CallViewControllerState? {
        didSet {
            if let state = state {
                setState(state)
            }
        }
    }
    private var muteAudio = false {
        didSet {
            setMuteAudio(muteAudio)
        }
    }
    private var muteVideo = false {
        didSet {
            setMuteVideo(muteVideo)
        }
    }
    private var statsItem: UIBarButtonItem?
    private var addUsersItem: UIBarButtonItem?
    
    private var didStartPlayAndRecord = false
    
    private let core = QBCore.instance
    private let settings = Settings.instance
    
    var isListnerOnly: Bool {
        return conferenceType == nil
    }
    
    // MARK: Life cycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("deinit \(self)")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        QBRTCConferenceClient.instance().add(self)
        QBRTCAudioSession.instance().addDelegate(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let chatDialog = self.chatDialog,
            let chatDialogID = chatDialog.id,
            let currentUser = core.currentUser else {
            return
        }
        if self.conferenceType != nil {
            users = [currentUser]
        } else {
            users = [QBUUser]()
        }
        // creating session
        let conferenceType = self.conferenceType ?? QBRTCConferenceType.video
        session = QBRTCConferenceClient.instance().createSession(withChatDialogID: chatDialogID,
                                                                 conferenceType: conferenceType)
        guard let session = self.session else { return }
        if session.conferenceType == QBRTCConferenceType.video, isListnerOnly == false {
            #if targetEnvironment(simulator)
            // Simulator
            #else
            // Device
            cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat, position: settings.preferredCameraPostion)
            cameraCapture?.startSession(nil)
            #endif
        }
        
        configureGUI()
        opponentsCollectionView.collectionViewLayout = OpponentsFlowLayout()
        opponentsCollectionView.backgroundColor = UIColor(red: 0.1465, green: 0.1465, blue: 0.1465, alpha: 1.0)
        view.backgroundColor = opponentsCollectionView.backgroundColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SVProgressHUD.show(withStatus: CallConstants.memoryWarning)
        state = CallViewControllerState.disconnecting
        session?.leave()
    }
    
    func configureGUI() {
        if let conferenceType = self.conferenceType {
            switch conferenceType {
            case .video:
                toolbar.add(videoEnabled, action: { [weak self] sender in
                    if let muteVideo = self?.muteVideo {
                        self?.muteVideo = !muteVideo
                        self?.localVideoView?.isHidden = !muteVideo
                    }
                })
            case .audio:
                dynamicEnable.pressed = true
                toolbar.add(dynamicEnable, action: { sender in
                    let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
                    let device = previousDevice == QBRTCAudioDevice.speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
                    QBRTCAudioSession.instance().currentAudioDevice = device
                })
            }
            toolbar.add(QBButtonsFactory.auidoEnable(), action: { [weak self] sender in
                if let muteAudio = self?.muteAudio {
                    self?.muteAudio = !muteAudio
                }
            })
        }
        
        toolbar.updateItems()
        
        // zoomed view
        prepareSubview(view: view, subview: zoomedView)
        zoomedView.didTapView = { [weak self] zoomedView in
            self?.unzoomVideoView()
        }
        // stats view
        prepareSubview(view: view, subview: statsView)
        
        // add button to enable stats view
        statsItem = UIBarButtonItem(title: "Stats", style: .plain, target: self, action: #selector(updateStatsView))
        addUsersItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushAddUsersToRoomScreen))
        state = CallViewControllerState.connecting
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Leave", style: .plain, target: self, action: #selector(leaveFromRoom))
        navigationItem.rightBarButtonItem = addUsersItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshVideoViews()
        
        if cameraCapture?.hasStarted == false {
            // ideally you should always stop capture session
            // when you are leaving controller in any way
            // here we should get its running state back
            cameraCapture?.startSession(nil)
        }
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.refreshVideoViews()
        })
    }
    
    // MARK: Overrides
    func setState(_ state: CallViewControllerState) {
        switch state {
        case .disconnected:
            title = CallStateConstant.disconnected
        case .connecting:
            title = CallStateConstant.connecting
        case .connected:
            title = CallStateConstant.connected
        case .disconnecting:
            title = CallStateConstant.disconnecting
        }
    }
    
    func setMuteAudio(_ muteAudio: Bool) {
        session?.localMediaStream.audioTrack.isEnabled = !muteAudio
    }
    
    func setMuteVideo(_ muteVideo: Bool) {
        session?.localMediaStream.videoTrack.isEnabled = !muteVideo
    }
    
    // MARK: Actions
    @objc func pushAddUsersToRoomScreen() {
        performSegue(withIdentifier: CallConstants.usersSegue, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        cameraCapture?.stopSession(nil)
        if (segue.identifier == CallConstants.usersSegue) {
            
            let usersVC = segue.destination as? AddUsersViewController
            usersVC?.usersDataSource = usersDataSource
            usersVC?.chatDialog = chatDialog
        }
    }
    
    func zoomVideoView(_ videoView: UIView?) {
        zoomedView.videoView = videoView
        zoomedView.isHidden = false
        navigationItem.rightBarButtonItem = statsItem
    }
    
    func unzoomVideoView() {
        if originCell != nil {
            originCell!.videoView = zoomedView.videoView
            zoomedView.videoView = nil
            originCell = nil
            zoomedView.isHidden = true
            statsUserID = nil
            navigationItem.rightBarButtonItem = addUsersItem
        }
    }
    
    func addToCollectionUser(withID userID: NSNumber) {
        
        guard let user: QBUUser = fetchUser(withID: userID) else { return }
//        guard let index = users.index(of: user) else { return }
//        if users.contains(user) == true {
//            return
//        }
//        debugPrint("index \(index)")
        if users.index(of: user) != NSNotFound {
            return
        }

        users.insert(user, at: 0)
        let indexPath = IndexPath(item: 0, section: 0)
        
        weak var weakSelf = self
        opponentsCollectionView.performBatchUpdates({
            weakSelf?.opponentsCollectionView.insertItems(at: [indexPath])
        }) { finished in
            weakSelf?.refreshVideoViews()
        }
    }
    
    func removeFromCollectionUser(withID userID: NSNumber) {
        guard let user: QBUUser = fetchUser(withID: userID) else { return }
        if users.index(of: user) == NSNotFound {
            return
        } else {
            let index = users.index(of: user)
            let indexPath = IndexPath(item: index ?? 0, section: 0)
            users.removeAll(where: { element in element == user })
            videoViews.removeValue(forKey: userID)
            
            weak var weakSelf = self
            opponentsCollectionView.performBatchUpdates({
                weakSelf?.opponentsCollectionView.deleteItems(at: [indexPath])
            }) { finished in
                weakSelf?.refreshVideoViews()
            }
        }
    }
    
    func closeCall(withTimeout timeout: Bool) {
        
        // removing delegate on close call so we don't get any callbacks
        // that will force collection view to perform updates
        // while controller is deallocating
        QBRTCConferenceClient.instance().remove(self)

        // stopping camera session
        cameraCapture?.stopSession(nil)

        // toolbar
        toolbar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.toolbar.alpha = 0.4
        })

        state = CallViewControllerState.disconnected

        if timeout {
            SVProgressHUD.showError(withStatus: CallConstants.conferenceDidClose)
            navigationController?.popToRootViewController(animated: true)
        } else {
            // dismissing progress hud if needed
            navigationController?.popToRootViewController(animated: true)
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func leaveFromRoom() {
        state = CallViewControllerState.disconnecting
        if session?.state == QBRTCSessionState.pending {
            closeCall(withTimeout: false)
        } else if session?.state != QBRTCSessionState.new {
            SVProgressHUD.show(withStatus: nil)
        }
        session?.leave()
    }
    
    @inline(__always) private func prepareSubview(view: UIView?, subview: UIView) {
        
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        subview.isHidden = false
        view?.addSubview(subview)
    }
    
    func refreshVideoViews() {
        
        // resetting zoomed view
        let zoomedVideoView: UIView? = zoomedView.videoView
        if let visibleCells = opponentsCollectionView?.visibleCells {
            for viewToRefresh in visibleCells {
                if viewToRefresh is OpponentCollectionViewCell {
                    let viewToRefr: OpponentCollectionViewCell = viewToRefresh as! OpponentCollectionViewCell
                    let view: UIView? = viewToRefr.videoView
                    if view == zoomedVideoView {
                        continue
                    }
                    viewToRefr.videoView = nil
                    viewToRefr.videoView = view
                }
            }
        }
    }
    
    @objc func updateStatsView() {
        shouldGetStats = !shouldGetStats
        statsView.isHidden = !statsView.isHidden
    }
    
    func videoView(withOpponentID opponentID: NSNumber?) -> UIView {
        
        var result = UIView()

        if core.currentUser?.id == opponentID?.uintValue, session?.conferenceType != QBRTCConferenceType.audio {
            //Local preview
            if videoViews.isEmpty == true {
                if let cameraCapture = self.cameraCapture {
                    let localVideoView = LocalVideoView(previewlayer: cameraCapture.previewLayer)
                    if let opponentID = opponentID {
                        videoViews[opponentID] = localVideoView
                    }
                    localVideoView.delegate = self
                    self.localVideoView = localVideoView
                    result = localVideoView
                    return localVideoView
                }
            }
        } else {
            //Opponents
            var remoteVideoView = QBRTCRemoteVideoView()
            if let opponentID = opponentID,
                let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: opponentID) {
                remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2, y: 2, width: 2, height: 2))
                remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                videoViews[opponentID] = remoteVideoView
                remoteVideoView.setVideoTrack(remoteVideoTraсk)
                return remoteVideoView
            }
        }
        return result
    }
    
    func fetchUser(withID userID: NSNumber) -> QBUUser? {
        var user: QBUUser?
        if let qbUser = usersDataSource?.user(withID: userID.intValue) {
            user = qbUser
        }
        return user
    }
    
    func indexPath(atUserID userID: NSNumber) -> IndexPath {
        var indexPath = IndexPath(row: 0, section: 0)
        guard let user: QBUUser = fetchUser(withID: userID) else { return indexPath }
        let idx = users.index(of: user)
        indexPath = IndexPath(row: idx ?? 0, section: 0)
        return indexPath
    }
    
    func performUpdateUserID(_ userID: NSNumber, block: @escaping (_ cell: OpponentCollectionViewCell?) -> Void) {
        let indexPath: IndexPath? = self.indexPath(atUserID: userID)
        if let indexPath = indexPath {
            let cell = opponentsCollectionView.cellForItem(at: indexPath) as? OpponentCollectionViewCell
            block(cell)
        }
    }
    
}
    
    // MARK: LocalVideoViewDelegate
    extension CallViewController: LocalVideoViewDelegate {
    func localVideoView(_ localVideoView: LocalVideoView?, pressedSwitchButton sender: UIButton?) {
        guard let position: AVCaptureDevice.Position = cameraCapture?.position else { return }
        let newPosition: AVCaptureDevice.Position = position == .back ? .front : .back
        
        if cameraCapture?.hasCamera(for: newPosition) == true {
            
            let animation = CATransition()
            animation.duration = 0.75
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.type = CATransitionType(rawValue: "oglFlip")
            
            if position == .front {
                
                animation.subtype = .fromRight
            } else if position == .back {
                
                animation.subtype = .fromLeft
            }
            
            localVideoView?.superview?.layer.add(animation, forKey: nil)
            cameraCapture?.position = newPosition
        }
    }
}

// MARK: QBRTCAudioSessionDelegate
extension CallViewController: QBRTCAudioSessionDelegate {
    func audioSession(_ audioSession: QBRTCAudioSession, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        if didStartPlayAndRecord == false {
            return
        }
        let isSpeaker: Bool = updatedAudioDevice == QBRTCAudioDevice.speaker
        if dynamicEnable.pressed != isSpeaker {
            dynamicEnable.pressed = isSpeaker
        }
    }
    
    func audioSessionDidStartPlayOrRecord(_ audioSession: QBRTCAudioSession) {
        didStartPlayAndRecord = true
        audioSession.currentAudioDevice = QBRTCAudioDevice.speaker
    }
    
    func audioSessionDidStopPlayOrRecord(_ audioSession: QBRTCAudioSession) {
        didStartPlayAndRecord = false
    }
}

// MARK: QBRTCConferenceClientDelegate
extension CallViewController: QBRTCConferenceClientDelegate {
    func didCreateNewSession(_ session: QBRTCConferenceSession?) {
        if session == self.session {
            let audioSession = QBRTCAudioSession.instance()
            audioSession.initialize { configuration in
                // adding blutetooth support
                
                configuration.categoryOptions = .allowBluetoothA2DP
                configuration.categoryOptions = .allowBluetooth
                
                // adding airplay support
                configuration.categoryOptions = .allowAirPlay
                
                if self.session?.conferenceType == QBRTCConferenceType.video {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                }
            }
            session?.localMediaStream.audioTrack.isEnabled = !muteAudio
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
            if cameraCapture != nil {
                session?.localMediaStream.videoTrack.videoCapture = cameraCapture
            }
            
            if isListnerOnly == false {
                session?.joinAsPublisher()
            } else {
                state = CallViewControllerState.connected
                self.session?.listOnlineParticipants(completionBlock: { [weak self] publishers, listeners in
                    for userID: NSNumber in publishers {
                        self?.session?.subscribeToUser(withID: userID)
                    }
                })
            }
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, didJoinChatDialogWithID chatDialogID: String?, publishersList: [NSNumber]) {
        if session == self.session {
            state = CallViewControllerState.connected
            if publishersList.isEmpty == false {
                for userID in publishersList {
                    self.session?.subscribeToUser(withID: userID)
                    addToCollectionUser(withID: userID)
                }
            }
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, didReceiveNewPublisherWithUserID userID: NSNumber?) {
        if session == self.session {
            guard let userId = userID else {return}
            // subscribing to user to receive his media
            self.session?.subscribeToUser(withID: userId)
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, publisherDidLeaveWithUserID userID: NSNumber?) {
        if session == self.session {
            // in case we are zoomed into leaving publisher
            // cleaning it here
            if statsUserID == userID {
                unzoomVideoView()
            }
        }
    }
    
    func sessionWillClose(_ session: QBRTCConferenceSession?) {
        if session == self.session {
            if QBRTCAudioSession.instance().isInitialized {
                // deinitializing audio session if needed
                QBRTCAudioSession.instance().deinitialize()
            }
            closeCall(withTimeout: false)
        }
    }
    
    func sessionDidClose(_ session: QBRTCConferenceSession?, withTimeout timeout: Bool) {
        if session == self.session, state != CallViewControllerState.disconnected {
            closeCall(withTimeout: timeout)
        }
    }
    
    func session(_ session: QBRTCConferenceSession!, didReceiveError error: Error!) {
        SVProgressHUD.showError(withStatus: error?.localizedDescription)
    }
}

// MARK: QBRTCBaseClientDelegate
extension CallViewController: QBRTCBaseClientDelegate {
    
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        if session == self.session {
            performUpdateUserID(userID, block: { cell in
                if cell?.connectionState == QBRTCConnectionState.connected, report.videoReceivedBitrateTracker.bitrate > 0 {
                    cell?.bitrate = report.videoReceivedBitrateTracker.bitrate
                }
            })
            if (statsUserID == userID) {
                let result = report.statsString()
                debugPrint("\(result)")
                
                // send stats to stats view if needed
                if shouldGetStats {
                    statsView.setStats(result)
                    view.setNeedsLayout()
                }
            }
        }
    }
    
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        if session == self.session {
            // adding user to the collection
            addToCollectionUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        if session == self.session {
            // remove user from the collection
            removeFromCollectionUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        if session == self.session {
            performUpdateUserID(userID, block: { cell in
                cell?.connectionState = state
            })
        }
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        if session == self.session {
            performUpdateUserID(userID, block: { [weak self] cell in
                let opponentVideoView = self?.videoView(withOpponentID: userID) as? QBRTCRemoteVideoView
                cell?.videoView = opponentVideoView
            })
        }
    }
}

// MARK: UICollectionViewDataSource
extension CallViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            var cell = UICollectionViewCell()
            
            if let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier:
                CallConstants.opponentCollectionViewCellIdentifier, for: indexPath)
                as? OpponentCollectionViewCell {
                
                let user = users[indexPath.row]
                reusableCell.didPressMuteButton = { [weak self] isMuted in
                    let audioTrack: QBRTCAudioTrack? = self?.session?.remoteAudioTrack(withUserID: NSNumber(value: (user.id)))
                    audioTrack?.isEnabled = !isMuted
                }
                reusableCell.videoView = videoView(withOpponentID: NSNumber(value: (user.id)))
                if let currentUser = QBSession.current.currentUser, user.id != currentUser.id {
                    // label for user
                    let title = user.fullName ?? CallConstants.unknownUserLabel
                    reusableCell.name = title
                    reusableCell.nameColor = PlaceholderGenerator.color(for: title.count)
                    // mute button
                    reusableCell.isMuted = false
                    // state
                    reusableCell.connectionState = QBRTCConnectionState.new
                }
                cell = reusableCell
            }
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        if let currentUserID = session?.currentUserID {
            if user.id == currentUserID.uintValue {
                // do not zoom local video view
                return
            }
            
            if let videoCell = opponentsCollectionView.cellForItem(at: indexPath) as? OpponentCollectionViewCell {
                let videoView: UIView? = videoCell.videoView
                if videoView != nil {
                    videoCell.videoView = nil
                    originCell = videoCell
                    statsUserID = NSNumber(value: user.id)
                    zoomVideoView(videoView)
                }
            }
        }
    }
}


