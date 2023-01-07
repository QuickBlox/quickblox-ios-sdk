//
//  CallKitManager.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 30.03.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC
import Quickblox
import CallKit

typealias ReportCallCompletion = (() -> Void)

struct CallKitConstant {
    static let defaultMaximumCallsPerCallGroup: Int = 1
    static let defaultMaximumCallGroups: Int = 1
}

enum IncommingCallState: UInt {
    case valid = 0
    case missed
    /// Some call data wrong or absent
    case invalid
}

protocol CallKitManagerDelegate: AnyObject {
    func callKit(_ callKit: CallKitManager, didTapAnswer sessionId: String)
    func callKit(_ callKit: CallKitManager, didTapRedject sessionId: String)
    
    /// external ending using "reportEndCall" methods
    func callKit(_ callKit: CallKitManager, didEndCall sessionId: String)
}

protocol CallKitManagerActionDelegate: AnyObject {
    func callKit(_ callKit: CallKitManager, didTapMute isMuted: Bool)
}

final class CallKitManager: NSObject {
    
    //MARK: - Properties
    weak var delegate: CallKitManagerDelegate?
    weak var actionDelegate: CallKitManagerActionDelegate?
    private var provider: CXProvider?
    private let qbAudioSession = QBRTCAudioSession.instance()
    private let callController = CXCallController(queue: DispatchQueue.main)
    private var call: CallKitInfo?
    private var reportEndCall: Bool = false
    
    static let providerConfiguration: CXProviderConfiguration = {
        let config = CXProviderConfiguration()
        config.supportsVideo = true
        config.maximumCallsPerCallGroup = CallKitConstant.defaultMaximumCallsPerCallGroup
        config.maximumCallGroups = CallKitConstant.defaultMaximumCallGroups
        config.supportedHandleTypes = [.phoneNumber]
        if let image = UIImage(named: "qb-logo") {
            config.iconTemplateImageData = image.pngData()
        }
        config.ringtoneSound = "ringtone.wav"
        return config
    }()
    
    func callUUID() -> UUID? {
        return call?.uuid
    }
    
    // MARK: - Life Cycle
    override init() {
        provider = CXProvider(configuration: type(of: self).providerConfiguration)
        super.init()
        if let provider = provider {
            provider.setDelegate(self, queue: nil)
        }
    }
    
    //MARK: - Public Methods
    func reportIncomingCall(sessionId: String,
                            title: String,
                            hasVideo: Bool,
                            state: IncommingCallState,
                            completion: ReportCallCompletion? = nil) {
        
        guard let provider = provider else {
            return
        }
        
        let update = callUpdate(withTitle: title, hasVideo: hasVideo)
        let call = CallKitInfo(sessionID: sessionId, hasVideo: hasVideo)
        self.call = call
        
        provider.reportNewIncomingCall(with: call.uuid, update: update) { [weak self] error in
            defer { completion?() }
            if let error = error {
                debugPrint("\(#function) Error: \(error)")
                return
            }
            switch state {
            case .valid:
                self?.qbAudioSession.useManualAudio = true
                return
            case .missed: provider.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
            case .invalid: provider.reportCall(with: call.uuid, endedAt: Date(), reason: .unanswered)
            }
            self?.call = nil
        }
    }
    
    func reportOutgoingCall(sessionId: String,
                            title: String,
                            hasVideo: Bool,
                            completion: ReportCallCompletion? = nil) {
        
        call = CallKitInfo(sessionID: sessionId, hasVideo: hasVideo)
        
        guard let call = call else {
            return
        }
        
        let action = CXStartCallAction(call: call.uuid, handle: handle(withText: title))
        let transaction = CXTransaction(action: action)
        
        callController.request(transaction) { error in
            defer { completion?() }
            if let error = error {
                debugPrint("\(#function) Error: \(error)")
            }
        }
    }
    
    func reportEndCall(sessionId: String) {
        guard let call = call,
              sessionId == call.sessionID else {
            return
        }
        
        reportEndCall = true
        let  action = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: action)
        callController.request(transaction) { error in
            guard let error = error else {
                return
            }
            debugPrint("\(#function) Error: \(error)")
        }
    }
    
    func reportEndCall(sessionId: String, reason: CXCallEndedReason) {
        guard let call = self.call,
                sessionId == call.sessionID,
              let provider = provider else {
            return
        }
        
        provider.reportCall(with: call.uuid, endedAt: Date(), reason: reason)
        closeCall(call.sessionID)
    }
    
    func reportAcceptCall(sessionId: String) {
        guard let provider = self.provider,
              let call = self.call else {
            return
        }
        
        let actions = provider.pendingCallActions(of: CXAnswerCallAction.self, withCall: call.uuid)
        for action in actions {
            if let answer = action as? CXAnswerCallAction {
                answer.fulfill(withDateConnected: Date())
                break
            }
        }
    }
    
    func reportUpdateCall(sessionId: String, title: String?) {
        guard let title = title,
              let provider = provider,
              let callUUID = UUID(uuidString: sessionId) else {
            return
        }
        
        let update = CXCallUpdate()
        update.remoteHandle = handle(withText:title)
        update.localizedCallerName = title
        provider.reportCall(with: callUUID, updated: update)
    }
    
    func muteAudio(_ mute: Bool, forCall sessionId: String) {
        guard let call = call, call.sessionID == sessionId else {
            return
        }
        
        let  action = CXSetMutedCallAction(call: call.uuid, muted: mute)
        let transaction = CXTransaction(action: action)
        callController.request(transaction) { error in
            guard let error = error else {
                return
            }
            debugPrint("\(#function) Error: \(error)")
        }
    }
    
    // MARK: - Helpers
    private func handle(withText text: String) -> CXHandle {
        return CXHandle(type: .generic, value: text)
    }
    
    private func callUpdate(withTitle title: String, hasVideo: Bool) -> CXCallUpdate {
        let update = CXCallUpdate()
        update.localizedCallerName = title
        update.supportsHolding = false
        update.supportsGrouping = false
        update.supportsUngrouping = false
        update.supportsDTMF = false
        update.hasVideo = hasVideo
        return update
    }
    
    private func closeCall(_ sessionID: String) {
        qbAudioSession.isAudioEnabled = false
        qbAudioSession.useManualAudio = false
        
        if reportEndCall {
            delegate?.callKit(self, didEndCall: sessionID)
        } else {
            delegate?.callKit(self, didTapRedject: sessionID)
        }
        
        reportEndCall = false
        self.call = nil
    }
    
    private func updateAudioSessionConfiguration(_ hasVideo: Bool) {
        let configuration = QBRTCAudioSessionConfiguration()
        configuration.categoryOptions.insert(.duckOthers)

        // adding blutetooth support
        configuration.categoryOptions.insert(.allowBluetooth)
        configuration.categoryOptions.insert(.allowBluetoothA2DP)

        // adding airplay support
        configuration.categoryOptions.insert(.allowAirPlay)
        
        if hasVideo == true {
            // setting mode to video chat to enable airplay audio and speaker only
            configuration.mode = AVAudioSession.Mode.videoChat.rawValue
        }
        qbAudioSession.setConfiguration(configuration)
    }
}

// MARK: - CXProviderDelegate
extension CallKitManager: CXProviderDelegate {
    
    func providerDidReset(_ provider: CXProvider) {
        call = nil
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fail()
            return
        }
        updateAudioSessionConfiguration(call.hasVideo)
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fail()
            return
        }
        updateAudioSessionConfiguration(call.hasVideo)
        
        delegate?.callKit(self, didTapAnswer: call.sessionID)
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fail()
            return
        }
        closeCall(call.sessionID)
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        qbAudioSession.audioSessionDidActivate(audioSession)
        qbAudioSession.isAudioEnabled = true
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        qbAudioSession.audioSessionDidDeactivate(audioSession)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fail()
            return
        }
        actionDelegate?.callKit(self, didTapMute: action.isMuted)
        action.fulfill()
    }
}
