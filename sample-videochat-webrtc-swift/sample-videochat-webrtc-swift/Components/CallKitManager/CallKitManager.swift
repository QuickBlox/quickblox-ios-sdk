//
//  CallKitManager.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/10/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC
import Quickblox
import CallKit

struct CallKitManagerConstant {
    static let maximumCallsPerCallGroup: Int = 1
    static let maximumCallGroups: Int = 1
}

enum CallStatus: UInt {
    case none = 0
    case invite
    case active
    case ended
}

struct Call {
    var uuid: UUID
    var sessionID: String?
    var status: CallStatus
}

typealias CompletionBlock = (() -> Void)
typealias CompletionActionBlock = ((Bool) -> Void)
typealias AudioSessionInitializeBlock = ((QBRTCSession) -> Void)

protocol CallKitManagerDelegate: class {
    func callKitManager(_ callKitManager: CallKitManager, didUpdateSession session: QBRTCSession)
}
/**
 CallKitManager class interface.
 Used as manager of Apple CallKit.
 */
class CallKitManager: NSObject {
    
    //MARK: - Properties
    weak var delegate: CallKitManagerDelegate?
    
    private var callStarted = false {
        didSet {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.isCalling = callStarted
            }
        }
    }
    
    /**
     UserDataSource instance to get users information from.
     */
    var usersDatasource: UsersDataSource?
    /**
     Action on microphone mute using CallKit UI.
     */
    var onMicrophoneMuteAction: CompletionBlock?
    private var provider: CXProvider?
    private var callController: CXCallController?
    private var actionCompletionBlock: CompletionBlock?
    private var onAcceptActionBlock: CompletionActionBlock?
    private var audioSessionInitializeBlock: AudioSessionInitializeBlock?
    private var session: QBRTCSession? {
        didSet {
            if let session = session {
                self.delegate?.callKitManager(self, didUpdateSession: session)
                if let audioSessionInitializeBlock = self.audioSessionInitializeBlock {
                    audioSessionInitializeBlock(session)
                    self.audioSessionInitializeBlock = nil
                }
            }
        }
    }
    private var calls: [Call] = []
    
    /**
     Class singleton instance.
     */
    static let instance = CallKitManager()
    
    class func configuration() -> CXProviderConfiguration {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let config = CXProviderConfiguration(localizedName: appName ?? "")
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = CallKitManagerConstant.maximumCallsPerCallGroup
        config.maximumCallGroups = CallKitManagerConstant.maximumCallGroups
        config.supportedHandleTypes = [.phoneNumber]
        if let image = UIImage(named: "CallKitLogo") {
            config.iconTemplateImageData = image.pngData()
        }
        config.ringtoneSound = "ringtone.wav"
        return config
    }
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        provider = CXProvider(configuration: CallKitManager.configuration())
        
        if let provider = provider {
            provider.setDelegate(self, queue: nil)
        }
        callController = CXCallController(queue: DispatchQueue.main)
        callStarted = false
    }
    
    func isCallStarted() -> Bool { 
        return callStarted
    }
    
    func isHasSession() -> Bool {
        return self.session != nil
    }
    
    func currentCall() -> Call? {
        if let currentCall = calls.first {
            return currentCall
        }
        return nil
    }
    
    func setupSession(_ session: QBRTCSession) {
        self.session = session
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
        guard let session = session,
            let uuid = uuid else {
                return
        }
        self.session = session
        
        calls = []
        let outgoingCall = Call(uuid: uuid, sessionID: session.id, status: .active)
        calls = [outgoingCall]
        
        let contactIdentifier = ""
        let handle = self.handle(forUserIDs: userIDs)
        let action = CXStartCallAction(call: uuid, handle: handle)
        action.contactIdentifier = contactIdentifier
        let transaction = CXTransaction(action: action)
        request(transaction) { error in
            if error == nil {
                let update = CXCallUpdate()
                update.remoteHandle = handle
                update.localizedCallerName = contactIdentifier
                update.supportsHolding = false
                update.supportsGrouping = false
                update.supportsUngrouping = false
                update.supportsDTMF = false
                update.hasVideo = session.conferenceType == QBRTCConferenceType.video
                if let provider = self.provider {
                    provider.reportCall(with: uuid, updated: update)
                }
            }
        }
    }
    
    /**
     End call with uuid.
     @param uuid uuid of call
     @param completion completion block
     */
    func endCall(with uuid: UUID?, completion: CompletionBlock? = nil) {
        guard let currentCall = calls.first else {
            return
        }
        let  action = CXEndCallAction(call: currentCall.uuid)
        let transaction = CXTransaction(action: action)
        dispatchOnMainThread(block: {
            self.request(transaction, completion: { (error) in
                if let error = error {
                    debugPrint("[CallKitManager] Request transaction error: \(error.localizedDescription)")
                }
            })
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
    func reportIncomingCall(withUserIDs userIDs: [NSNumber],
                            outCallerName: String,
                            session: QBRTCSession?,
                            sessionID: String?,
                            sessionConferenceType:QBRTCConferenceType,
                            uuid: UUID,
                            onAcceptAction: @escaping CompletionActionBlock,
                            completion: @escaping (Bool) -> Void) {
        
        calls = []
        if session != nil {
            self.session = session
        }
        
        onAcceptActionBlock = onAcceptAction
        
        let incomingCall = Call(uuid: uuid, sessionID: sessionID, status: .invite)
        calls = [incomingCall]
        
        let update = CXCallUpdate()
        update.localizedCallerName = outCallerName
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.hasVideo = true
        update.hasVideo = sessionConferenceType == .video
        
        let audioSession = QBRTCAudioSession.instance()
        audioSession.useManualAudio = true
        // disabling audio unit for local mic recording in recorder to enable it later
        if audioSession.isInitialized == false {
            audioSession.initialize { configuration in
                // adding blutetooth support
                configuration.categoryOptions.insert(.allowBluetooth)
                configuration.categoryOptions.insert(.allowBluetoothA2DP)
                configuration.categoryOptions.insert(.duckOthers)
                // adding airplay support
                configuration.categoryOptions.insert(.allowAirPlay)
                if sessionConferenceType == .video {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                } else if sessionConferenceType == .audio {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.voiceChat.rawValue
                }
            }
        }
        
        if let provider = provider {
            provider.reportNewIncomingCall(with: uuid, update: update) { error in
                let errorDomain = (error as NSError?)?.domain
                let errorCode = (error as NSError?)?.code
                let silent = errorDomain == CXErrorDomainIncomingCall &&
                    errorCode == CXErrorCodeIncomingCallError.Code.filteredByDoNotDisturb.rawValue
                self.dispatchOnMainThread(block: {
                    completion(silent)
                })
            }
        }
    }
    
    func updateIncomingCall(withUserIDs userIDs: [NSNumber],
                            outCallerName: String,
                            session: QBRTCSession,
                            uuid: UUID) {
        guard let provider = provider else {
            return
        }
        
        self.session = session
        let audioSession = QBRTCAudioSession.instance()
        
        audioSession.useManualAudio = true
        // disabling audio unit for local mic recording in recorder to enable it later
        session.recorder?.isLocalAudioEnabled = false
        if audioSession.isInitialized == false {
            audioSession.initialize { configuration in
                // adding blutetooth support
                configuration.categoryOptions.insert(.allowBluetooth)
                configuration.categoryOptions.insert(.allowBluetoothA2DP)
                configuration.categoryOptions.insert(.duckOthers)
                // adding airplay support
                configuration.categoryOptions.insert(.allowAirPlay)
                if session.conferenceType == .video {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                } else if session.conferenceType == .audio {
                    // setting mode to video chat to enable airplay audio and speaker only
                    configuration.mode = AVAudioSession.Mode.voiceChat.rawValue
                }
            }
        }
        
        let update = CXCallUpdate()
        update.localizedCallerName = outCallerName
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.hasVideo = true
        update.hasVideo = session.conferenceType == .video
        
        provider.reportCall(with: uuid, updated: update)
    }
    
    /**
     Update outgoing call with connecting date
     
     @param uuid call uuid
     @param date connecting started date
     */
    func updateCall(with uuid: UUID?, connectingAt date: Date?) {
        if let uuid = uuid,
            let provider = provider {
            provider.reportOutgoingCall(with: uuid, startedConnectingAt: date)
        }
    }
    
    /**
     Update outgoing call with connected date.
     
     @param uuid call uuid
     @param date connected date
     */
    func updateCall(with uuid: UUID?, connectedAt date: Date?) {
        if let uuid = uuid,
            let provider = provider {
            provider.reportOutgoingCall(with: uuid, connectedAt: date)
        }
    }
    
    // MARK: - Helpers
    func handle(forUserIDs userIDs: [NSNumber]) -> CXHandle {
        if userIDs.count == 1 {
            if let userId = userIDs.first,
                let usersDatasource = usersDatasource,
                let user = usersDatasource.user(withID: userId.uintValue),
                user.phone?.isEmpty == false {
                return CXHandle(type: .phoneNumber, value: user.phone ?? "")
            }
        }
        let arrayUserIDs = userIDs.map({$0.stringValue})
        return CXHandle(type: .phoneNumber, value: arrayUserIDs.joined(separator: ", "))
    }
    
    @inline(__always) private func dispatchOnMainThread(block: @escaping () -> Void) {
        if Thread.isMainThread == true {
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
            debugPrint("[CallKitManager] transaction successfully!!!")
            completion(nil)
        }
    }
}

extension CallKitManager: CXProviderDelegate {
    // MARK: - CXProviderDelegate protocol
    func providerDidReset(_ provider: CXProvider){
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard let session = self.session else {
            action.fail()
            return
        }
        dispatchOnMainThread(block: { [weak self] in
            session.startCall(nil)
            self?.callStarted = true
            action.fulfill()
        })
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        if let index = calls.firstIndex(where: { $0.uuid == action.callUUID }),
            calls[index].status == .invite {
            calls[index].status = .active
        } else {
            return
        }
        if let session = self.session {
            if (Int(UIDevice.current.systemVersion) == 10) {
                // Workaround for webrtc on ios 10, because first incoming call does not have audio
                // due to incorrect category: AVAudioSessionCategorySoloAmbient
                // webrtc need AVAudioSessionCategoryPlayAndRecord
                try! AVAudioSession.sharedInstance().setCategory(.playAndRecord)
                debugPrint("[CallKitManager] Error setting category for webrtc workaround on ios 10.")
            }
            self.callStarted = true
            session.acceptCall(nil)
        }
        
        dispatchOnMainThread(block: { [weak self] in
            guard let self = self else {
                return
            }
            action.fulfill()
            if let onAcceptActionBlock = self.onAcceptActionBlock {
                onAcceptActionBlock(true)
                self.onAcceptActionBlock = nil
            }
        })
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if let index = calls.firstIndex(where: { $0.uuid == action.callUUID }) {
            calls[index].status = .ended
            if let session = self.session {
                if callStarted == true {
                    session.hangUp(nil)
                    callStarted = false
                } else {
                    session.rejectCall(nil)
                }
                self.session = nil
                calls = []
            }
        } else {
            callStarted = false
            calls = []
            action.fail()
            return
        }
        
        dispatchOnMainThread(block: { [weak self] in
            guard let self = self else {
                return
            }
            let audioSession = QBRTCAudioSession.instance()
            if audioSession.isInitialized == true {
                audioSession.isAudioEnabled = false
                audioSession.useManualAudio = false
                audioSession.deinitialize()
            }
            action.fulfill(withDateEnded: Date())
            
            if let onAcceptActionBlock = self.onAcceptActionBlock {
                onAcceptActionBlock(false)
                self.onAcceptActionBlock = nil
            }
            if let actionCompletionBlock = self.actionCompletionBlock {
                actionCompletionBlock()
                self.actionCompletionBlock = nil
            }
            
            self.audioSessionInitializeBlock = nil
        })
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction){
        dispatchOnMainThread(block: { [weak self] in
            if let session = self?.session {
                session.localMediaStream.audioTrack.isEnabled = !action.isMuted
            }
            action.fulfill()
            if let onMicrophoneMuteAction = self?.onMicrophoneMuteAction {
                onMicrophoneMuteAction()
            }
        })
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession){
        if self.session != nil {
            debugPrint("[CallKitManager] Activated audio session.")
            activateAudioSession(audioSession)
        } else {
            self.audioSessionInitializeBlock = { [weak self] qbSession in
                self?.activateAudioSession(audioSession)
                debugPrint("[CallKitManager] Activated audio session in audioSessionInitializeBlock.")
            }
        }
    }
    
    private func activateAudioSession(_ audioSession: AVAudioSession) {
        let rtcAudioSession = QBRTCAudioSession.instance()
        rtcAudioSession.audioSessionDidActivate(audioSession)
        // enabling audio now
        rtcAudioSession.isAudioEnabled = true
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession){
        debugPrint("[CallKitManager] Dectivated audio session.")
        QBRTCAudioSession.instance().audioSessionDidDeactivate(audioSession)
        // deinitializing audio session after iOS deactivated it for us
        let rtcAudioSession = QBRTCAudioSession.instance()
        if rtcAudioSession.isInitialized == true {
            debugPrint("Deinitializing session in CallKit callback.")
            rtcAudioSession.deinitialize()
        }
        self.audioSessionInitializeBlock = nil
    }
}
