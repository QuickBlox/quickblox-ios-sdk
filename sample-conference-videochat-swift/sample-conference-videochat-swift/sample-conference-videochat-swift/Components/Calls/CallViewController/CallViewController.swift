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

class CallViewController: UIViewController {
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
    private var users = [ConferenceUser]()
    private var videoViews = [UInt: UIView]()
    private var selectedUserID: UInt?
    
    //Views
    
    lazy private var dynamicButton: CustomButton = {
        let dynamicButton = ButtonsFactory.dynamicEnable()
        return dynamicButton
    }()
    
    private var localVideoView: LocalVideoView?
    
    lazy private var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()
    
    private lazy var statsItem = UIBarButtonItem(title: "Stats",
                                                 style: .plain,
                                                 target: self,
                                                 action: #selector(didTapStats(_:)))
    
    private lazy var addUsersItem = UIBarButtonItem(barButtonSystemItem: .add,
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
            let currentConferenceUser = ConferenceUser(user: currentUser)
            users = [currentConferenceUser]
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
            cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat,
                                               position: settings.preferredCameraPostion)
            cameraCapture?.startSession(nil)
            #endif
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadContent()
        
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
        
        // stats view
        statsView.frame = view.bounds
        statsView.autoresizingMask = mask
        statsView.isHidden = true
        view.addSubview(statsView)
        
        // add button to enable stats view
        state = CallViewControllerState.connecting
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Leave",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapLeave(_:)))
        navigationItem.rightBarButtonItem = addUsersItem
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { [weak self] context in
            self?.reloadContent()
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
    private func zoomUser(userID: UInt) {
        selectedUserID = userID
        reloadContent()
        navigationItem.rightBarButtonItem = statsItem
    }
    
    private func unzoomUser() {
        selectedUserID = nil
        navigationItem.rightBarButtonItem = addUsersItem
        reloadContent()
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
    
    private func userCell(userID: UInt) -> ConferenceUserCell? {
        let indexPath = userIndexPath(userID: userID)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConferenceUserCell  else {
            return nil
        }
        return cell
    }

    private func createConferenceUser(userID: UInt) -> ConferenceUser {
        guard let usersDataSource = dataSource,
            let user = usersDataSource.user(withID: userID) else {
                let user = QBUUser()
                user.id = userID
                return ConferenceUser(user: user)
        }
        return ConferenceUser(user: user)
    }
    
    private func userIndexPath(userID: UInt) -> IndexPath {
        guard let index = users.index(where: { $0.userID == userID }), index != NSNotFound else {
            return IndexPath(row: 0, section: 0)
        }

        return IndexPath(row: index, section: 0)
    }

    func reloadContent() {
        videoViews.values.forEach{ $0.removeFromSuperview() }
        collectionView.reloadData()
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
    
    func session(_ session: QBRTCConferenceSession?, didJoinChatDialogWithID chatDialogID: String?,
                 publishersList: [NSNumber]) {
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
        guard let session = session, session == self.session,
            let userID = userID,
            let selectedUserID = selectedUserID,
            selectedUserID == userID.uintValue else {
            return
        }
        self.selectedUserID = nil
        reloadContent()
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
        guard session == self.session,
            let user = users.filter({ $0.userID == userID.uintValue }).first  else {
            return
        }
        
        if user.connectionState == .connected,
            report.videoReceivedBitrateTracker.bitrate > 0.0 {
            user.bitrate = report.videoReceivedBitrateTracker.bitrate
        }
        
        reloadContent()

        guard let selectedUserID = selectedUserID,
            selectedUserID == userID.uintValue,
            shouldGetStats == true else {
            return
        }

        let result = report.statsString()
        debugPrint("\(result)")

        statsView.updateStats(result)
    }
    
    
    
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        // adding user to the collection
        addToCollectionUser(withID: userID)
    }
    
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        // remove user from the collection
        if let index = users.index(where: { $0.userID == userID.uintValue }) {
            users.remove(at: index)
        }
        
        if let videoView = videoViews[userID.uintValue] {
            videoView.removeFromSuperview()
            videoViews.removeValue(forKey: userID.uintValue)
        }
        reloadContent()
    }
    
    func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
        guard session == self.session, let index = users.index(where: { $0.userID == userID.uintValue }) else {
            return
        }
        let user = users[index]
        user.connectionState = state
        reloadContent()
    }
    
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        guard session == self.session else {
                return
        }
        reloadContent()
    }
    
    //MARK: - Internal
    private func addToCollectionUser(withID userID: NSNumber) {
        guard users.contains(where: { $0.userID == userID.uintValue }) == false else {
            return
        }
        let user = createConferenceUser(userID: userID.uintValue)
        users.insert(user, at: 0)
        reloadContent()
    }
    
}

extension CallViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUserID != nil ? 1 : users.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallConstants.opponentCollectionViewCellIdentifier,
                                                            for: indexPath) as? ConferenceUserCell else {
            return UICollectionViewCell()
        }
        
        var index = indexPath.row
        if let selectedUserID = selectedUserID {
            let selectedIndexPath = userIndexPath(userID: selectedUserID)
            index = selectedIndexPath.row
        }
        
        let user = users[index]
        let userID = NSNumber(value: user.userID)
        
        cell.didPressMuteButton = { [weak self] isMuted in
            let audioTrack = self?.session?.remoteAudioTrack(withUserID: userID)
            audioTrack?.isEnabled = !isMuted
        }
        
        cell.videoView = userView(userID: user.userID)
        
        cell.name = ""
        cell.connectionState = user.connectionState
        
        guard let currentUser = QBSession.current.currentUser, user.userID != currentUser.id else {
            return cell
        }
        
        let title = user.userName
        cell.name = title
        
        return cell
    }
}

extension CallViewController: UICollectionViewDelegate {
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        guard let currentUserID = session?.currentUserID,
            user.userID != currentUserID.uintValue else {
                return
        }
        selectedUserID == nil ? zoomUser(userID: user.userID) : unzoomUser()
    }
}
