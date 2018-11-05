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
    //MARK: - IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var toolbar: ToolBar!
    
    //MARK: - Properties
    var chatDialog: QBChatDialog?
    var conferenceType: QBRTCConferenceType?
    weak var dataSource: UsersDataSource?
    
    //MARK: - Internal Properties
    
    //Managers
    private let core = Core.instance
    private let settings = Settings.instance
    
    //Camera
    private var session: QBRTCConferenceSession?
    private var cameraCapture: QBRTCCameraCapture?
    
    //Containers
    private var users = [QBUUser]()
    private var videoViews = [UInt: UIView]()
    private var statsUserID: NSNumber?
    
    //Views
    private weak var originCell: OpponentCollectionViewCell?
    
    lazy private var dynamicButton: CustomButton = {
        let dynamicButton = ButtonsFactory.dynamicEnable()
        return dynamicButton
    }()
    
    private var localVideoView: LocalVideoView?
    
    lazy private var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()
    
    lazy private var zoomedView: ZoomedView = {
        let zoomedView = ZoomedView()
        return zoomedView
    }()
    
    private var statsItem = UIBarButtonItem(title: "Stats",
                                            style: .plain,
                                            target: self,
                                            action: #selector(didTapStats(_:)))
    
    private var addUsersItem = UIBarButtonItem(barButtonSystemItem: .add,
                                               target: self,
                                               action: #selector(didTapAddUsers(_:)))
    
    //States
    private var shouldGetStats = false
    private var didStartPlayAndRecord = false
    
    private var muteAudio = false {
        didSet {
            session?.localMediaStream.audioTrack.isEnabled = !muteAudio
        }
    }
    private var muteVideo = false {
        didSet {
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
        }
    }
    
    private var isListnerOnly: Bool {
        return conferenceType == nil
    }
    
    private var state = CallViewControllerState.connected {
        didSet {
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
    }
    
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        QBRTCConferenceClient.instance().add(self)
        QBRTCAudioSession.instance().addDelegate(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chatDialog = self.chatDialog,
            let chatDialogID = chatDialog.id,
            let currentUser = core.currentUser else {
                return
        }
        
        if isListnerOnly == false {
            users = [currentUser]
        }
        
        configureGUI()
        
        // creating session
        // when conferenceType is nil, it means that user connected to the session as a listener
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SVProgressHUD.show(withStatus: CallConstants.memoryWarning)
        state = CallViewControllerState.disconnecting
        session?.leave()
    }
    
    //MARK - Setup
    func configureGUI() {
        // when conferenceType is nil, it means that user connected to the session as a listener
        if let conferenceType = self.conferenceType {
            switch conferenceType {
            case .video:
                toolbar.add(ButtonsFactory.videoEnable(), action: { [weak self] sender in
                    if let muteVideo = self?.muteVideo {
                        self?.muteVideo = !muteVideo
                        self?.localVideoView?.isHidden = !muteVideo
                    }
                })
            case .audio:
                dynamicButton.pressed = true
                toolbar.add(dynamicButton, action: { sender in
                    let previousDevice = QBRTCAudioSession.instance().currentAudioDevice
                    let device = previousDevice == QBRTCAudioDevice.speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
                    QBRTCAudioSession.instance().currentAudioDevice = device
                })
            }
            toolbar.add(ButtonsFactory.auidoEnable(), action: { [weak self] sender in
                if let muteAudio = self?.muteAudio {
                    self?.muteAudio = !muteAudio
                }
            })
        }
        
        toolbar.updateItems()
        
        let mask: UIView.AutoresizingMask = [.flexibleWidth,
                                             .flexibleHeight,
                                             .flexibleLeftMargin,
                                             .flexibleRightMargin,
                                             .flexibleTopMargin,
                                             .flexibleBottomMargin]
        
        // zoomed view
        zoomedView.autoresizingMask = mask
        zoomedView.isHidden = false
        view.addSubview(zoomedView)
        zoomedView.didTapView = { [weak self] zoomedView in
            self?.unzoomVideoView()
        }
        // stats view
        statsView.autoresizingMask = mask
        statsView.isHidden = false
        view.addSubview(statsView)
        
        // add button to enable stats view
        state = CallViewControllerState.connecting
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Leave",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapLeave(_:)))
        navigationItem.rightBarButtonItem = addUsersItem
        
        // collection view
        collectionView.collectionViewLayout = OpponentsFlowLayout()
        collectionView.backgroundColor = UIColor(red: 0.1465, green: 0.1465, blue: 0.1465, alpha: 1.0)
        view.backgroundColor = collectionView.backgroundColor
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            self.refreshVideoViews()
        })
    }
    
    // MARK: - Prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        cameraCapture?.stopSession(nil)
        if (segue.identifier == CallConstants.usersSegue) {
            
            let usersVC = segue.destination as? AddUsersViewController
            usersVC?.usersDataSource = dataSource
            usersVC?.chatDialog = chatDialog
        }
    }
    
    // MARK: - Actions
    @objc func didTapAddUsers(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: CallConstants.usersSegue, sender: nil)
    }
    
    @objc func didTapLeave(_ sender: UIBarButtonItem) {
        state = CallViewControllerState.disconnecting
        if session?.state == QBRTCSessionState.pending {
            closeCall(withTimeout: false)
        } else if session?.state != QBRTCSessionState.new {
            SVProgressHUD.show(withStatus: nil)
        }
        session?.leave()
    }
    
    @objc func didTapStats(_ sender: UIBarButtonItem) {
        shouldGetStats = !shouldGetStats
        statsView.isHidden = !statsView.isHidden
    }
    
    //MARK: - Internal Methods
    private func zoomVideoView(_ videoView: UIView?) {
        zoomedView.videoView = videoView
        zoomedView.isHidden = false
        navigationItem.rightBarButtonItem = statsItem
    }
    
    private func unzoomVideoView() {
        guard let originCell = originCell else {
            return
        }
        originCell.videoView = zoomedView.videoView
        zoomedView.videoView = nil
        self.originCell = nil
        zoomedView.isHidden = true
        statsUserID = nil
        navigationItem.rightBarButtonItem = addUsersItem
    }
    
    private func closeCall(withTimeout timeout: Bool) {
        // removing delegate on close call so we don't get any callbacks
        // that will force collection view to perform updates
        // while controller is deallocating
        QBRTCConferenceClient.instance().remove(self)
        
        // stopping camera session
        cameraCapture?.stopSession(nil)
        
        // toolbar
        toolbar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.toolbar.alpha = 0.4
        })
        
        state = CallViewControllerState.disconnected
        
        if timeout {
            SVProgressHUD.showError(withStatus: CallConstants.conferenceDidClose)
        } else {
            // dismissing progress hud if needed
            SVProgressHUD.dismiss()
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func refreshVideoViews() {
        // resetting zoomed view
        for cell in collectionView.visibleCells {
            guard let opponentCell = cell as? OpponentCollectionViewCell,
                let videoView = opponentCell.videoView,
                videoView != zoomedView.videoView else {
                    continue
            }
            opponentCell.videoView = videoView
        }
    }
    
    private func userView(userID: UInt) -> UIView? {
        
        if let result = videoViews[userID] {
            return result
        }
        
        if core.currentUser?.id == userID,
            session?.conferenceType != QBRTCConferenceType.audio,
            let cameraCapture = self.cameraCapture {
            //Local preview
            let localVideoView = LocalVideoView(previewlayer: cameraCapture.previewLayer)
            videoViews[userID] = localVideoView
            localVideoView.delegate = self
            self.localVideoView = localVideoView
            
            return localVideoView
            
        } else if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: userID)) {
            //Opponents
            let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
            videoViews[userID] = remoteVideoView
            remoteVideoView.setVideoTrack(remoteVideoTraсk)
            
            return remoteVideoView
        }
        return nil
    }
    
    private func fetchUser(userID: UInt) -> QBUUser {
        guard let usersDataSource = dataSource,
            let user = usersDataSource.user(withID: userID) else {
                let user = QBUUser()
                user.id = userID
                return user
        }
        return user
    }
    
    private func userIndexPath(userID: UInt) -> IndexPath {
        let user = fetchUser(userID: userID)
        guard let index = users.index(of: user), index != NSNotFound else {
            return IndexPath(row: 0, section: 0)
        }
        return IndexPath(row: index, section: 0)
    }
    
    private func userCell(userID: UInt) -> OpponentCollectionViewCell? {
        let indexPath = userIndexPath(userID: userID)
        guard let cell = collectionView.cellForItem(at: indexPath) as? OpponentCollectionViewCell  else {
            return nil
        }
        return cell
    }
    
}

extension CallViewController: LocalVideoViewDelegate {
    // MARK: LocalVideoViewDelegate
    func localVideoView(_ localVideoView: LocalVideoView, pressedSwitchButton sender: UIButton?) {
        guard let cameraCapture = self.cameraCapture else {
            return
        }
        
        let newPosition: AVCaptureDevice.Position = cameraCapture.position == .back ? .front : .back
        
        guard cameraCapture.hasCamera(for: newPosition) == true else {
            return
        }
        
        let animation = CATransition()
        animation.duration = 0.75
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = CATransitionType(rawValue: "oglFlip")
        animation.subtype = cameraCapture.position == .back ? .fromLeft : .fromRight
        
        localVideoView.superview?.layer.add(animation, forKey: nil)
        cameraCapture.position = newPosition
    }
}

extension CallViewController: QBRTCAudioSessionDelegate {
    //MARK: QBRTCAudioSessionDelegate
    func audioSession(_ audioSession: QBRTCAudioSession, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        guard didStartPlayAndRecord == true else {
            return
        }
        let isSpeaker = updatedAudioDevice == QBRTCAudioDevice.speaker
        dynamicButton.pressed = isSpeaker
    }
    
    func audioSessionDidStartPlayOrRecord(_ audioSession: QBRTCAudioSession) {
        didStartPlayAndRecord = true
        audioSession.currentAudioDevice = QBRTCAudioDevice.speaker
    }
    
    func audioSessionDidStopPlayOrRecord(_ audioSession: QBRTCAudioSession) {
        didStartPlayAndRecord = false
    }
}

extension CallViewController: QBRTCConferenceClientDelegate {
    // MARK: QBRTCConferenceClientDelegate
    func didCreateNewSession(_ session: QBRTCConferenceSession?) {
        guard let session = session, session == self.session else {
            return
        }
        
        let audioSession = QBRTCAudioSession.instance()
        audioSession.initialize { configuration in
            // adding blutetooth support
            
            configuration.categoryOptions = .allowBluetoothA2DP
            configuration.categoryOptions = .allowBluetooth
            
            // adding airplay support
            configuration.categoryOptions = .allowAirPlay
            
            if session.conferenceType == QBRTCConferenceType.video {
                // setting mode to video chat to enable airplay audio and speaker only
                configuration.mode = AVAudioSession.Mode.videoChat.rawValue
            }
        }
        
        session.localMediaStream.audioTrack.isEnabled = !muteAudio
        session.localMediaStream.videoTrack.isEnabled = !muteVideo
        
        if let cameraCapture = cameraCapture {
            session.localMediaStream.videoTrack.videoCapture = cameraCapture
        }
        
        if isListnerOnly == false {
            session.joinAsPublisher()
        } else {
            state = CallViewControllerState.connected
            session.listOnlineParticipants(completionBlock: { publishers, listeners in
                for userID in publishers {
                    session.subscribeToUser(withID: userID)
                }
            })
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, didJoinChatDialogWithID chatDialogID: String?, publishersList: [NSNumber]) {
        guard let session = session, session == self.session else {
            return
        }
        state = CallViewControllerState.connected
        for userID in publishersList {
            session.subscribeToUser(withID: userID)
            addToCollectionUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, didReceiveNewPublisherWithUserID userID: NSNumber?) {
        guard let session = session, session == self.session, let userId = userID else {
            return
        }
        session.subscribeToUser(withID: userId)
    }
    
    func session(_ session: QBRTCConferenceSession?, publisherDidLeaveWithUserID userID: NSNumber?) {
        guard let session = session, session == self.session, statsUserID == userID else {
            return
        }
        unzoomVideoView()
    }
    
    func sessionWillClose(_ session: QBRTCConferenceSession?) {
        guard session == self.session else {
            return
        }
        if QBRTCAudioSession.instance().isInitialized {
            // deinitializing audio session if needed
            QBRTCAudioSession.instance().deinitialize()
        }
        closeCall(withTimeout: false)
    }
    
    func sessionDidClose(_ session: QBRTCConferenceSession?, withTimeout timeout: Bool) {
        guard session == self.session, state != CallViewControllerState.disconnected else {
            return
        }
        closeCall(withTimeout: timeout)
    }
    
    func session(_ session: QBRTCConferenceSession!, didReceiveError error: Error!) {
        SVProgressHUD.showError(withStatus: error?.localizedDescription)
    }
}

extension CallViewController: QBRTCBaseClientDelegate {
    // MARK: QBRTCBaseClientDelegate
    func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
        guard session == self.session else {
            return
        }
        
        if let cell = userCell(userID: userID.uintValue),
            cell.connectionState == .connected,
            report.videoReceivedBitrateTracker.bitrate > 0.0 {
            cell.bitrate = report.videoReceivedBitrateTracker.bitrate
        }
        
        guard statsUserID == userID, shouldGetStats == true else {
            return
        }
        
        let result = report.statsString()
        debugPrint("\(result)")
        
        statsView.updateStats(result)
        view.setNeedsLayout()
    }
    
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        // adding user to the collection
        addToCollectionUser(withID: userID)
    }
    
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        let user = fetchUser(userID: userID.uintValue)
        guard session == self.session,
            let index = users.index(of: user),
            index != NSNotFound else {
                return
        }
        
        // remove user from the collection
        let indexPath = IndexPath(item: index, section: 0)
        users.removeAll(where: { element in element == user })
        videoViews.removeValue(forKey: userID.uintValue)
        
        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.deleteItems(at: [indexPath])
            }, completion: { [weak self] _ in
                self?.refreshVideoViews()
        })
    }
    
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        guard session == self.session, let cell = userCell(userID: userID.uintValue) else {
            return
        }
        cell.connectionState = state
    }
    
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        guard session == self.session,
            let cell = userCell(userID: userID.uintValue),
            let videoView = userView(userID: userID.uintValue) as? QBRTCRemoteVideoView else {
                return
        }
        
        cell.videoView = videoView
    }
    
    //MARK: - Internal
    private func addToCollectionUser(withID userID: NSNumber) {
        let user = fetchUser(userID: userID.uintValue)
        guard users.contains(user) == false else {
            return
        }
        
        users.insert(user, at: 0)
        let indexPath = IndexPath(item: 0, section: 0)
        
        collectionView.performBatchUpdates({ [weak self] in
            self?.collectionView.insertItems(at: [indexPath])
            }, completion: { [weak self] _ in
                self?.refreshVideoViews()
        })
    }
    
}

// MARK: UICollectionViewDataSource
extension CallViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallConstants.opponentCollectionViewCellIdentifier,
                                                            for: indexPath) as? OpponentCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let user = users[indexPath.row]
        let userID =  NSNumber(value: user.id)
        
        cell.didPressMuteButton = { [weak self] isMuted in
            let audioTrack = self?.session?.remoteAudioTrack(withUserID: userID)
            audioTrack?.isEnabled = !isMuted
        }
        
        cell.videoView = userView(userID: user.id)
        
        guard let currentUser = QBSession.current.currentUser, user.id != currentUser.id else {
            return cell
        }
        
        let title = user.fullName ?? CallConstants.unknownUserLabel
        cell.name = title
        cell.nameColor = PlaceholderGenerator.color(for: title.count)
        cell.isMuted = false
        cell.connectionState = QBRTCConnectionState.new
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        guard let currentUserID = session?.currentUserID,
            user.id != currentUserID.uintValue,
            let videoCell = collectionView.cellForItem(at: indexPath) as? OpponentCollectionViewCell,
            let videoView = videoCell.videoView  else {
                return
        }
        videoCell.videoView = nil
        originCell = videoCell
        statsUserID = NSNumber(value: user.id)
        zoomVideoView(videoView)
    }
}


