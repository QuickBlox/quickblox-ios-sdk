//
//  CallViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 04.10.2018.
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
    static let didRecivePushAndOpenCallChatNotification = NSNotification.Name(rawValue: "didRecivePushAndOpenCallChatNotification")
    static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let unknownUserLabel = "Unknown user"
    static let usersSegue = "PresentUsersViewController"
    static let sharingViewControllerIdentifier = "SharingViewController"
    static let chatSegue = "SA_STR_SEGUE_GO_TO_CHAT_FROM_CALL".localized
    static let membersSegue = "SA_STR_SEGUE_GO_TO_INFO_FROM_CALL".localized
    static let hideInterval: TimeInterval = 5.0
    static let refreshTimeInterval: TimeInterval = 1.0
    
    static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call", comment: "")
    static let conferenceDidClose = NSLocalizedString("Conference did close due to time out", comment: "")
}

protocol ChildCallVCDelegate: class {
    func callVCDidClosedCallScreen(_ isClosedCall: Bool)
}

typealias CompletionBlock = (() -> Void)

class CallViewController: UIViewController, QBRTCClientDelegate {
    //MARK: - IBOutlets
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var toolbar: ToolBar!
    @IBOutlet weak var containerToolBarView: ChatGradientView!
    @IBOutlet weak var collectionViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topGradientView: ChatGradientView!
    @IBOutlet weak var timerCallLabel: UILabel!
    @IBOutlet weak var topGradientViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    private var actionCompletionBlock: CompletionBlock?
    weak var delegate: ChildCallVCDelegate?
    var dialogID: String! {
        didSet {
            self.chatDialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    private var chatDialog: QBChatDialog?
    private let conferenceType = QBRTCConferenceType.video
    private var callType: String?
    private var toolbarHideTimer: Timer?
    private var timeDuration: TimeInterval = 0.0
    private var callTimer: Timer?
    private var listenersCount = 0
    private var listenersIDs: Set<UInt> = []
    
    //MARK: - Internal Properties
    //Managers
    private let chatManager = ChatManager.instance
    private let settings = Settings()
    var callSettings: CallSettings! {
        didSet {
            if let callSettings = callSettings {
                dialogID = callSettings.chatDialogID
                callType = callSettings.callType
                initiatorID = callSettings.initiatorID
                conferenceID = callSettings.conferenceID
                isSendMessage = callSettings.isSendMessage
            }
        }
    }
    
    //Camera
    private var session: QBRTCConferenceSession?
    lazy private var cameraCapture: QBRTCCameraCapture = {
        let settings = Settings()
        let cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat,
                                               position: settings.preferredCameraPostion)
        cameraCapture.startSession(nil)
        return cameraCapture
    }()
    
    //Containers
    private var users = [ConferenceUser]()
    private var videoViews = [UInt: UIView]()
    private var usersAudioEnabled: [UInt: Bool] = [:]
    private var usersVideoEnabled: [UInt: Bool] = [:]
    private var selectedUserID: UInt?
    private var initiatorID: UInt?
    var conferenceID: String?
    private var isSendMessage = false
    
    //Views
    lazy private var streamTitleView: StreamTitleView = {
        let streamTitleView = StreamTitleView()
        return streamTitleView
    }()
    
    private var localVideoView: LocalVideoView? = nil
    
    lazy private var statsView: StatsView = {
        let statsView = StatsView()
        return statsView
    }()

    private lazy var membersItem = UIBarButtonItem(image: UIImage(named: "members_call"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(didTapMembers(_:)))

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

    private var isListnerOnly = false
    
        
    //MARK: - Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        QBRTCConferenceClient.instance().add(self)
        QBRTCAudioSession.instance().addDelegate(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: ChatViewControllerConstant.cameraEnabledMessageNotification, object: nil)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isCalling = false
        }
        debugPrint("deinit \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isCalling = true
        }
        isListnerOnly = Profile().ID != initiatorID && callType == MessageType.startStream.rawValue
        
        configureGUI()
        configureToolBar()
        setupSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(cameraEnabledNotification(_:)),
                                               name: ChatViewControllerConstant.cameraEnabledMessageNotification,
                                               object: nil)
        
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
        
        if isListnerOnly == false {
            session?.localMediaStream.videoTrack.videoCapture = cameraCapture
        }
        
        setupNavigationBarWillAppear(true)
        
        let topBarHeight = self.navigationController?.navigationBar.frame.height ?? 44.0
        collectionViewTopConstraint.constant = -topBarHeight
        showControls()
        setupHideToolbarTimerWithTimeInterval(CallConstants.hideInterval)
        
        if self.usersVideoEnabled[Profile().ID] == false, let chatDialog = self.chatDialog, let conferenceID = self.conferenceID {
            let occupantIDs = self.users.compactMap({ $0.userID })
            self.chatManager.sendMessageCameraOn(false, occupantIDs: occupantIDs, dialog: chatDialog, roomID: conferenceID)
        }
    }
    
    @objc func cameraEnabledNotification(_ notification: Notification?) {
        guard let roomID = notification?.userInfo?["roomID"] as? String,
            roomID == self.conferenceID,
            let userIDString = notification?.userInfo?["userID"] as? String,
            let userID = userIDString.toUInt(),
            let isCameraEnabledString = notification?.userInfo?["isCameraEnabled"] as? String else {return}
        let enabled = isCameraEnabledString == "1"
        usersVideoEnabled[userID] = enabled
        reloadContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reloadContent()
        
        if cameraCapture.hasStarted == false {
            // ideally you should always stop capture session
            // when you are leaving controller in any way
            // here we should get its running state back
            cameraCapture.startSession(nil)
        }
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
    
    //MARK - Setup
    private func setupSession() {
        let profile = Profile()
        guard let conferenceID = self.conferenceID,
            profile.isFull == true,
            let currentConferenceUser = Profile.currentUser() else {
                return
        }
        
        timeDuration = 0.0
        callTimer?.invalidate()
        callTimer = nil
        
        // creating session
        session = nil
        session = QBRTCConferenceClient.instance().createSession(withChatDialogID: conferenceID,
                                                                 conferenceType: .video)
        
        guard session != nil else {
            return
        }
        
        users = []
        videoViews = [:]
        usersAudioEnabled = [:]
        usersVideoEnabled = [:]
        
        if isListnerOnly == false {
            users = [currentConferenceUser]
            usersAudioEnabled[currentConferenceUser.userID] = true
            usersVideoEnabled[currentConferenceUser.userID] = true
        } else if isListnerOnly == true {
            guard let initiatorID = initiatorID, Profile().ID != initiatorID else {return}
            addToCollectionUser(withID: NSNumber(value: initiatorID))
            localVideoView = nil
        }
        
        if isListnerOnly == false {
            #if targetEnvironment(simulator)
            // Simulator
            #else
            // Device
            if cameraCapture.hasStarted == false {
                cameraCapture.startSession(nil)
            }
            #endif
        } else {
            cameraCapture.stopSession(nil)
        }
        reloadContent()
    }
    
    private func setupNavigationBarWillAppear(_ isWillAppear: Bool) {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = isWillAppear
    }
    
    func configureGUI() {
        containerToolBarView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.0), secondColor: UIColor.black.withAlphaComponent(1.0))
        topGradientView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.9), secondColor: UIColor.black.withAlphaComponent(0.0))
        if UIApplication.shared.statusBarOrientation.isLandscape {
            self.topGradientViewHeightConstraint.constant = 56.0
        } else {
            self.topGradientViewHeightConstraint.constant = 100.0
        }
        timerCallLabel.setRoundedLabel(cornerRadius: 10.0)
        
        configureNavigationBarButtonItems()
    }
    
    func configureNavigationBarButtonItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu_chat"),
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapChat(_:)))
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        if callType == MessageType.startStream.rawValue {
            navigationItem.titleView = streamTitleView
            if isListnerOnly == false {
                streamTitleView.setupStreamTitleViewOnLive(true)
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "0 members",
                                                                    style: .plain,
                                                                    target: self,
                                                                    action: nil)
                
            } else if isListnerOnly == true  {
                navigationItem.rightBarButtonItem = nil
            }
            
        } else if callType == MessageType.startConference.rawValue {
            navigationItem.titleView = nil
            title = self.chatDialog?.name
            navigationItem.rightBarButtonItem = membersItem
        }
        navigationItem.rightBarButtonItem?.tintColor = .white
    }
    
    func leaveFromCallAnimated(_ isAnimated: Bool, isSetupNewCall: Bool = false, completion:(() -> Void)? = nil) {
        if session?.state == QBRTCSessionState.pending {
            closeCall(withTimeout: false)
        } else if session?.state != .new {
            SVProgressHUD.show(withStatus: nil)
        }
        SVProgressHUD.dismiss()
        session?.leave()
        if isSetupNewCall == true {
            actionCompletionBlock = completion
        }
    }
    
    func configureToolBar() {
        // when conferenceType is nil, it means that user connected to the session as a listener
        if isListnerOnly == true, callType == MessageType.startStream.rawValue {
            self.muteAudio = true
            self.muteVideo = true
            toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                self.setupHideToolbarTimerWithTimeInterval(CallConstants.hideInterval)
                self.leaveFromCallAnimated(true)
            })
            
        } else if isListnerOnly == false {
            
            toolbar.add(ButtonsFactory.audioEnable(), action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                self.muteAudio = !self.muteAudio
                self.setupHideToolbarTimerWithTimeInterval(CallConstants.hideInterval)
            })
            
            toolbar.add(ButtonsFactory.videoEnable(), action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                
                self.muteVideo = !self.muteVideo
                
                if let chatDialog = self.chatDialog, let conferenceID = self.conferenceID {
                    let occupantIDs = self.users.compactMap({ $0.userID })
                    self.chatManager.sendMessageCameraOn(self.muteVideo == false, occupantIDs: occupantIDs, dialog: chatDialog, roomID: conferenceID)
                }
                
                self.localVideoView?.isHidden = self.muteVideo
                if self.localVideoView?.isHidden == true {
                    self.cameraCapture.stopSession(nil)
                    self.usersVideoEnabled[Profile().ID] = false
                } else if self.localVideoView?.isHidden == false {
                    self.cameraCapture.startSession(nil)
                    self.usersVideoEnabled[Profile().ID] = true
                }
                
                self.setupHideToolbarTimerWithTimeInterval(CallConstants.hideInterval)
            })
            
            toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                self.setupHideToolbarTimerWithTimeInterval(CallConstants.hideInterval)
                self.leaveFromCallAnimated(true)
            })
            
            toolbar.add(ButtonsFactory.screenShare(), action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                guard let sharingVC = self.storyboard?.instantiateViewController(withIdentifier: CallConstants.sharingViewControllerIdentifier) as? SharingViewController else {
                    return
                }
                sharingVC.session = self.session
                self.navigationController?.pushViewController(sharingVC, animated: true)
                
                if self.usersVideoEnabled[Profile().ID] == false, let chatDialog = self.chatDialog, let conferenceID = self.conferenceID {
                    let occupantIDs = self.users.compactMap({ $0.userID })
                    self.chatManager.sendMessageCameraOn(true, occupantIDs: occupantIDs, dialog: chatDialog, roomID: conferenceID)
                }
            })
            
            toolbar.add(ButtonsFactory.swapCam(), action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                
                self.setupHideToolbarTimerWithTimeInterval(CallConstants.hideInterval)
                
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
        }
        toolbar.updateItems()
    }
    
    // MARK: Transition to size
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let self = self else {return}
            self.topGradientView.layoutSubviews()
            self.containerToolBarView.layoutSubviews()
            self.reloadContent()
            
            if UIApplication.shared.statusBarOrientation.isLandscape {
                self.topGradientViewHeightConstraint.constant = 56.0
            } else {
                self.topGradientViewHeightConstraint.constant = 100.0
            }
        })
    }
    
    // MARK: - Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == CallConstants.membersSegue {
            if let chatInfoViewController = segue.destination as? UsersInfoTableViewController {
                chatInfoViewController.dialogID = self.chatDialog?.id
                chatInfoViewController.action = ChatActions.InfoFromCall
                let qbUsers = users.compactMap{ chatManager.storage.user(withID: $0.userID) }
                chatInfoViewController.users = qbUsers
                chatInfoViewController.usersAudioEnabled = usersAudioEnabled
                chatInfoViewController.didPressMuteUser = { [weak self] (isMuted, userId) in
                    let userID = NSNumber(value: userId)
                    let audioTrack = self?.session?.remoteAudioTrack(withUserID: userID)
                    audioTrack?.isEnabled = !isMuted
                    self?.usersAudioEnabled[userId] = !isMuted
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc func didTapMembers(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: CallConstants.membersSegue, sender: ChatActions.InfoFromCall)
    }
    
    @objc func didTapChat(_ sender: UIBarButtonItem) {
        delegate?.callVCDidClosedCallScreen(false)
    }
    
    func goToChatFromCall() {
        performSegue(withIdentifier: CallConstants.chatSegue, sender: ChatActions.ChatFromCall)
    }
    
    // MARK: - Helpers
    private func cancelCallAlertWith(_ title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            
            self.leaveFromCallAnimated(false, completion: nil)
        }
        alert.addAction(cancelAction)
        present(alert, animated: false) {
        }
    }
    
    //MARK: - Internal Methods
    @objc private func refreshCallTime(_ sender: Timer?) {
        timeDuration += CallConstants.refreshTimeInterval
        timerCallLabel.text = string(withTimeDuration: timeDuration)
        session?.listOnlineParticipants(completionBlock: { [weak self] publishers, listeners in
            guard let self = self else {return}
            if self.callType == MessageType.startStream.rawValue, self.isListnerOnly == false {
                let setOfNewListenersID = Set(listeners.compactMap({ $0.uintValue }))
                let newListenersID = setOfNewListenersID.subtracting(self.listenersIDs)
                if self.listenersCount != listeners.count {
                    if let isCameraEnabled = self.usersVideoEnabled[Profile().ID], let chatDialog = self.chatDialog, let conferenceID = self.conferenceID {
                        self.chatManager.sendMessageCameraOn(isCameraEnabled, occupantIDs: Array(newListenersID), dialog: chatDialog, roomID: conferenceID)
                    }
                }
                
                let members = listeners.count == 1 ? "member" : "members"
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem?.title = "\(listeners.count) " + members
                }
            }
        })
    }
    
    private func string(withTimeDuration timeDuration: TimeInterval) -> String {
        let hours = Int(timeDuration / 3600)
        let minutes = Int(timeDuration / 60)
        let seconds = Int(timeDuration) % 60
        
        var timeStr = ""
        if hours > 0 {
            let minutes = Int((timeDuration - Double(3600 * hours)) / 60);
            timeStr = "\(hours):\(minutes):\(seconds)"
        } else {
            if (seconds < 10) {
                timeStr = "\(minutes):0\(seconds)"
            } else {
                timeStr = "\(minutes):\(seconds)"
            }
        }
        return timeStr
    }
    
    private func setupHideToolbarTimerWithTimeInterval(_ timeInterval: TimeInterval) {
        invalidateHideToolbarTimer()
        self.toolbarHideTimer = Timer.scheduledTimer(timeInterval: timeInterval,
                                                     target: self,
                                                     selector: #selector(hideControls),
                                                     userInfo: nil,
                                                     repeats: false)
    }
    
    private func invalidateHideToolbarTimer() {
        if self.toolbarHideTimer != nil {
            self.toolbarHideTimer?.invalidate()
            self.toolbarHideTimer = nil
        }
    }
    
    @objc private func hideControls() {
        containerToolBarView.isHidden = true
        navigationItem.leftBarButtonItem?.tintColor = .clear
        navigationItem.rightBarButtonItem?.tintColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.clear]
        topGradientView.isHidden = true
        navigationItem.titleView?.isHidden = true
    }
    
    private func showControls() {
        if containerToolBarView.isHidden == true {
            containerToolBarView.isHidden = false
            setupHideToolbarTimerWithTimeInterval(CallConstants.hideInterval)
        }
        navigationItem.titleView?.isHidden = false
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        topGradientView.isHidden = false
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
            if $0 is CallViewController {
                navigationController.setViewControllers(newStack, animated: true)
                return
            }
        }
        
        if callTimer != nil {
            callTimer?.invalidate()
            self.callTimer = nil
        }

        QBRTCConferenceClient.instance().remove(self)
        
        // stopping camera session
        cameraCapture.stopSession(nil)
        
        invalidateHideToolbarTimer()
        
        // toolbar
        toolbar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.toolbar.alpha = 0.4
        })
        
        SVProgressHUD.dismiss()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.isCalling = false
        }
        
        if let actionCompletionBlock = self.actionCompletionBlock {
            actionCompletionBlock()
            self.actionCompletionBlock = nil
            
        } else {
            delegate?.callVCDidClosedCallScreen(true)
        }
    }
    
    private func userView(userID: UInt) -> UIView? {
        let profile = Profile()
        
        guard profile.isFull == true else {
            return nil
        }
        if let result = videoViews[userID] {
            return result
        }
        
        if profile.ID == userID, isListnerOnly == false {
            //Local preview
            let localVideoView = LocalVideoView(previewlayer: cameraCapture.previewLayer)
            videoViews[userID] = localVideoView
            self.localVideoView = localVideoView
            
            return localVideoView
        } else if let remoteVideoTraсk = session?.remoteVideoTrack(withUserID: NSNumber(value: userID)) {
            //Opponents
            let remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2.0, y: 2.0, width: 2.0, height: 2.0))
            remoteVideoView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
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
    
    private func createConferenceUser(userID: UInt) -> ConferenceUser? {
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
    
    func reloadContent() {
        videoViews.values.forEach{ $0.removeFromSuperview() }
        collectionView.reloadData()
    }
}

extension CallViewController: QBRTCAudioSessionDelegate {
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

extension CallViewController: QBRTCConferenceClientDelegate {
    // MARK: QBRTCConferenceClientDelegate
    func didCreateNewSession(_ session: QBRTCConferenceSession?) {
        guard let session = session,
            session == self.session,
            let conferenceID = self.conferenceID,
            let callType = self.callType,
            let chatDialog = self.chatDialog else {
                return
        }
        if let callTimer = callTimer {
            callTimer.invalidate()
            self.callTimer = nil
        }
        
        timeDuration = 0.0
        
        let audioSession = QBRTCAudioSession.instance()
        audioSession.initialize { configuration in
            // adding blutetooth support
            
            configuration.categoryOptions = .allowBluetoothA2DP
            configuration.categoryOptions = .allowBluetooth
            
            // adding airplay support
            configuration.categoryOptions = .allowAirPlay
            
            configuration.mode = AVAudioSession.Mode.videoChat.rawValue
        }
        
        if isSendMessage == true {
            chatManager.setDialogOnCall(chatDialog, callType: callType, conferenceID: conferenceID)
        }
        
        session.listOnlineParticipants(completionBlock: { [weak self] publishers, listeners in
            
            if self?.isListnerOnly == true {
                for userID in publishers {
                    session.subscribeToUser(withID: userID)
                }
                DispatchQueue.main.async {
                    self?.streamTitleView.setupStreamTitleViewOnLive(publishers.isEmpty == false)
                }
            }
        })
        
        if isListnerOnly == false {
            session.localMediaStream.audioTrack.isEnabled = true
            session.localMediaStream.videoTrack.isEnabled = true
            session.localMediaStream.videoTrack.videoCapture = cameraCapture
            session.joinAsPublisher()
        }
        
        callTimer = Timer.scheduledTimer(timeInterval: 2,
                                         target: self,
                                         selector: #selector(refreshCallTime(_:)),
                                         userInfo: nil,
                                         repeats: true)
    }
    
    func session(_ session: QBRTCConferenceSession?, didJoinChatDialogWithID chatDialogID: String?,
                 publishersList: [NSNumber]) {
        guard let session = session, session == self.session else {
            return
        }
        if let isCameraEnabled = usersVideoEnabled[Profile().ID],
            let chatDialog = self.chatDialog,
            let conferenceID = self.conferenceID {
            let occupantIDs = publishersList.compactMap({ $0.uintValue })
            self.chatManager.sendMessageCameraOn(isCameraEnabled, occupantIDs: occupantIDs, dialog: chatDialog, roomID: conferenceID)
        }
        for userID in publishersList {
            if Profile().ID != userID.uintValue {
                session.subscribeToUser(withID: userID)
            }
            addToCollectionUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, didReceiveNewPublisherWithUserID userID: NSNumber?) {
        guard let session = session, session == self.session, let userId = userID else {
            return
        }
        if Profile().ID != userID?.uintValue {
            session.subscribeToUser(withID: userId)
        }
        if let isCameraEnabled = usersVideoEnabled[Profile().ID],
            let chatDialog = self.chatDialog,
            let conferenceID = self.conferenceID {
            let occupantIDs = [userId.uintValue]
            self.chatManager.sendMessageCameraOn(isCameraEnabled, occupantIDs: occupantIDs, dialog: chatDialog, roomID: conferenceID)
        }
        if isListnerOnly == true {
            DispatchQueue.main.async {
                self.streamTitleView.setupStreamTitleViewOnLive(true)
                self.showControls()
            }
        }
        
        reloadContent()
    }
    
    func session(_ session: QBRTCConferenceSession?, publisherDidLeaveWithUserID userID: NSNumber?) {
        guard let session = session, session == self.session,
            let userID = userID else {
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

extension CallViewController: QBRTCBaseClientDelegate {
    // MARK: QBRTCBaseClientDelegate
    func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        // adding user to the collection
        if isListnerOnly == false {
            addToCollectionUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCBaseSession, connectionClosedForUser userID: NSNumber) {
        guard session == self.session else {
            return
        }
        // remove user from the collection
        if let index = users.index(where: { $0.userID == userID.uintValue }) {
            if isListnerOnly == false {
                users.remove(at: index)
            } else {
                DispatchQueue.main.async {
                    self.streamTitleView.setupStreamTitleViewOnLive(false)
                    self.showControls()
                }
            }
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
        if let user = createConferenceUser(userID: userID.uintValue) {
            users.insert(user, at: 0)
            usersAudioEnabled[userID.uintValue] = true
            usersAudioEnabled[userID.uintValue] = true
            reloadContent()
        } else {
            chatManager.loadUser(userID.uintValue, completion: { [weak self] (user) in
                if let user = self?.createConferenceUser(userID: userID.uintValue) {
                    self?.users.insert(user, at: 0)
                    self?.usersAudioEnabled[userID.uintValue] = true
                    self?.usersAudioEnabled[userID.uintValue] = true
                    self?.reloadContent()
                }
            })
        }
    }
}

extension CallViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if selectedUserID != nil || isListnerOnly == true {
            return 1
        }
        return users.count
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
        
        if let isMute = usersAudioEnabled[user.userID] {
            cell.unMute = isMute
        }
        if let videoEnabled = usersVideoEnabled[user.userID] {
            cell.videoEnabled = videoEnabled
        }
        cell.userColor = user.userID.generateColor()
        cell.name = user.userName
        
        return cell
    }
}

extension CallViewController: UICollectionViewDelegate {
    // MARK: UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showControls()
        let user = users[indexPath.row]
        guard let currentUserID = session?.currentUserID,
            user.userID != currentUserID.uintValue else {
                return
        }
        if isListnerOnly == false {
            selectedUserID == nil ? zoomUser(userID: user.userID) : unzoomUser()
        }
    }
}
