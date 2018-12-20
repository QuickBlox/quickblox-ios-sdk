//
//  CallViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/18/18.
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

struct CallConstant {
  static let opponentCollectionViewCellIdentifier = "OpponentCollectionViewCellIdentifier"
  static let unknownUserLabel = "Unknown user"
  static let sharingViewControllerIdentifier = "SharingViewController"
  static let refreshTimeInterval: TimeInterval = 1.0
  static let recordingTitle = "[Recording] "
  
  static let memoryWarning = NSLocalizedString("MEMORY WARNING: leaving out of call", comment: "")
  static let conferenceDidClose = NSLocalizedString("Conference did close due to time out", comment: "")
  static let savingRecord = NSLocalizedString("Saving record", comment: "")
}

class CallViewController: UIViewController, UICollectionViewDelegateFlowLayout {
  //MARK: - IBOutlets
  @IBOutlet private weak var opponentsCollectionView: UICollectionView!
  @IBOutlet private weak var toolbar: ToolBar!
  
  //MARK: - Properties
  weak var usersDataSource: UsersDataSource?
  
  //MARK: - Internal Properties
  
  private var timeDuration: TimeInterval = 0.0
  
  private var callTimer: Timer?
  private var beepTimer: Timer?
  
  //Managers
  private let core = Core.instance
  private let settings = Settings.instance
  
  //Camera
  var session: QBRTCSession?
  var callUUID: UUID?
  private var cameraCapture: QBRTCCameraCapture?
  
  //Containers
  private var users = [ConferenceUser]()
  private var videoViews = [UInt: UIView]()
  private var statsUserID: UInt?
  
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
                                               action: #selector(updateStatsView))
  
  
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
    QBRTCClient.instance().add(self as QBRTCClientDelegate)
    QBRTCAudioSession.instance().addDelegate(self)
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
    debugPrint("deinit \(self)")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    guard let currentUser = core.currentUser else {
      return
    }
    
    let currentConferenceUser = ConferenceUser(user: currentUser)
    users = [currentConferenceUser]
    
    let audioSession = QBRTCAudioSession.instance()
    if audioSession.isInitialized == false {
      audioSession.initialize { configuration in
        // adding blutetooth support
        configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowBluetooth)
        configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowBluetoothA2DP)
        // adding airplay support
        configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowAirPlay)
        
        guard let session = self.session else { return }
        if session.conferenceType == QBRTCConferenceType.video {
          // setting mode to video chat to enable airplay audio and speaker only
          configuration.mode = AVAudioSession.Mode.videoChat.rawValue
        }
      }
    }
    
    configureGUI()
    
    guard let session = self.session else { return }
    if session.conferenceType == QBRTCConferenceType.video {
      #if targetEnvironment(simulator)
      // Simulator
      #else
      // Device
      cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat,
                                         position: settings.preferredCameraPostion)
      cameraCapture?.startSession(nil)
      session.localMediaStream.videoTrack.videoCapture = cameraCapture
      #endif
    }
    
    opponentsCollectionView.collectionViewLayout = OpponentsFlowLayout()
    opponentsCollectionView.backgroundColor = UIColor(red: 0.1465,
                                                      green: 0.1465,
                                                      blue: 0.1465,
                                                      alpha: 1.0)
    view.backgroundColor = opponentsCollectionView.backgroundColor
    
    var conferenceUsers = [ConferenceUser]()
    conferenceUsers.insert(currentConferenceUser, at: 0)
    for uID in session.opponentsIDs {
      if currentConferenceUser.userID == uID.uintValue {
        let initiator = createConferenceUser(userID: session.initiatorID.uintValue)
        conferenceUsers.insert(initiator, at: 0)
        continue
      }
      
      let user = createConferenceUser(userID: uID.uintValue)
      conferenceUsers.insert(user, at: 0)
    }
    
    self.users = conferenceUsers
    
    let isInitiator = currentConferenceUser.userID == session.initiatorID.uintValue
    if isInitiator == true {
      startCall()
    } else {
      acceptCall()
    }
    
    title = CallStateConstant.connecting
    
    if CallKitManager.isCallKitAvailable() == true,
      session.initiatorID.uintValue == currentUser.id {
      CallKitManager.instance.updateCall(with: callUUID, connectingAt: Date())
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    reloadContent()
    
    if cameraCapture?.hasStarted == false {
      // ideally you should always stop capture session
      // when you are leaving controller in any way
      // here we should get its running state back
      cameraCapture = QBRTCCameraCapture(videoFormat: settings.videoFormat,
                                         position: settings.preferredCameraPostion)
      cameraCapture?.startSession(nil)
      session?.localMediaStream.videoTrack.videoCapture = cameraCapture
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    SVProgressHUD.show(withStatus: CallConstant.memoryWarning)
    state = CallViewControllerState.disconnecting
    //        session?.leave()
  }
  
  //MARK - Setup
  func configureGUI() {
    // when conferenceType is nil, it means that user connected to the session as a listener
    if let conferenceType = session?.conferenceType {
      switch conferenceType {
      case .video:
        toolbar.add(ButtonsFactory.videoEnable(), action: { [weak self] sender in
          if let muteVideo = self?.muteVideo {
            self?.muteVideo = !muteVideo
            self?.localVideoView?.isHidden = !muteVideo
          }
        })
        toolbar.add(ButtonsFactory.screenShare(), action: { [weak self] sender in
          guard let sharingVC = self?.storyboard?.instantiateViewController(withIdentifier: CallConstant.sharingViewControllerIdentifier) as? SharingViewController else {
            return
          }
          sharingVC.session = self?.session
          
          // put camera capture on pause
          self?.cameraCapture?.stopSession(nil)
          self?.navigationController?.pushViewController(sharingVC, animated: true)
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
      toolbar.add(ButtonsFactory.decline(), action: { [weak self] sender in
        self?.callTimer?.invalidate()
        self?.session?.hangUp(["hangup": "hang up"])
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
    statsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(updateStatsState)))
    view.addSubview(statsView)
    
    // add button to enable stats view
    state = .connecting
  }
  
  // MARK: Transition to size
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    coordinator.animate(alongsideTransition: { [weak self] context in
      self?.reloadContent()
    })
  }
  
  // MARK: - Actions
  func startCall() {
    //Begin play calling sound
    beepTimer = Timer.scheduledTimer(timeInterval: QBRTCConfig.dialingTimeInterval(),
                                     target: self,
                                     selector: #selector(playCallingSound(_:)),
                                     userInfo: nil, repeats: true)
    playCallingSound(nil)
    //Start call
    let userInfo = ["name": "Test", "url": "http.quickblox.com", "param": "\"1,2,3,4\""]
    
    session?.startCall(userInfo)
  }
  
  func acceptCall() {
    
    SoundManager.instance.stopAllSounds()
    //Accept call
    let userInfo = ["acceptCall": "userInfo"]
    session?.acceptCall(userInfo)
  }
  
  
  @objc func updateStatsView() {
    shouldGetStats = !shouldGetStats
    statsView.isHidden = !statsView.isHidden
  }
  
  @objc func updateStatsState() {
    updateStatsView()
  }
  
  //MARK: - Internal Methods
  private func zoomUser(userID: UInt) {
    statsUserID = userID
    reloadContent()
    navigationItem.rightBarButtonItem = statsItem
  }
  
  private func unzoomUser() {
    statsUserID = nil
    reloadContent()
    navigationItem.rightBarButtonItem = nil
  }
  
  private func closeCall(withTimeout timeout: Bool) {
    // removing delegate on close call so we don't get any callbacks
    // that will force collection view to perform updates
    // while controller is deallocating
    QBRTCClient.instance().remove(self as QBRTCClientDelegate)
    
    // stopping camera session
    cameraCapture?.stopSession(nil)
    
    // toolbar
    toolbar.isUserInteractionEnabled = false
    UIView.animate(withDuration: 0.5, animations: { [weak self] in
      self?.toolbar.alpha = 0.4
    })
    
    state = .disconnected
    
    if timeout {
      SVProgressHUD.showError(withStatus: CallConstant.conferenceDidClose)
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
      session?.conferenceType != .audio,
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
    guard let cell = opponentsCollectionView.cellForItem(at: indexPath) as? ConferenceUserCell  else {
      return nil
    }
    return cell
  }
  
  private func createConferenceUser(userID: UInt) -> ConferenceUser {
    guard let usersDataSource = self.usersDataSource,
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
    opponentsCollectionView.reloadData()
  }
  
  // MARK: - Timers actions
  
  @objc func playCallingSound(_ sender: Any?) {
    SoundManager.playCallingSound()
  }
  
  @objc func refreshCallTime(_ sender: Timer?) {
    
    timeDuration += CallConstant.refreshTimeInterval
    title = "Call time - \(String(describing: string(withTimeDuration: timeDuration)))"
  }
  
  func string(withTimeDuration timeDuration: TimeInterval) -> String {
    
    let minutes = Int(timeDuration / 60)
    let seconds = Int(timeDuration) % 60
    
    let timeStr = "\(minutes):\(seconds)"
    
    return timeStr
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
    let isSpeaker = updatedAudioDevice == QBRTCAudioDevice.speaker
    dynamicButton.pressed = isSpeaker
  }
}

extension CallViewController: QBRTCClientDelegate {
  // MARK: QBRTCClientDelegate
  func session(_ session: QBRTCBaseSession, updatedStatsReport report: QBRTCStatsReport, forUserID userID: NSNumber) {
    guard let session = session as? QBRTCSession,
      session == self.session,
      let user = users.filter({ $0.userID == userID.uintValue }).first else {
        return
    }
    
    if user.connectionState == .connected,
      report.videoReceivedBitrateTracker.bitrate > 0.0 {
      user.bitrate = report.videoReceivedBitrateTracker.bitrate
    }
    
    reloadContent()
    
    guard let selectedUserID = statsUserID,
      selectedUserID == userID.uintValue,
      shouldGetStats == true else {
        return
    }
    let result = report.statsString()
    statsView.updateStats(result)
  }
  
  /**
   *  Called in case when connection state changed
   */
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
  
  /**
   *  Called in case when connection state changed
   */
  func session(_ session: QBRTCBaseSession, didChange state: QBRTCConnectionState, forUser userID: NSNumber) {
    guard let session = session as? QBRTCSession,
      session == self.session, let index = users.index(where: { $0.userID == userID.uintValue }) else {
        return
    }
    let user = users[index]
    user.connectionState = state
    reloadContent()
  }
  
  /**
   *  Called in case when receive remote video track from opponent
   */
  func session(_ session: QBRTCBaseSession,
               receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack,
               fromUser userID: NSNumber) {
    guard let session = session as? QBRTCSession,
      session == self.session else {
        return
    }
    reloadContent()
  }
  
  func sessionDidClose(_ session: QBRTCSession) {
    
    if session == self.session {
      if CallKitManager.isCallKitAvailable() == true {
        CallKitManager.instance.endCall(with: callUUID) {
          debugPrint("endCall")
        }
      }
      cameraCapture?.stopSession(nil)
      
      let audioSession = QBRTCAudioSession.instance()
      if audioSession.isInitialized == true,
        audioSession.audioSessionIsActivatedOutside(AVAudioSession.sharedInstance()) == false {
        debugPrint("Deinitializing QBRTCAudioSession in CallViewController.")
        audioSession.deinitialize()
      }
      
      if let beepTimer = beepTimer {
        beepTimer.invalidate()
        self.beepTimer = nil
        SoundManager.instance.stopAllSounds()
      }
      
      if let callTimer = callTimer {
        callTimer.invalidate()
        self.callTimer = nil
      }
      
      toolbar.isUserInteractionEnabled = false
      UIView.animate(withDuration: 0.5) {
        self.toolbar.alpha = 0.4
      }
      
      title = "End - \(string(withTimeDuration: timeDuration))"
    }
  }
  
  /**
   *  Called in case when connection is established with opponent
   */
  func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
    guard let session = session as? QBRTCSession,
      session == self.session else {
        return
    }
    
    if let beepTimer = beepTimer {
      beepTimer.invalidate()
      self.beepTimer = nil
      SoundManager.instance.stopAllSounds()
    }
    
    if callTimer == nil {
      
      if CallKitManager.isCallKitAvailable(),
        let currentUser = core.currentUser,
        session.initiatorID.uintValue == currentUser.id {
        CallKitManager.instance.updateCall(with: callUUID, connectedAt: Date())
      }
      
      callTimer = Timer.scheduledTimer(timeInterval: CallConstant.refreshTimeInterval,
                                       target: self,
                                       selector: #selector(refreshCallTime(_:)),
                                       userInfo: nil,
                                       repeats: true)
    }
  }
}

extension CallViewController: UICollectionViewDataSource {
  // MARK: UICollectionViewDataSource
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if session?.conferenceType == QBRTCConferenceType.audio {
      return users.count
    } else {
      return statsUserID != nil ? 1 : users.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CallConstant.opponentCollectionViewCellIdentifier,
                                                        for: indexPath) as? ConferenceUserCell else {
                                                          return UICollectionViewCell()
    }
    
    var index = indexPath.row
    if session?.conferenceType == QBRTCConferenceType.video {
      if let selectedUserID = statsUserID {
        let selectedIndexPath = userIndexPath(userID: selectedUserID)
        index = selectedIndexPath.row
      }
    }
    
    let user = users[index]
    let userID = NSNumber(value: user.userID)
    
    cell.didPressMuteButton = { [weak self] isMuted in
      let audioTrack = self?.session?.remoteAudioTrack(withUserID: userID)
      audioTrack?.isEnabled = !isMuted
    }
    
    cell.videoView = userView(userID: user.userID)
    
    cell.name = ""
    
    guard let currentUser = QBSession.current.currentUser, user.userID != currentUser.id else {
      return cell
    }
    
    if user.bitrate > 0.0 {
      cell.bitrate = user.bitrate
    } else {
      cell.connectionState = user.connectionState
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
    guard let session = session else {
      return
    }
    if session.conferenceType == QBRTCConferenceType.audio {
      // just show stats on click if in audio call
      statsUserID = user.userID
      updateStatsView()
    } else {
      statsUserID == nil ? zoomUser(userID: user.userID) : unzoomUser()
    }
  }
}
