//
//  CallKit.swift
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

enum CallKitActiveteAudioReason: UInt {
    case startCall, answerCall, outside
}

enum IncommingCallState: UInt {
    case valid = 0
    case missed
    /// Some call data wrong or absent
    case invalid
}

protocol CallKitDelegate: AnyObject {
    func callKit(_ callKit: CallKit, didTapAnswer sessionId: String)
    func callKit(_ callKit: CallKit, didTapRedject sessionId: String)
    func callKit(_ callKit: CallKit, didTapMute enable: Bool)
    func callKit(_ callKit: CallKit, didActivate audioSession: QBRTCAudioSession, reason: CallKitActiveteAudioReason)

    /// external ending using "reportEndCall" methods
    func callKit(_ callKit: CallKit, didEndCall sessionId: String)
}

final class CallKit: NSObject {
    
    //MARK: - Properties
    weak var delegate: CallKitDelegate?
    private var provider: CXProvider?
    private let callController = CXCallController(queue: DispatchQueue.main)
    private var call: CallKitInfo?
    private var reportEndCall: Bool = false
    
    static let providerConfiguration: CXProviderConfiguration = {
        let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
        let config = CXProviderConfiguration(localizedName: appName ?? "SwiftWebRTCSample")
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
        
        guard let provider = provider else { return }
        
        let update = callUpdate(withTitle: title, hasVideo: hasVideo)
        let call = CallKitInfo(sessionID: sessionId, hasVideo: hasVideo)
        if state == .valid {
            self.call = call
            QBRTCAudioSession.instance().useManualAudio = true
        }
        provider.reportNewIncomingCall(with: call.uuid, update: update) { error in
            completion?()
            if let error = error {
                QBRTCAudioSession.instance().useManualAudio = false
                debugPrint("\(#function) Error: \(error)")
                return
            }
            switch state {
            case .valid:
                return
            case .missed: provider.reportCall(with: call.uuid, endedAt: Date(), reason: .remoteEnded)
            case .invalid: provider.reportCall(with: call.uuid, endedAt: Date(), reason: .unanswered)
            }
        }
    }
    
    func reportOutgoingCall(sessionId: String,
                            title: String,
                            hasVideo: Bool,
                            completion: ReportCallCompletion? = nil) {

        call = CallKitInfo(sessionID: sessionId, hasVideo: hasVideo)
        
        guard let provider = provider,
              let call = call else { return }

        let action = CXStartCallAction(call: call.uuid, handle: handle(withText: title))
        let transaction = CXTransaction(action: action)

        callController.request(transaction) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                QBRTCAudioSession.instance().useManualAudio = false
                debugPrint("\(#function) Error: \(error)")
                return
            }
            let update = self.callUpdate(withTitle: title, hasVideo: hasVideo)
            provider.reportCall(with: call.uuid, updated: update)
            completion?()
        }
    }
    
    func reportEndCall(sessionId: String) {
        guard let call = call,
              sessionId == call.sessionID else { return }
        
        reportEndCall = true
        let  action = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction(action: action)
        callController.request(transaction) { error in
            guard let error = error else { return }
            debugPrint("\(#function) Error: \(error)")
        }
    }
    
    func reportEndCall(sessionId: String, reason: CXCallEndedReason) {
        guard let call = call,
              sessionId == call.sessionID,
              let provider = provider else { return }
        
        provider.reportCall(with: call.uuid, endedAt: Date(), reason: reason)
        delegate?.callKit(self, didEndCall: sessionId)
        reportEndCall = false
        self.call = nil
    }
    
    func reportAcceptCall(sessionId: String) {
        guard let provider = provider,
              let callUUID = UUID(uuidString: sessionId) else { return }
        
        let actions = provider.pendingCallActions(of: CXAnswerCallAction.self, withCall: callUUID)
        for action in actions {
            if let answer = action as? CXAnswerCallAction {
                answer.fulfill(withDateConnected: Date())
            }
        }
    }
    
    func reportUpdateCall(sessionId: String, title: String?) {
        guard let title = title,
              let provider = provider,
              let callUUID = UUID(uuidString: sessionId) else { return }

        let update = CXCallUpdate()
        update.remoteHandle = handle(withText:title)
        provider.reportCall(with: callUUID, updated: update)
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
        update.hasVideo = true
        update.hasVideo = hasVideo
        
        return update
    }
    
    private func updateAudioSessionConfiguration(_ hasVideo: Bool, reason: CallKitActiveteAudioReason) {
        let audioSession = QBRTCAudioSession.instance()
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
        audioSession.setConfiguration(configuration, active: true)

        delegate?.callKit(self, didActivate: audioSession, reason: reason)
    }
}

// MARK: - CXProviderDelegate
extension CallKit: CXProviderDelegate {

    func providerDidReset(_ provider: CXProvider) {
        call = nil
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fulfill()
            return
        }
        updateAudioSessionConfiguration(call.hasVideo, reason: .startCall)

        action.fulfill()
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fulfill()
            return
        }
        updateAudioSessionConfiguration(call.hasVideo, reason: .answerCall)
        delegate?.callKit(self, didTapAnswer: call.sessionID)
    }

    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fulfill()
            return
        }
        
        QBRTCAudioSession.instance().isAudioEnabled = false
        QBRTCAudioSession.instance().useManualAudio = false

        if (QBRTCAudioSession.instance().isActive) {
            QBRTCAudioSession.instance().setActive(false)
        }
        
        if reportEndCall {
            delegate?.callKit(self, didEndCall: call.sessionID)
        } else {
            delegate?.callKit(self, didTapRedject: call.sessionID)
        }
        
        reportEndCall = false
        self.call = nil
        
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        debugPrint("Timed out", #function)
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        guard let call = call else {return }
        if QBRTCAudioSession.instance().isActive { return }
        updateAudioSessionConfiguration(call.hasVideo, reason: .outside)
        QBRTCAudioSession.instance().audioSessionDidActivate(audioSession)
        QBRTCAudioSession.instance().isAudioEnabled = true
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        
        if QBRTCAudioSession.instance().isActive == false { return }
        QBRTCAudioSession.instance().audioSessionDidDeactivate(audioSession)
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = call,
              action.callUUID == call.uuid else {
            action.fulfill()
            return
        }
        delegate?.callKit(self, didTapMute: action.isMuted)
        action.fulfill()
    }
}
