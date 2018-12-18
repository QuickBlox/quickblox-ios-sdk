//
//  CallKitManager.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/10/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC
import Quickblox
import CallKit

private let QBDefaultMaximumCallsPerCallGroup: Int = 1
private let QBDefaultMaximumCallGroups: Int = 1


/**
 CallKitManager class interface.
 Used as manager of Apple CallKit.
 */
class CallKitManager: NSObject, CXProviderDelegate {
    
    private var callStarted = false
    
    
    /**
     UserDataSource instance to get users information from.
     */
    weak var usersDatasource: UsersDataSource?
    /**
     Action on microphone mute using CallKit UI.
     */
    var onMicrophoneMuteAction: () -> () = { }
    
    private var provider: CXProvider?
    private var callController: CXCallController?
    private var actionCompletionBlock: () -> () = { }
    private var onAcceptActionBlock: () -> () = { }
    private weak var session: QBRTCSession?
    
    /**
     Class singleton instance.
     */
    static let instance = CallKitManager()
    
    
    class func configuration() -> CXProviderConfiguration? {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let config = CXProviderConfiguration(localizedName: appName ?? "")
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = QBDefaultMaximumCallsPerCallGroup
        config.maximumCallGroups = QBDefaultMaximumCallGroups
        let supportedHandleTypes: Set = [CXHandle.HandleType.generic, CXHandle.HandleType.phoneNumber]
        config.supportedHandleTypes = supportedHandleTypes
        if let image = UIImage(named: "CallKitLogo") {
            config.iconTemplateImageData = image.pngData()
        }
        config.ringtoneSound = "ringtone.wav"
        return config
    }
    
    
    static var callKitAvailable: Bool = {
        var callKitAvailable = false
        if #available(iOS 10.0, *) {
            callKitAvailable = true
        }
        return callKitAvailable
    }()
    
    class func isCallKitAvailable() -> Bool {
        // `dispatch_once()` call was converted to a static variable initializer
        return callKitAvailable
    }
    
    // MARK: - Initialization
    override init() {
        super.init()
        
        let configuration: CXProviderConfiguration? = CallKitManager.configuration()
        if let aConfiguration = configuration {
            provider = CXProvider(configuration: aConfiguration)
        }
        provider?.setDelegate(self, queue: nil)
        callController = CXCallController(queue: DispatchQueue.main)
    }
    
    // MARK: - Call management
    /**
     Start Call with user IDs.
     
     @param userIDs user IDs to perform call with
     @param session session instance
     @param uuid call uuid
     
     @discussion Use this to perform outgoing call with specific user ids.
     
     @see QBRTCSession
     */
    func startCall(withUserIDs userIDs: [NSNumber], session: QBRTCSession?, uuid: UUID?) {
        self.session = session
        let contactIdentifier = ""
        let handle: CXHandle? = self.handle(forUserIDs: userIDs, outCallerName: contactIdentifier)
        var action: CXStartCallAction? = nil
        if let uuid = uuid, let handle = handle {
            action = CXStartCallAction(call: uuid, handle: handle)
        }
        action?.contactIdentifier = contactIdentifier
        
        var transaction: CXTransaction? = nil
        if let anAction = action {
            transaction = CXTransaction(action: anAction)
        }
        if let aTransaction = transaction {
            request(aTransaction) { succeed in
                let update = CXCallUpdate()
                update.remoteHandle = handle
                update.localizedCallerName = contactIdentifier
                update.supportsHolding = false
                update.supportsGrouping = false
                update.supportsUngrouping = false
                update.supportsDTMF = false
                update.hasVideo = session?.conferenceType == QBRTCConferenceType.video
                
                if let uuid = uuid {
                    self.provider?.reportCall(with: uuid, updated: update)
                }
            }
        }
    }
    
    /**
     End call with uuid.
     
     @param uuid uuid of call
     @param completion completion block
     */
    func endCall(with uuid: UUID?, completion: @escaping () -> ()) {
        if session == nil {
            return
        }
        
        var action: CXEndCallAction? = nil
        if let uuid = uuid {
            action = CXEndCallAction(call: uuid)
        }
        var transaction: CXTransaction? = nil
        if let anAction = action {
            transaction = CXTransaction(action: anAction)
        }
        
        dispatchOnMainThread(block: {
            if let aTransaction = transaction {
                self.request(aTransaction) { _ in }
            }
        })
        actionCompletionBlock = completion
    }
    
    
    /**
     Report incoming call with user IDs.
     
     @param userIDs user IDs of incoming call
     @param session session instance
     @param uuid call uuid
     @param onAcceptAction on call accept action
     @param completion completion block
     
     @discussion Use this to show incoming call screen.
     
     @see QBRTCSession
     */
    func reportIncomingCall(withUserIDs userIDs: [NSNumber], session: QBRTCSession?, uuid: UUID?, onAcceptAction: @escaping () -> (), completion: @escaping (Bool) -> Void) {
        if let uuid = uuid {
            print("[CallKitManager] Report incoming call \(uuid)")
        }
        
        if self.session != nil {
            return
        }
        
        self.session = session
        onAcceptActionBlock = onAcceptAction
        
        let callerName = ""
        let update = CXCallUpdate()
        update.remoteHandle = self.handle(forUserIDs: userIDs, outCallerName: callerName)
        update.localizedCallerName = callerName
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.hasVideo = session?.conferenceType == QBRTCConferenceType.video
        
        print("[CallKitManager] Activating audio session.")
        let audioSession = QBRTCAudioSession.instance()
        audioSession.useManualAudio = true
        // disabling audio unit for local mic recording in recorder to enable it later
//        session?.recorder?.isLocalAudioEnabled = false
        if audioSession.isInitialized == false{
            
            audioSession.initialize { configuration in
                
                // adding blutetooth support
                configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowBluetooth)
                configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowBluetoothA2DP)
                // adding airplay support
                configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowAirPlay)
                
                if self.session?.conferenceType == QBRTCConferenceType.video {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                }
            }
        }
        if let uuid = uuid {
            provider?.reportNewIncomingCall(with: uuid, update: update) { error in
                let silent: Bool = (((error as NSError?)?.domain) == CXErrorDomainIncomingCall)
                    && (error as NSError?)?.code == CXErrorCodeIncomingCallError.Code.filteredByDoNotDisturb.rawValue
                self.dispatchOnMainThread(block: {
                    completion(silent)
                })
            }
        }
    }
    
    /**
     Update outgoing call with connecting date
     
     @param uuid call uuid
     @param date connecting started date
     */
    func updateCall(with uuid: UUID?, connectingAt date: Date?) {
        if let uuid = uuid {
            provider?.reportOutgoingCall(with: uuid, startedConnectingAt: date)
        }
    }
    
    /**
     Update outgoing call with connected date.
     
     @param uuid call uuid
     @param date connected date
     */
    func updateCall(with uuid: UUID?, connectedAt date: Date?) {
        if let uuid = uuid {
            provider?.reportOutgoingCall(with: uuid, connectedAt: date)
        }
    }
    
    // MARK: - CXProviderDelegate protocol
    @available(iOS 10.0, *)
    func providerDidReset(_ provider: CXProvider){
    }
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        if session == nil {
            action.fail()
            return
        }
        
        dispatchOnMainThread(block: {
            self.session?.startCall(nil)
            self.callStarted = true
            action.fulfill()
        })
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        if session == nil {
            action.fail()
            return
        }
        CallKitManager.callKitAvailable = true
        
        // Workaround for webrtc on ios 10, because first incoming call does not have audio
        // due to incorrect category: AVAudioSessionCategorySoloAmbient
        // webrtc need AVAudioSessionCategoryPlayAndRecord
        
        if !((try?  AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord,
                                                                mode: AVAudioSession.Mode.default,
                                                                options: AVAudioSession.CategoryOptions.defaultToSpeaker)) != nil) {
            print("[CallKitManager] Error setting category for webrtc workaround.")
        }
        
        dispatchOnMainThread(block: {
            self.session?.acceptCall(nil)
            self.callStarted = true
            action.fulfill()
            self.onAcceptActionBlock()
        })
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        if self.session == nil {
            action.fail()
            return
        }
        
        var session: QBRTCSession? = self.session
        session = nil
        
        dispatchOnMainThread(block: {
            let audioSession = QBRTCAudioSession.instance()
            audioSession.isAudioEnabled = false
            audioSession.useManualAudio = false
            
            if self.callStarted {
                session?.hangUp(nil)
                self.callStarted = false
            } else {
                session?.rejectCall(nil)
            }
            action.fulfill(withDateEnded: Date())
            self.actionCompletionBlock()
        })
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction){
        if session == nil {
            action.fail()
            return
        }
        dispatchOnMainThread(block: {
            self.session?.localMediaStream.audioTrack.isEnabled = !action.isMuted
            action.fulfill()
            self.onMicrophoneMuteAction()
        })
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession){
        print("[CallKitManager] Activated audio session.")
        let rtcAudioSession = QBRTCAudioSession.instance()
        rtcAudioSession.audioSessionDidActivate(audioSession)
        // enabling audio now
        rtcAudioSession.isAudioEnabled = true
        // enabling local mic recording in recorder (if recorder is active) as of interruptions are over now
//        session?.recorder?.isLocalAudioEnabled = true
    }
    
    @available(iOS 10.0, *)
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession){
        print("[CallKitManager] Dectivated audio session.")
        QBRTCAudioSession.instance().audioSessionDidDeactivate(audioSession)
        // deinitializing audio session after iOS deactivated it for us
        let session = QBRTCAudioSession.instance()
        if session.isInitialized {
            print("Deinitializing session in CallKit callback.")
            session.deinitialize()
        }
    }
    
    // MARK: - Helpers
    func handle(forUserIDs userIDs: [NSNumber], outCallerName: String?) -> CXHandle? {
        var outCallerName = outCallerName
        // handle user from whatever database here
        if outCallerName != nil {
            var opponentNames = [String]()
            for userID in userIDs {
                let user = usersDatasource?.user(withID: userID.uintValue )
                opponentNames.append(user?.fullName ?? "\(userID.uintValue)" )
            }
            outCallerName = opponentNames.joined(separator: ", ")
        }
        
        if userIDs.count == 1 {
            let user = usersDatasource?.user(withID: userIDs[0].uintValue)
            if user?.phone?.isEmpty == false {
                return CXHandle(type: .phoneNumber, value: user?.phone ?? "")
            }
        }
        let arrayUserIDs = userIDs.map({"\($0)"})
        return CXHandle(type: .generic, value: arrayUserIDs.joined(separator: ", ") )
    }
    
    @inline(__always) private func dispatchOnMainThread(block: @escaping () -> ()) {
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    func request(_ transaction: CXTransaction, completion: @escaping (Error?) -> Void) {
        callController?.request(transaction) { error in
            if let error = error {
                debugPrint("[CallKitManager] Error: \(error)")
            }
        }
    }
}

