//
//  CallViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

import Quickblox
import QuickbloxWebRTC
import SVProgressHUD

class CallViewController: UIViewController, QBRTCClientDelegate {
    
    let kDefBgClr = UIColor(red: 0.8118, green: 0.8118, blue: 0.8118, alpha: 1.0)
    var kSelectedBgClr: UIColor = UIColor(red: 0.3843, green: 0.3843, blue: 0.3843, alpha: 1.0)
    
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIBarButtonItem!
    @IBOutlet weak var screenShareBtn: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    
    open var opponets: [QBUUser]?
    open var currentUser: QBUUser?
    
    var videoCapture: QBRTCCameraCapture!
    var session: QBRTCSession?
    
    @IBOutlet weak var toolbar: UIView!
    
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QBRTCClient.initializeRTC()
        QBRTCClient.instance().add(self)
        
        cofigureVideo()
        configureAudio()
        
        self.title = self.currentUser?.login
        self.navigationItem.setHidesBackButton(true, animated:true)
        
        self.screenShareBtn.isHidden = true
        self.endBtn.isHidden = true
        self.toolbar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.resumeVideoCapture()
    }
    
    //MARK: WebRTC configuration
    
    func cofigureVideo() {
        
        QBRTCConfig.mediaStreamConfiguration().videoCodec = .H264
        
        let videoFormat = QBRTCVideoFormat()
        videoFormat.frameRate = 21
        videoFormat.pixelFormat = .format420f
        videoFormat.width = 640
        videoFormat.height = 480
        
        self.videoCapture = QBRTCCameraCapture(videoFormat: videoFormat, position: .front)
        self.videoCapture.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.videoCapture.startSession {
            
            let localView = LocalVideoView(withPreviewLayer:self.videoCapture.previewLayer)
            self.stackView.addArrangedSubview(localView)
        }
    }
    
    func configureAudio() {
        
        QBRTCConfig.mediaStreamConfiguration().audioCodec = .codecOpus
        //Save current audio configuration before start call or accept call
        QBRTCAudioSession.instance().initialize()
        QBRTCAudioSession.instance().currentAudioDevice = .speaker
        //OR you can initialize audio session with a specific configuration
        QBRTCAudioSession.instance().initialize { (configuration: QBRTCAudioSessionConfiguration) -> () in

            var options = configuration.categoryOptions
            if #available(iOS 10.0, *) {
                options = options.union(AVAudioSessionCategoryOptions.allowBluetoothA2DP)
                options = options.union(AVAudioSessionCategoryOptions.allowAirPlay)
            } else {
                options = options.union(AVAudioSessionCategoryOptions.allowBluetooth)
            }
            
            configuration.categoryOptions = options
            configuration.mode = AVAudioSessionModeVideoChat
        }
        
    }
    
    //MARK: Actions

    @IBAction func didPressCamSwitchButton(_ sender: UIButton) {
        switchButton(button: sender)
        
        self.session?.localMediaStream.videoTrack.isEnabled = !(self.session?.localMediaStream.videoTrack.isEnabled)!
    }
    
    @IBAction func didPressMicSwitchButton(_ sender: UIButton) {
        switchButton(button: sender)
        
        self.session?.localMediaStream.audioTrack.isEnabled = !(self.session?.localMediaStream.audioTrack.isEnabled)!
    }
    
    @IBAction func didPressDynamicButton(_ sender: UIButton) {
        switchButton(button: sender)
        
        let device = QBRTCAudioSession.instance().currentAudioDevice;
        
        if device == .speaker {
            QBRTCAudioSession.instance().currentAudioDevice = .receiver
        }
        else {
            QBRTCAudioSession.instance().currentAudioDevice = .speaker
        }
    }
    
    @IBAction func didPressCameraRotationButton(_ sender: UIButton) {
        switchButton(button: sender)
        
        let position = self.videoCapture.position
        if position == .back {
            self.videoCapture.position = .front
        }
        else {
            self.videoCapture.position = .back
        }
    }
    
    @IBAction func didPressLogout(_ sender: Any) {
        self.logout()
    }
    
    @IBAction func didPressCall(_ sender: UIButton) {
        
        sender.isHidden = true
        self.endBtn.isHidden = false
        self.toolbar.isHidden = false
        self.logoutBtn.isEnabled = false
        let ids = self.opponets?.map({$0.id})
        self.session = QBRTCClient.instance().createNewSession(withOpponents: ids! as [NSNumber],
                                                              with: .video)
        self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
        self.session?.startCall(["info" : "user info"])
    }
    
    @IBAction func didPressEnd(_ sender: UIButton) {
        
        if self.session != nil {
            self.session?.hangUp(nil)
        }
    }
    
    @IBAction func didPressScreenShare(_ sender: UIButton) {
        self.videoCapture.stopSession(nil)
        self.performSegue(withIdentifier: "ScreenShareViewController", sender: self.session)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let screenShareVC = segue.destination as! ScreenShareViewController
        screenShareVC.session = sender as? QBRTCSession
    }
    
    func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        
        if self.session == nil {
            self.session = session
            handleIncomingCall()
        }
    }
    
    func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        
        if (session as! QBRTCSession).id == self.session?.id {
            if session.conferenceType == QBRTCConferenceType.video {
                self.screenShareBtn.isHidden = false
            }
        }
    }
    
    func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        
        if session.id == self.session?.id {
            
            self.removeRemoteView(with: userID.uintValue)
            if userID == session.initiatorID {
                self.session?.hangUp(nil)
            }
        }
    }
    
    func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        
        if (session as! QBRTCSession).id == self.session?.id {
            
            let remoteView :QBRTCRemoteVideoView = QBRTCRemoteVideoView()
            remoteView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
            remoteView.clipsToBounds = true
            remoteView.setVideoTrack(videoTrack)
            remoteView.tag = userID.intValue
            self.stackView.addArrangedSubview(remoteView)
        }
    }
    
    func sessionDidClose(_ session: QBRTCSession) {
        
        if session.id == self.session?.id {
            self.callBtn.isHidden = false
            self.endBtn.isHidden = true
            self.toolbar.isHidden = true
            self.logoutBtn.isEnabled = true
            self.screenShareBtn.isHidden = true
            let ids = self.opponets?.map({$0.id})
            for userID in ids! {
                self.removeRemoteView(with: userID)
            }
            self.session = nil
        }
    }
    
    //MARK: Helpers
    
    func switchButton(button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            button.backgroundColor = kSelectedBgClr
        }
        else {
            button.backgroundColor = kDefBgClr
        }
    }
    
    func resumeVideoCapture() {
        // ideally you should always stop capture session
        // when you are leaving controller in any way
        // here we should get its running state back
        if self.videoCapture != nil && !self.videoCapture.hasStarted {
            self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
            self.videoCapture.startSession(nil)
        }
    }
    
    func removeRemoteView(with userID: UInt) {
        
        for view in self.stackView.arrangedSubviews {
            if view.tag == userID {
                self.stackView.removeArrangedSubview(view)
            }
        }
    }
    
    func handleIncomingCall() {
        
        let alert = UIAlertController(title: "Incoming video call", message: "Accept ?", preferredStyle: .actionSheet)
        
        let accept = UIAlertAction(title: "Accept", style: .default) { action in
            self.session?.localMediaStream.videoTrack.videoCapture = self.videoCapture
            self.session?.acceptCall(nil)
            self.callBtn.isHidden = true
            self.endBtn.isHidden = false
            self.toolbar.isHidden = false
            self.logoutBtn.isEnabled = false
        }
        
        let reject = UIAlertAction(title: "Reject", style: .default) { action in
            self.session?.rejectCall(nil)
        }
        
        alert.addAction(accept)
        alert.addAction(reject)
        self.present(alert, animated: true)
    }
    
    func logout() {
        
        SVProgressHUD.show(withStatus: "Logout")
        QBChat.instance.disconnect { (err) in
            QBRequest .logOut(successBlock: { (r) in
                SVProgressHUD.dismiss()
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
}
