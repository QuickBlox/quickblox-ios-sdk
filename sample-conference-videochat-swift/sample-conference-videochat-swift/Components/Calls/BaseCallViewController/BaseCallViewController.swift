//
//  BaseCallViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 17.08.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import SVProgressHUD

//The Model for setup CallViewController
struct ConferenceSettings {
    var conferenceInfo: ConferenceInfo
    var isSendMessage: Bool
}

//The Model for sending data about the created conference
struct ConferenceInfo {
    var callType: String
    var chatDialogID: String
    var conferenceID: String
    var initiatorID: UInt
}

struct CallConstants {
    static let unknownUserLabel = "Unknown user"
    static let memoryWarning = "MEMORY WARNING: leaving out of call"
    static let conferenceDidClose = "Conference did close due to time out"
}

typealias CompletionBlock = (() -> Void)

protocol BaseCallViewControllerDelegate: class {
    func callVC(_ callVC: BaseCallViewController, didAddNewPublisher userID: UInt)
}

class BaseCallViewController: BaseViewController, QBRTCClientDelegate, ConferenceView {
    //Views
    var localVideoView: LocalVideoView? = nil
    
    //Buttons
    lazy var swapCamera: CustomButton = {
        let swapCamera = ButtonsFactory.swapCam()
        return swapCamera
    }()
    
    lazy private var videoEnabled: CustomButton = {
        let videoEnabled = ButtonsFactory.videoEnable()
        return videoEnabled
    }()
    
    lazy private var screenShareEnabled: CustomButton = {
        let screenShareEnabled = ButtonsFactory.screenShare()
        return screenShareEnabled
    }()
    
    //MARK: - Properties
    var conferenceSettings: ConferenceSettings
    var session: QBRTCConferenceSession?
    weak var callViewControllerDelegate: BaseCallViewControllerDelegate?
    var didClosedCallScreen: ((Bool) -> Void)?
    
    //Containers
    var users: [ConferenceUser] = []
    var videoViews: [UInt: UIView] = [:]
    
    //MARK: - Internal Properties
    private var selectedUserID: UInt?
    private var closeCallActionCompletion: CompletionBlock?
    private let conferenceType = QBRTCConferenceType.video
    private let settings = Settings()
    private var didStartPlayAndRecord = false
    
    //Audio/Video on/Off
    var muteAudio = false {
        didSet {
            session?.localMediaStream.audioTrack.isEnabled = !muteAudio
        }
    }
    
    var muteVideo = true {
        didSet {
            session?.localMediaStream.videoTrack.isEnabled = !muteVideo
            swapCamera.isUserInteractionEnabled = !muteVideo
        }
    }
    
    //Managers
    let chatManager = ChatManager.instance
    
    //Camera
    lazy var cameraCapture: QBRTCCameraCapture = {
        let settings = Settings()
        let cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat,
                                               position: settings.preferredCameraPostion)
        return cameraCapture
    }()
    
    //MARK: - Life Cycle
    init(conferenceSettings: ConferenceSettings) {
        self.conferenceSettings = conferenceSettings
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        debugPrint("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureGUI()
        setupSession()

        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                               object: nil,
                                               queue: nil) { [weak self] (notification) in
            guard let self = self else { return }
            self.camera(turn: !self.muteVideo)
            self.reloadContent()
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                               object: nil,
                                               queue: OperationQueue.main) { [weak self] (notification) in
            guard let self = self,
                  let session = self.session else { return }
            session.localMediaStream.videoTrack.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupDelegates()
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { status in
            let notConnection = status == .notConnection
            if notConnection == true {
                debugPrint("[CallViewController] status == .notConnection")
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        
        setupLocalMediaStreamVideoCapture()
        session?.localMediaStream.videoTrack.isEnabled = !muteVideo
        setupNavigationBarWillAppear(true)
        screenShareEnabled.pressed = false
        showControls(true)
        setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadContent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupNavigationBarWillAppear(false)
        invalidateHideToolbarTimer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SVProgressHUD.show(withStatus: CallConstants.memoryWarning)
        leaveFromCallAnimated(false)
    }
    
    //MARK: - These methods can be overridden in child controllers
    override func setupCollectionView() {
        collectionView.collectionViewLayout = OpponentsFlowLayout()
        collectionView.register(UINib(nibName: ConferenceUserCellConstant.reuseIdentifier, bundle: nil),
                                forCellWithReuseIdentifier: ConferenceUserCellConstant.reuseIdentifier)

    }
    
    func setupLocalMediaStreamVideoCapture() {
        session?.localMediaStream.videoTrack.videoCapture = cameraCapture
    }
    
    func setupDelegates() {
        QBRTCConferenceClient.instance().add(self)
        QBRTCAudioSession.instance().addDelegate(self)
    }
    
    func setupSession() {
        // creating session
        let conferenceID = conferenceSettings.conferenceInfo.conferenceID
        session = QBRTCConferenceClient.instance().createSession(withChatDialogID: conferenceID,
                                                                 conferenceType: .video)
        
        guard session != nil, let currentConferenceUser = createConferenceUser(userID: Profile().ID) else {
            return
        }
        
        users = [currentConferenceUser]
    }
    
    func setupAudioVideoEnabledCell(_ cell: ConferenceUserCell, forUserID userID: UInt) {
        // configure it if necessary. for example see ConferenceViewController
    }
    
    func removeUserFromCollection(_ userID: NSNumber) {
        // configure it if necessary
    }
    
    override func configureToolBar() {
        toolbar.add(ButtonsFactory.audioEnable(), action: { [weak self] sender in
            guard let self = self else {
                return
            }
            self.muteAudio = !self.muteAudio
            self.setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
        })
        
        muteVideo = true
        toolbar.add(videoEnabled, action: { [weak self] sender in
            guard let self = self else {
                return
            }
            self.camera(turn: self.muteVideo)
            self.setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
        })
        videoEnabled.pressed = true
        
        toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
            guard let self = self else {
                return
            }
            self.setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
            self.leaveFromCallAnimated(true)
        })
        
        toolbar.add(screenShareEnabled, action: { [weak self] sender in
            guard let self = self else {
                return
            }
            
            guard let sharingVC = ScreenFactory().makeSharingOutput() as? SharingViewController else {
                return
            }
            
            sharingVC.session = self.session
            
            let os = ProcessInfo().operatingSystemVersion
            switch (os.majorVersion, os.minorVersion, os.patchVersion) {
            case (let x, let y, let z) where x < 13 || x == 13 && y < 2 && z < 3:
                if self.cameraCapture.hasStarted == false {
                    self.cameraCapture.startSession(nil)
                }
                sharingVC.isReplayKit = false
                self.navigationController?.pushViewController(sharingVC, animated: true)
            default:
                let alertSharingVC = UIAlertController(title: "Use ReplayKit to sharing screen?", message: nil, preferredStyle: .actionSheet)
                let useReplayKitAction = UIAlertAction(title: "Use ReplayKit", style: .default, handler: { action in
                    if self.cameraCapture.hasStarted == false {
                        self.cameraCapture.startSession(nil)
                    }
                    sharingVC.isReplayKit = true
                    self.navigationController?.pushViewController(sharingVC, animated: true)
                })
                let useOldStyleAction = UIAlertAction(title: "Use Old Style", style: .default, handler: { action in
                    if self.cameraCapture.hasStarted == false {
                        self.cameraCapture.startSession(nil)
                    }
                    sharingVC.isReplayKit = false
                    self.navigationController?.pushViewController(sharingVC, animated: true)
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                    self.screenShareEnabled.pressed = false
                }
                alertSharingVC.addAction(useReplayKitAction)
                alertSharingVC.addAction(useOldStyleAction)
                alertSharingVC.addAction(cancelAction)
                if UIDevice.current.userInterfaceIdiom == .pad, let popoverController = alertSharingVC.popoverPresentationController {
                    popoverController.permittedArrowDirections = .init(rawValue: 0)
                    popoverController.sourceView = self.view
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                }
                self.present(alertSharingVC, animated: true)
            }
        })
        
        toolbar.add(swapCamera, action: { [weak self] sender in
            guard let self = self else {
                return
            }
            self.setupHideToolbarTimerWithTimeInterval(BaseConstant.hideInterval)
            guard let localVideoView = self.localVideoView else {
                return
            }
            let newPosition: AVCaptureDevice.Position = self.cameraCapture.position == .back ? .front : .back
            guard self.cameraCapture.hasCamera(for: newPosition) == true else {
                return
            }
            let animation = CATransition()
            animation.duration = 0.75
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.type = CATransitionType(rawValue: "oglFlip")
            animation.subtype = self.cameraCapture.position == .back ? .fromLeft : .fromRight
            
            localVideoView.superview?.layer.add(animation, forKey: nil)
            self.cameraCapture.position = newPosition
        })
        toolbar.updateItems()
    }
    
    func updateUIWithCreatedNewSession(_ session: QBRTCConferenceSession) {
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
        session.localMediaStream.videoTrack.videoCapture = cameraCapture
        session.localMediaStream.videoTrack.isEnabled = false
        session.joinAsPublisher()
    }
    
    func addNewPublisher(_ user: ConferenceUser) {
        users.insert(user, at: 0)
        reloadContent()
    }
    
    // MARK: - Actions
    @objc func didTapChat(_ sender: UIBarButtonItem) {
        session?.localMediaStream.videoTrack.isEnabled = false
        didClosedCallScreen?(false)
    }
    
    // MARK: - Helpers
    private func cancelCallAlertWith(_ title: String) {
        let alert = UIAlertController(title: "Error from server!!!", message: title, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            
            self.leaveFromCallAnimated(false, completion: nil)
        }
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    //MARK: - Public Methods
    func camera(turn:Bool) {
        // localMediaStream videoTrack set to Enable/disable
        // stop/start cammera session
        // update user states updateUserStates
        // send trakcs States
        #if targetEnvironment(simulator)
        // Simulator
        #else
        //Device
        if turn == true, cameraCapture.hasStarted == false {
            cameraCapture.startSession(nil)
        }
        self.muteVideo = !turn
        self.localVideoView?.isHidden = !turn
        
        #endif
    }
    
    @objc func cameraCaptureStopSession() {
        session?.localMediaStream.videoTrack.isEnabled = false
    }
    
    override func reloadContent() {
        videoViews.values.forEach{ $0.removeFromSuperview() }
        collectionView.reloadData()
    }
    
    func addToCollectionUser(withID userID: NSNumber) {
        guard users.contains(where: { $0.userID == userID.uintValue }) == false else {
            return
        }
        if let user = createConferenceUser(userID: userID.uintValue) {
            addNewPublisher(user)
        }
    }
    
    func userView(userID: UInt) -> UIView? {
        if session?.currentUserID.uintValue == userID {
            //Local preview
            if let result = videoViews[userID] {
                return result
            }
            let localVideoView = LocalVideoView(previewlayer: cameraCapture.previewLayer)
            videoViews[userID] = localVideoView
            self.localVideoView = localVideoView
            
            return localVideoView
        } else
        if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: userID)) {
            //Opponents
            if let remoteVideoView = videoViews[userID] as? QBRTCRemoteVideoView {
                remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
                videoViews[userID] = remoteVideoView
                remoteVideoView.setVideoTrack(remoteVideoTraсk)
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
    
    func leaveFromCallAnimated(_ isAnimated: Bool, completion:(() -> Void)? = nil) {
        if completion != nil {
            closeCallActionCompletion = completion
        }
        if session?.state == QBRTCSessionState.pending {
            closeCall(withTimeout: false)
        } else if session?.state != .new {
            SVProgressHUD.show(withStatus: nil)
        }
        SVProgressHUD.dismiss()
        session?.leave()
    }
    
    private func zoomUser(userID: UInt) {
        selectedUserID = userID
        reloadContent()
    }
    
    private func unzoomUser() {
        selectedUserID = nil
        reloadContent()
    }
    
    private func closeCall(withTimeout timeout: Bool) {
        // removing delegate on close call so we don't get any callbacks
        // that will force collection view to perform updates
        // while controller is deallocating
        guard let navigationController = navigationController else {
            return
        }
        let controllers = navigationController.viewControllers
        var newStack = [UIViewController]()
        
        //change stack by replacing view controllers after CallViewController
        controllers.forEach{
            newStack.append($0)
            if $0 is BaseCallViewController {
                navigationController.setViewControllers(newStack, animated: true)
                return
            }
        }
        
        QBRTCConferenceClient.instance().remove(self)
        
        // stopping camera session
        cameraCapture.stopSession(nil)
        
        invalidateHideToolbarTimer()
        
        // toolbar
        toolbar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.toolbar.alpha = 0.3
        })
        
        SVProgressHUD.dismiss()
        session = nil
        
        if let closeCallActionCompletion = self.closeCallActionCompletion {
            closeCallActionCompletion()
            self.closeCallActionCompletion = nil
            
        } else {
            didClosedCallScreen?(true)
        }
    }
    
    
    private func userCell(userID: UInt) -> ConferenceUserCell? {
        let indexPath = userIndexPath(userID: userID)
        guard let cell = collectionView.cellForItem(at: indexPath) as? ConferenceUserCell  else {
            return nil
        }
        return cell
    }
    
    func createConferenceUser(userID: UInt) -> ConferenceUser? {
        guard let user = chatManager.storage.user(withID: userID) else {
            return nil
        }
        return ConferenceUser(user: user)
    }
    
    private func userIndexPath(userID: UInt) -> IndexPath {
        guard let index = users.index(where: { $0.userID == userID }), index != NSNotFound else {
            return IndexPath(row: 0, section: 0)
        }
        return IndexPath(row: index, section: 0)
    }
}

extension BaseCallViewController: QBRTCAudioSessionDelegate {
    //MARK: QBRTCAudioSessionDelegate
    func audioSession(_ audioSession: QBRTCAudioSession, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        guard didStartPlayAndRecord == true else {
            return
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

extension BaseCallViewController: QBRTCConferenceClientDelegate {
    // MARK: QBRTCConferenceClientDelegate
    func didCreateNewSession(_ session: QBRTCConferenceSession?) {
        guard let session = session,
              session == self.session else {
            return
        }
        if conferenceSettings.isSendMessage == true {
            chatManager.sendStartConferenceMessage(conferenceSettings.conferenceInfo) { (error) in
                if let error = error {
                    debugPrint("[BaseCallViewController] sendStartCallMessage error: \(error.localizedDescription)")
                }
            }
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
        
        // updated UI with Created New Session
        updateUIWithCreatedNewSession(session)
    }
    
    func session(_ session: QBRTCConferenceSession?, didJoinChatDialogWithID chatDialogID: String?,
                 publishersList: [NSNumber]) {
        guard let session = session, session == self.session else {
            return
        }
        
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
        addToCollectionUser(withID: userId)
    }
    
    func session(_ session: QBRTCConferenceSession?, publisherDidLeaveWithUserID userID: NSNumber?) {
        guard let session = session, session == self.session, let userID = userID else {
            return
        }
        if let selectedUserID = self.selectedUserID,
           selectedUserID == userID.uintValue {
            self.selectedUserID = nil
        }
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
        guard session == self.session else {
            return
        }
        closeCall(withTimeout: timeout)
    }
    
    func session(_ session: QBRTCConferenceSession!, didReceiveError error: Error!) {
        cancelCallAlertWith(error?.localizedDescription ?? "Error!!!!")
    }
}

extension BaseCallViewController: QBRTCBaseClientDelegate {
    // MARK: QBRTCBaseClientDelegate
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        // configure it if necessary. for example see ConferenceViewController
    }
    
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        // remove user from the collection
        removeUserFromCollection(userID)
        
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
    }
    
    func session(_ session: QBRTCBaseSession,
                 receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
                 fromUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        reloadContent()
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedUserID != nil {
            return 1
        }
        return users.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ConferenceUserCellConstant.reuseIdentifier,
                                                            for: indexPath) as? ConferenceUserCell else {
            return UICollectionViewCell()
        }
        
        var index = indexPath.row
        if let selectedUserID = selectedUserID {
            let selectedIndexPath = userIndexPath(userID: selectedUserID)
            index = selectedIndexPath.row
        }
        
        let user = users[index]
        
        cell.videoView = userView(userID: user.userID)
        
        cell.didChangeVideoGravity = { [weak self] isResizeAspect in
            guard self != nil else {return}
            if isResizeAspect == true {
                if let cellVideoView = cell.videoView as? QBRTCRemoteVideoView {
                    UIView.animate(withDuration: TimeInterval(CustomButtonConstants.animationLength),
                                   delay: 0.0,
                                   options: .curveEaseIn,
                                   animations: { [weak self] in
                                    guard self != nil else { return }
                                    cellVideoView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
                                   })
                }
            } else {
                if let cellVideoView = cell.videoView as? QBRTCRemoteVideoView {
                    UIView.animate(withDuration: TimeInterval(CustomButtonConstants.animationLength),
                                   delay: 0.0,
                                   options: .curveEaseIn,
                                   animations: { [weak self] in
                                    guard self != nil else { return }
                                    cellVideoView.videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
                                   })
                }
            }
        }
        
        cell.videoEnabled = true
        // configure it if necessary. for example see ConferenceViewController
        setupAudioVideoEnabledCell(cell, forUserID: user.userID)
        
        cell.userColor = user.userID.generateColor()
        cell.name = user.userName
        
        return cell
    }

    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showControls(true)
        let user = users[indexPath.row]
        if user.userID == Profile().ID {
            return
        }
        selectedUserID == nil ? zoomUser(userID: user.userID) : unzoomUser()
    }
}
