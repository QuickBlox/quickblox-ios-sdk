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

struct CallConstants {
    static let kOpponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
    static let kUnknownUserLabel = "Unknown user"
    static let kUsersSegue = "PresentUsersViewController"
}

//class CallViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCAudioSessionDelegate, QBRTCConferenceClientDelegate, LocalVideoViewDelegate {

class CallViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, QBRTCAudioSessionDelegate, QBRTCConferenceClientDelegate {
    
    var chatDialog: QBChatDialog?
    var conferenceType: QBRTCConferenceType?
    weak var usersDataSource: UsersDataSource?
    private weak var session: QBRTCConferenceSession?
    @IBOutlet private weak var opponentsCollectionView: UICollectionView!
    @IBOutlet private weak var toolbar: QBToolBar!
    private var users: [QBUUser] = []
    private var cameraCapture: QBRTCCameraCapture?
    private var videoViews: [AnyHashable : Any] = [:]
    private var dynamicEnable: QBButton?
    private var videoEnabled: QBButton?
    private var audioEnabled: QBButton?
    private weak var localVideoView: LocalVideoView?
    private var statsView: StatsView?
    private var shouldGetStats = false
    private var statsUserID: NSNumber?
    private var zoomedView: ZoomedView?
    private weak var originCell: OpponentCollectionViewCell?
    private var state: CallViewControllerState?
    private var muteAudio = false
    private var muteVideo = false
    private var statsItem: UIBarButtonItem?
    private var addUsersItem: UIBarButtonItem?
    
    private var didStartPlayAndRecord = false
    
    let core = QBCore.instance
    
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
        
        // creating session
        session = QBRTCConferenceClient.instance().createSession(withChatDialogID: chatDialog?.id ?? "", conferenceType: Int(conferenceType!.rawValue) > 0 ? conferenceType! : QBRTCConferenceType.video)
        
        if Int(conferenceType!.rawValue) > 0 {
            users = [core.currentUser]
        } else {
            users = [AnyHashable]()
        }
        
        if session?.conferenceType == QBRTCConferenceType.video && Int(conferenceType!.rawValue) > 0 {
            #if !(TARGET_IPHONE_SIMULATOR)
            let settings = Settings.instance
            cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat!, position: settings.preferredCameraPostion!)
            cameraCapture?.startSession(nil)
            #endif
        }
        
        configureGUI()
        
        opponentsCollectionView.backgroundColor = UIColor(red: 0.1465, green: 0.1465, blue: 0.1465, alpha: 1.0)
        view.backgroundColor = opponentsCollectionView.backgroundColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SVProgressHUD.show(withStatus: "MEMORY WARNING: leaving out of call")
        state = CallViewControllerState.disconnecting
        session?.leave()
    }
    
    func configureGUI() {
        
        weak var weakSelf = self
        
        if session?.conferenceType == QBRTCConferenceType.video && Int(conferenceType!.rawValue) > 0 {
            videoEnabled = QBButtonsFactory.videoEnable()
            toolbar.add(videoEnabled, action: { sender in
                
                weakSelf?.muteVideo = true
                weakSelf?.localVideoView?.isHidden = (weakSelf?.muteVideo)!
            })
        }
        
        if Int(conferenceType!.rawValue) > 0 {
            audioEnabled = QBButtonsFactory.auidoEnable()
            toolbar.add(audioEnabled, action: { sender in
                
                weakSelf?.muteAudio = true
            })
        }
        
        if session?.conferenceType == QBRTCConferenceType.audio {
            
            dynamicEnable = QBButtonsFactory.dynamicEnable()
            dynamicEnable?.pressed = true
            toolbar.add(dynamicEnable, action: { sender in
                
                let device: QBRTCAudioDevice = QBRTCAudioSession.instance().currentAudioDevice
                
                QBRTCAudioSession.instance().currentAudioDevice = device == QBRTCAudioDevice.speaker ? QBRTCAudioDevice.receiver : QBRTCAudioDevice.speaker
            })
        }
        
        toolbar.updateItems()
        
        // zoomed view
        zoomedView = prepareSubview(view: view, subviewClass: ZoomedView.self) as? ZoomedView
        zoomedView?.didTapView = { zoomedView in
            weakSelf?.unzoomVideoView()
        }
        // stats view
        statsView = prepareSubview(view: view, subviewClass: StatsView.self) as? StatsView
        
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
        
        if cameraCapture != nil && !(cameraCapture?.hasStarted)! {
            // ideally you should always stop capture session
            // when you are leaving controller in any way
            // here we should get its running state back
            cameraCapture?.startSession(nil)
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: CallConstants.kOpponentCollectionViewCellIdentifier, for: indexPath) as? OpponentCollectionViewCell
        
        let user: QBUUser? = users[indexPath.row]
        weak var weakSelf = self
        reusableCell?.didPressMuteButton = { isMuted in
            let audioTrack: QBRTCAudioTrack? = weakSelf.session.remoteAudioTrack(withUserID: user?.id)
            audioTrack?.enabled = !isMuted
        }
        
        reusableCell?.videoView = videoView(withOpponentID: user?.id)
        
        if user?.id != QBSession.current().isCurrentUser.id {
            // label for user
            let title = user?.fullName ?? kUnknownUserLabel
            reusableCell?.name = title
            reusableCell?.nameColor = PlaceholderGenerator.color(for: title)
            // mute button
            reusableCell?.isMuted = false
            // state
            reusableCell?.connectionState = QBRTCConnectionStateNew
        }
        
        return reusableCell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let user: QBUUser? = users[indexPath.item]
        if user?.id == session.currentUserID {
            // do not zoom local video view
            return
        }
        
        let videoCell = opponentsCollectionView.cellForItem(at: indexPath) as? OpponentCollectionViewCell
        let videoView: UIView? = videoCell?.videoView
        
        if videoView != nil {
            videoCell?.videoView = nil
            originCell = videoCell
            statsUserID = user?.id
            zoomVideoView(videoView)
        }
    }
    
    // MARK: Transition to size
    func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            
            self.refreshVideoViews()
            
        })
    }
    
    // MARK: QBRTCBaseClientDelegate
    func session(_ session: QBRTCBaseSession?, updatedStatsReport report: QBRTCStatsReport?, forUserID userID: NSNumber?) {
        
        if session == self.session {
            
            performUpdateUserID(userID, block: { cell in
                if cell?.connectionState == QBRTCConnectionStateConnected && report?.videoReceivedBitrateTracker.bitrate ?? 0 > 0 {
                    cell?.bitrate = report?.videoReceivedBitrateTracker.bitrate
                }
            })
            
            if (statsUserID == userID) {
                
                let result = report?.statsString()
                print("\(result ?? "")")
                
                // send stats to stats view if needed
                if shouldGetStats {
                    
                    statsView.stats = result
                    view.setNeedsLayout()
                }
            }
        }
    }
    
    func session(_ session: QBRTCBaseSession?, startedConnectingToUser userID: NSNumber?) {
        
        if session == self.session {
            // adding user to the collection
            addToCollectionUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCBaseSession?, connectionClosedForUser userID: NSNumber?) {
        
        if session == self.session {
            // remove user from the collection
            removeFromCollectionUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCBaseSession?, didChange state: QBRTCConnectionState, forUser userID: NSNumber?) {
        
        if session == self.session {
            
            performUpdateUserID(userID, block: { cell in
                cell?.connectionState = state
            })
        }
    }
    
    func session(_ session: QBRTCBaseSession?, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack?, fromUser userID: NSNumber?) {
        
        if session == self.session {
            
            weak var weakSelf = self
            performUpdateUserID(userID, block: { cell in
                let opponentVideoView = weakSelf.videoView(withOpponentID: userID) as? QBRTCRemoteVideoView
                cell?.videoView = opponentVideoView
            })
        }
    }
    
    // MARK: QBRTCConferenceClientDelegate
    
    func didCreateNewSession(_ session: QBRTCConferenceSession?) {
        
        if session == self.session {
            
            let audioSession = QBRTCAudioSession.instance()
            audioSession.initialize(withConfigurationBlock: { configuration in
                // adding blutetooth support
                configuration?.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetooth
                configuration?.categoryOptions |= AVAudioSessionCategoryOptionAllowBluetoothA2DP
                
                // adding airplay support
                configuration?.categoryOptions |= AVAudioSessionCategoryOptionAllowAirPlay
                
                if self.session.conferenceType == QBRTCConferenceTypeVideo {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration?.mode = AVAudioSession.Mode.videoChat
                }
            })
            
            session?.localMediaStream.audioTrack.enabled = !muteAudio
            session?.localMediaStream.videoTrack.enabled = !muteVideo
            
            if cameraCapture != nil {
                session?.localMediaStream.videoTrack.videoCapture = cameraCapture
            }
            
            if conferenceType > 0 {
                session?.joinAsPublisher()
            } else {
                state = CallViewControllerStateConnected
                weak var weakSelf = self
                self.session.listOnlineParticipants(withCompletionBlock: { publishers, listeners in
                    for userID: NSNumber in publishers {
                        weakSelf.session.subscribeToUser(withID: userID)
                    }
                })
            }
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, didJoinChatDialogWithID chatDialogID: String?, publishersList: [Any]?) {
        
        if session == self.session {
            
            state = CallViewControllerStateConnected
            for userID: NSNumber? in publishersList as? [NSNumber?] ?? [] {
                self.session.subscribeToUser(withID: userID)
                addToCollectionUser(withID: userID)
            }
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, didReceiveNewPublisherWithUserID userID: NSNumber?) {
        
        if session == self.session {
            
            // subscribing to user to receive his media
            self.session.subscribeToUser(withID: userID)
        }
    }
    
    func session(_ session: QBRTCConferenceSession?, publisherDidLeaveWithUserID userID: NSNumber?) {
        
        if session == self.session {
            
            // in case we are zoomed into leaving publisher
            // cleaning it here
            if (statsUserID == userID) {
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
        
        if session == self.session && state != CallViewControllerStateDisconnected {
            
            closeCall(withTimeout: timeout)
        }
    }
    
    func session(_ session: QBRTCConferenceSession?) throws {
        SVProgressHUD.showError(withStatus: error?.localizedDescription)
    }
    
    // MARK: QBRTCAudioSessionDelegate
    func audioSession(_ audioSession: QBRTCAudioSession?, didChangeCurrentAudioDevice updatedAudioDevice: QBRTCAudioDevice) {
        
        if !didStartPlayAndRecord {
            return
        }
        
        let isSpeaker: Bool = updatedAudioDevice == QBRTCAudioDeviceSpeaker
        if dynamicEnable.pressed != isSpeaker {
            
            dynamicEnable.pressed = isSpeaker
        }
    }
    
    func audioSessionDidStartPlayOrRecord(_ audioSession: QBRTCAudioSession?) {
        didStartPlayAndRecord = true
        audioSession?.currentAudioDevice = QBRTCAudioDeviceSpeaker
    }
    
    func audioSessionDidStopPlayOrRecord(_ audioSession: QBRTCAudioSession?) {
        didStartPlayAndRecord = false
    }
    
    // MARK: Overrides
    func setState(_ state: CallViewControllerState) {
        
        if self.state != state {
            switch state {
            case CallViewControllerStateDisconnected:
                title = "Disconnected"
            case CallViewControllerStateConnecting:
                title = "Connecting..."
            case CallViewControllerStateConnected:
                title = "Connected"
            case CallViewControllerStateDisconnecting:
                title = "Disconnecting..."
            default:
                break
            }
            
            self.state = state
        }
    }
    
    func setMuteAudio(_ muteAudio: Bool) {
        
        if self.muteAudio != muteAudio {
            self.muteAudio = muteAudio
            session.localMediaStream.audioTrack.enabled = !muteAudio
        }
    }
    
    func setMuteVideo(_ muteVideo: Bool) {
        
        if self.muteVideo != muteVideo {
            self.muteVideo = muteVideo
            session.localMediaStream.videoTrack.enabled = !muteVideo
        }
    }
    
    // MARK: Actions
    @objc func pushAddUsersToRoomScreen() {
        performSegue(withIdentifier: kUsersSegue, sender: nil)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        cameraCapture.stopSession(nil)
        if (segue.identifier == kUsersSegue) {
            
            let usersVC = segue.destination as? AddUsersViewController
            usersVC?.usersDataSource = usersDataSource
            usersVC?.chatDialog = chatDialog
        }
    }
    
    func zoomVideoView(_ videoView: UIView?) {
        zoomedView.videoView = videoView
        zoomedView.hidden = false
        navigationItem?.rightBarButtonItem = statsItem
    }
    
    func unzoomVideoView() {
        if originCell != nil {
            originCell.videoView = zoomedView.videoView
            zoomedView.videoView = nil
            originCell = nil
            zoomedView.hidden = true
            statsUserID = nil
            navigationItem?.rightBarButtonItem = addUsersItem
        }
    }
    
    func addToCollectionUser(withID userID: NSNumber?) {
        
        let user: QBUUser? = self.user(withID: userID)
        if let anUser = user {
            if users.index(of: anUser) != NSNotFound {
                return
            }
        }
        if let anUser = user {
            users.insert(anUser, at: 0)
        }
        let indexPath = IndexPath(item: 0, section: 0)
        
        weak var weakSelf = self
        opponentsCollectionView.performBatchUpdates({
            
            weakSelf.opponentsCollectionView.insertItems(at: [indexPath])
            
        }) { finished in
            
            weakSelf.refreshVideoViews()
        }
        
    }
    
    func removeFromCollectionUser(withID userID: NSNumber?) {
        
        let user: QBUUser? = self.user(withID: userID)
        var index: Int? = nil
        if let anUser = user {
            index = users.index(of: anUser)
        }
        if index == NSNotFound {
            return
        }
        let indexPath = IndexPath(item: index ?? 0, section: 0)
        users.removeAll(where: { element in element == user })
        videoViews.removeValueForKey(userID)
        
        weak var weakSelf = self
        opponentsCollectionView.performBatchUpdates({
            
            weakSelf.opponentsCollectionView.deleteItems(at: [indexPath])
            
        }) { finished in
            
            weakSelf.refreshVideoViews()
        }
    }
    
    func closeCall(withTimeout timeout: Bool) {
        
        // removing delegate on close call so we don't get any callbacks
        // that will force collection view to perform updates
        // while controller is deallocating
        QBRTCConferenceClient.instance().removeDelegate(self)
        
        // stopping camera session
        cameraCapture.stopSession(nil)
        
        // toolbar
        toolbar.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.toolbar.alpha = 0.4
        })
        
        state = CallViewControllerStateDisconnected
        
        if timeout {
            SVProgressHUD.showError(withStatus: "Conference did close due to time out")
            navigationController?.popToRootViewController(animated: true)
        } else {
            // dismissing progress hud if needed
            navigationController?.popToRootViewController(animated: true)
            SVProgressHUD.dismiss()
        }
    }
    
    @objc func leaveFromRoom() {
        state = CallViewControllerStateDisconnecting
        if session.state == QBRTCSessionStatePending {
            closeCall(withTimeout: false)
        } else if session.state != QBRTCSessionStateNew {
            SVProgressHUD.show(withStatus: nil)
        }
        session.leave()
    }
    
    @inline(__always) private func prepareSubview(view: UIView?, subviewClass: AnyClass) -> UIView? {
        
        let subview = subviewClass(frame: view?.bounds ?? CGRect.zero) as? UIView
        subview?.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        subview?.isHidden = true
        if let aSubview = subview {
            view?.addSubview(aSubview)
        }
        return subview
    }
    
    func refreshVideoViews() {
        
        // resetting zoomed view
        let zoomedVideoView: UIView? = zoomedView.videoView
        for viewToRefresh: OpponentCollectionViewCell in opponentsCollectionView.visibleCells {
            let view: UIView? = viewToRefresh.videoView
            if view == zoomedVideoView {
                continue
            }
            
            viewToRefresh.videoView = nil
            viewToRefresh.videoView = view
        }
    }
    
    @objc func updateStatsView() {
        shouldGetStats ^= 1
        statsView.hidden ^= 1
    }
    
    func videoView(withOpponentID opponentID: NSNumber?) -> UIView? {
        
        if !videoViews {
            videoViews = [AnyHashable : Any]()
        }
        
        var result: Any? = nil
        if let anID = opponentID {
            result = videoViews[anID]
        }
        
        if Core.currentUser.id == Int(opponentID ?? 0) && session.conferenceType != QBRTCConferenceTypeAudio {
            //Local preview
            
            if result == nil {
                
                let localVideoView = LocalVideoView(previewlayer: cameraCapture.previewLayer)
                if let anID = opponentID {
                    videoViews[anID] = localVideoView
                }
                localVideoView.delegate = self
                self.localVideoView = localVideoView
                
                return localVideoView
            }
        } else {
            //Opponents
            
            var remoteVideoView: QBRTCRemoteVideoView? = nil
            let remoteVideoTraсk: QBRTCVideoTrack? = session.remoteVideoTrack(withUserID: opponentID)
            
            if result == nil && remoteVideoTraсk != nil {
                
                remoteVideoView = QBRTCRemoteVideoView(frame: CGRect(x: 2, y: 2, width: 2, height: 2))
                remoteVideoView?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                if let anID = opponentID {
                    videoViews[anID] = remoteVideoView
                }
                remoteVideoView?.videoTrack = remoteVideoTraсk
                result = remoteVideoView
            }
            
            return result as? UIView
        }
        
        return result as? UIView
    }
    
    func user(withID userID: NSNumber?) -> QBUUser? {
        
        var user: QBUUser? = usersDataSource.user(withID: UInt(userID ?? 0))
        
        if user == nil {
            user = QBUUser()
            user?.id = UInt(userID ?? 0)
        }
        
        return user
    }
    
    func indexPath(atUserID userID: NSNumber?) -> IndexPath? {
        
        let user: QBUUser? = self.user(withID: userID)
        var idx: Int? = nil
        if let anUser = user {
            idx = users.index(of: anUser)
        }
        let indexPath = IndexPath(row: idx ?? 0, section: 0)
        
        return indexPath
    }
    
    func performUpdateUserID(_ userID: NSNumber?, block: @escaping (_ cell: OpponentCollectionViewCell?) -> Void) {
        
        let indexPath: IndexPath? = self.indexPath(atUserID: userID)
        let cell = opponentsCollectionView.cellForItem(at: indexPath) as? OpponentCollectionViewCell
        block(cell)
    }
    
    func localVideoView(_ localVideoView: LocalVideoView?, pressedSwitch sender: UIButton?) {
        
        let position: AVCaptureDevice.Position = cameraCapture.position
        let newPosition: AVCaptureDevice.Position = position == .back ? .front : .back
        
        if cameraCapture.hasCamera(for: newPosition) {
            
            let animation = CATransition.animation()
            animation.duration = 0.75
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.type = CATransitionType("oglFlip")
            
            if position == .front {
                
                animation.subtype = .fromRight
            } else if position == .back {
                
                animation.subtype = .fromLeft
            }
            
            localVideoView?.superview.layer.add(animation, forKey: nil)
            cameraCapture.position = newPosition
        }
    }
}
