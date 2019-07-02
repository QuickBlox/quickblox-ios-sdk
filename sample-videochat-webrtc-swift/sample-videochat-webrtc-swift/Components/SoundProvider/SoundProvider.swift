//
//  SoundProvider.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/26/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

enum SoundType: String {
    case calling
    case ringtone
}

enum SoundExtentionType: String {
    case caf
    case aif
    case aiff
    case wav
}

struct SoundErrorConstant {
    static let notSupported = NSLocalizedString("The property is not supported.", comment: "")
    static let sizePropertyDataNotCorrect = NSLocalizedString("The size of the property data was not correct.", comment: "")
    static let sizeSpecifierDataNotCorrect = NSLocalizedString("The size of the specifier data was not correct.", comment: "")
    static let unspecifiedErrorOccurred = NSLocalizedString("An unspecified error has occurred.", comment: "")
    static let timeOut = NSLocalizedString("System sound client message timed out.", comment: "")
    static let notBeAdded = NSLocalizedString("Warning! Completion block could not be added to SystemSoundID.", comment: "")
    static let notBeCreated = NSLocalizedString("Warning! SystemSoundID could not be created.", comment: "")
    static let notBeDisposed = NSLocalizedString("Warning! SystemSoundID could not be disposed.", comment: "")
}

class SoundProvider {
    
    //MARK: - Instance Singelton
    static let instance = SoundProvider()
    
    //MARK: - Properties
    var soundId: SystemSoundID = 1158
    
    let notificationCenter = NotificationCenter.default
    
    //MARK: - Class Methods
    class func playSound(type: SoundType) {
        SoundProvider.instance.playSound(type: type)
    }
    
    class func stopSound(){
        SoundProvider.instance.unloadSoundID()
    }
    
    //MARK: - Life Cycle
    init() {
        notificationCenter.addObserver(self,
                                       selector: #selector(self.didReceiveMemoryWarning(_:)),
                                       name: UIApplication.didReceiveMemoryWarningNotification,
                                       object: nil)
    }
    
    deinit {
        notificationCenter.removeObserver(self)
    }
    
    func playSound(type: SoundType) {
        if type.rawValue.isEmpty == true {
            return
        }
        soundId = createSoundID(withName: type.rawValue, extention: SoundExtentionType.wav.rawValue)
        switch type {
        case .calling:
            AudioServicesPlaySystemSound(soundId)
        case .ringtone:
            AudioServicesPlayAlertSound(soundId)
        }
    }
    
    //MARK: - Internal Methods
    private func createSoundID(withName filename: String, extention: String?) -> SystemSoundID {
        var soundID: SystemSoundID = 1158
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: extention) else {
            debugPrint("[SoundProvider] Error: audio file not found at URL")
            return soundID
        }
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let error: OSStatus = AudioServicesCreateSystemSoundID(fileURL as CFURL, &soundID)
            if error != noErr  {
                logError(error, withMessage: SoundErrorConstant.notBeCreated)
                return soundID
            } else {
                soundId = soundID
                return soundId
            }
        }
        return soundID
    }
    
    private func unloadSoundID() {
        AudioServicesRemoveSystemSoundCompletion(soundId)
        let error: OSStatus = AudioServicesDisposeSystemSoundID(soundId)
        if error != noErr  {
            logError(error, withMessage: SoundErrorConstant.notBeDisposed)
        }
    }
    
    private func logError(_ error: OSStatus, withMessage message: String?) {
        var errorMessage: String? = nil
        
        switch error {
        case kAudioServicesUnsupportedPropertyError:
            errorMessage = SoundErrorConstant.notSupported
        case kAudioServicesBadPropertySizeError:
            errorMessage = SoundErrorConstant.sizePropertyDataNotCorrect
        case kAudioServicesBadSpecifierSizeError:
            errorMessage = SoundErrorConstant.sizeSpecifierDataNotCorrect
        case kAudioServicesSystemSoundUnspecifiedError:
            errorMessage = SoundErrorConstant.unspecifiedErrorOccurred
        case kAudioServicesSystemSoundClientTimedOutError:
            errorMessage = SoundErrorConstant.timeOut
        default:
            break
        }
        debugPrint("\(message ?? "") Error: (code \(Int(error))) \(errorMessage ?? "")")
    }
    
    // MARK: - Did Receive Memory Warning Notification
    @objc private func didReceiveMemoryWarning(_ notification: Notification?) {
        unloadSoundID()
    }
}
