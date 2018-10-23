//
//  QMSoundManager.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

struct QMSoundManagerConstants {
    static let kSystemSoundTypeCAF = "caf"
    static let kSystemSoundTypeAIF = "aif"
    static let kSystemSoundTypeAIFF = "aiff"
    static let kystemSoundTypeWAV = "wav"
    
    static let kQMSoundManagerSettingKey = "kQMSoundManagerSettingKey"
    
    static let kQMCallingSoundName = "calling"
    static let kQMBusySoundName = "busy"
    static let kQMEndOfCallSoundName = "end_of_call"
    static let kQMRingtoneSoundName = "ringtone"
}

class QMSoundManager {
    var on = false
    
    //MARK: Instance Singelton
    static let instance = QMSoundManager()
    
    //MARK: Variadles
    private var sounds: [String : Data] = [:]
    private var completionBlocks: [AnyHashable : Any] = [:]
    private var audioDeviceChanged = false
    
    let notifcationCenter = NotificationCenter.default
    
    // MARK: Life cycle
    
    init() {
        
//        super.init()
        
        
        on = true
        
//        sounds = [AnyHashable : Any]()
//        completionBlocks = [AnyHashable : Any]()
        
        notifcationCenter.addObserver(self, selector: #selector(self.didReceiveMemoryWarning(_:)), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
        
    }

    deinit {
        notifcationCenter.removeObserver(self)
    }
    
    func setOn(_ on: Bool) {
        
        self.on = on
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(on, forKey: QMSoundManagerConstants.kQMSoundManagerSettingKey)
        userDefaults.synchronize()
        
        if !on {
            
            stopAllSounds()
        }
    }
    
    /**
     *  Plays a system sound object corresponding to an audio file with the given filename and extension.
     *  The system sound player will lazily initialize and load the file before playing it, and then cache its corresponding `SystemSoundID`.
     *  If this file has previously been played, it will be loaded from cache and played immediately.
     *
     *  @param filename      A string containing the base name of the audio file to play.
     *  @param extension A string containing the extension of the audio file to play.
     *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav`
     *
     *  @warning If the system sound object cannot be created, this method does nothing.
     */
    func playSound(withName filename: String?, ext: String?) {
        
        playSound(withName: filename, ext: ext) {  }
    }
    
    func playSound(withName filename: String?, ext: String?, isAlert: Bool, completion: @escaping () -> Void) {
        
        if !on {
            return
        }
        
        if filename == nil || ext == nil {
            return
        }
        
        if sounds[filename!] == nil {
            
            addSoundIDForAudioFile(withName: filename, ext: ext)
        }
        
        let soundID = self.soundID(forFilename: filename)
        
//        if soundID != 0 {
//            
//            //if completion
//            
//            let weakSelf = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
//            let error: OSStatus = AudioServicesAddSystemSoundCompletion(soundID, nil, nil, systemServicesSoundCompletion(soundID: soundID, data: weakSelf), nil)
//            
//            if error != noErr {
//                
//                logError(error, withMessage: "Warning! Completion block could not be added to SystemSoundID.")
//            } else {
//                
//                addCompletionBlock(completion, to: soundID)
//            }
//            
//            
//            if isAlert {
//                
//                AudioServicesPlayAlertSound(soundID)
//            } else {
//                
//                AudioServicesPlaySystemSound(soundID)
//            }
//        }
    }
    
    /**
     *  Plays a system sound object *as an alert* corresponding to an audio file with the given filename and extension.
     *  The system sound player will lazily initialize and load the file before playing it, and then cache its corresponding `SystemSoundID`.
     *  If this file has previously been played, it will be loaded from cache and played immediately.
     *
     *  @param filename     A string containing the base name of the audio file to play.
     *  @param extension    A string containing the extension of the audio file to play.
     *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav
     *
     *  @warning If the system sound object cannot be created, this method does nothing.
     *
     *  @warning This method performs the same functions as `playSoundWithName: extension:`, with the excepion that,
     *  depending on the particular iOS device, this method may invoke vibration.
     */
    func playAlertSound(withName filename: String?, ext: String?) {
        
        playAlertSound(withName: filename, ext: ext) {  }
    }
    // MARK: Preset sounds
    class func playCallingSound() {
        
        QMSoundManager.instance.playSound(withName: QMSoundManagerConstants.kQMCallingSoundName, ext: QMSoundManagerConstants.kystemSoundTypeWAV)
    }
    
    class func playBusySound() {
        
        QMSoundManager.instance.playSound(withName: QMSoundManagerConstants.kQMBusySoundName, ext: QMSoundManagerConstants.kystemSoundTypeWAV)
    }
    
    class func playEndOfCallSound() {
        
        QMSoundManager.instance.playSound(withName: QMSoundManagerConstants.kQMEndOfCallSoundName, ext: QMSoundManagerConstants.kystemSoundTypeWAV)
    }
    
    class func playRingtoneSound() {
        
        QMSoundManager.instance.playAlertSound(withName: QMSoundManagerConstants.kQMRingtoneSoundName, ext: QMSoundManagerConstants.kystemSoundTypeWAV)
    }
    
    func playAlertSound(withName filename: String?, ext: String?, completion: @escaping () -> Void) {
        
        playSound(withName: filename, ext: ext, isAlert: true, completion: completion)
    }
    
    
    
    func playSound(withName filename: String?, ext: String?, completion: @escaping () -> Void) {
        
        playSound(withName: filename, ext: ext, isAlert: false, completion: completion)
    }
    
    
    
    
    
   
    
    
    
    /**
     *  On some iOS devices, you can call this method to invoke vibration.
     *  On other iOS devices this functionaly is not available, and calling this method does nothing.
     */
    func playVibrateSound() {
        if on {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    /**
     *  Stops playing all sounds immediately.
     *
     *  @warning Any completion blocks attached to any currently playing sound will *not* be executed.
     *  Also, calling this method will purge all `SystemSoundID` objects from cache, regardless of whether or not they were currently playing.
     */
    func stopAllSounds() {
        unloadSoundIDs()
    }
    
    /**
     *  Stops playing the sound with the given filename immediately.
     *
     *  @param filename The filename of the sound to stop playing.
     *
     *  @warning If a completion block is attached to the given sound, it will *not* be executed.
     *  Also, calling this method will purge the `SystemSoundID` object for this file from cache, regardless of whether or not it was currently playing.
     */
    func stopSound(withFilename filename: String?) {
        
        let soundID = self.soundID(forFilename: filename)
        let data: Data? = self.data(with: soundID)
        
        unloadSoundID(forFileNamed: filename)
        
        sounds.removeValue(forKey: filename!)
        completionBlocks.removeValue(forKey: data)
    }
    
    /**
     *  Preloads a system sound object corresponding to an audio file with the given filename and extension.
     *  The system sound player will initialize, load, and cache the corresponding `SystemSoundID`.
     *
     *  @param filename      A string containing the base name of the audio file to play.
     *  @param extension A string containing the extension of the audio file to play.
     *  This parameter must be one of `caf`, `aif`, `aiff`, or `wav`.
     */
    func preloadSound(withFilename filename: String?, ext: String?) {
        
        if sounds[filename!] == nil {
            addSoundIDForAudioFile(withName: filename, ext: ext)
        }
    }
    
    func systemServicesSoundCompletion(soundID: SystemSoundID, data: UnsafeMutableRawPointer?) {
        
        let completion: (() -> Void)? = QMSoundManager.instance.completionBlock(for: soundID)
        
        if completion != nil {
            
            completion?()
            QMSoundManager.instance.removeCompletionBlock(for: soundID)
        }
    }
    
    // MARK: - Sound completion blocks
    func completionBlock(for soundID: SystemSoundID) -> (() -> Void) {
        
        let data: Data? = self.data(with: soundID)
        if let aData = data {
            return completionBlocks[aData] as! (() -> Void)
        }
        return {  }
    }
    
    func addCompletionBlock(_ block: @escaping () -> Void, to soundID: SystemSoundID) {
        
        let data: Data? = self.data(with: soundID)
        if let aData = data {
            completionBlocks[aData] = block()
        }
    }
    
    func removeCompletionBlock(for soundID: SystemSoundID) {
        
        let key: Data? = data(with: soundID)
        completionBlocks.removeValue(forKey: key)
        AudioServicesRemoveSystemSoundCompletion(soundID)
    }
    
    // MARK: - Sound data
    func data(with soundID: SystemSoundID) -> Data? {
        var soundID = soundID
        let data = Data(bytes:  &soundID, count: MemoryLayout<SystemSoundID>.size)
        return data
    }
    
    func soundID(from data: Data?) -> SystemSoundID {
        
        if data != nil {
            var soundID: UInt8 = 0
            data?.copyBytes(to: &soundID, count: MemoryLayout<SystemSoundID>.size)
            return UInt32(soundID) as SystemSoundID
        }
        return SystemSoundID(0)
    }
    
    // MARK: - Sound files
    func soundID(forFilename filenameKey: String?) -> SystemSoundID {
        
        let soundData: Data? = sounds[filenameKey!]
        return soundID(from: soundData)
    }
    
    func addSoundIDForAudioFile(withName filename: String?, ext: String?) {
        
        let soundID = createSoundID(withName: filename, ext: ext)
        if soundID != 0 && (filename?.count)! > 0 {
            
            let data: Data? = self.data(with: soundID)
            sounds[filename!] = data
        }
    }
    
    // MARK: - Managing sounds
    func createSoundID(withName filename: String?, ext: String?) -> SystemSoundID {
        
        let fileURL: URL? = Bundle.main.url(forResource: filename, withExtension: ext)
        
        if FileManager.default.fileExists(atPath: fileURL?.path ?? "") {
            
            var soundID: SystemSoundID = 0
            let error: OSStatus = AudioServicesCreateSystemSoundID(fileURL! as CFURL, &soundID)
            
            if error != noErr  {
                logError(error, withMessage: "Warning! SystemSoundID could not be created.")
                return SystemSoundID(0)
            } else {
                return soundID
            }
        }
        
        if let anURL = fileURL {
            print("Error: audio file not found at URL: \(anURL)")
        }
        
        return SystemSoundID(0)
    }
    
    func unloadSoundIDs() {
        
        for eachFilename: String? in sounds.keys {
            unloadSoundID(forFileNamed: eachFilename)
        }
        
        sounds.removeAll()
        completionBlocks.removeAll()
    }
    
    func unloadSoundID(forFileNamed filename: String?) {
        
        let soundID = self.soundID(forFilename: filename)
        
        if soundID != 0 {
            AudioServicesRemoveSystemSoundCompletion(soundID)
            
            let error: OSStatus = AudioServicesDisposeSystemSoundID(soundID)
            
            //if error
            
            
            logError(error, withMessage: "Warning! SystemSoundID could not be disposed.")
        }
    }
    
    func logError(_ error: OSStatus, withMessage message: String?) {
        
        var errorMessage: String? = nil
        
        switch error {
        case kAudioServicesUnsupportedPropertyError:
            errorMessage = "The property is not supported."
        case kAudioServicesBadPropertySizeError:
            errorMessage = "The size of the property data was not correct."
        case kAudioServicesBadSpecifierSizeError:
            errorMessage = "The size of the specifier data was not correct."
        case kAudioServicesSystemSoundUnspecifiedError:
            errorMessage = "An unspecified error has occurred."
        case kAudioServicesSystemSoundClientTimedOutError:
            errorMessage = "System sound client message timed out."
        default:
            break
        }
        
        print("\(message ?? "") Error: (code \(Int(error))) \(errorMessage ?? "")")
    }

    
    // MARK: - Did Receive Memory Warning Notification
    @objc func didReceiveMemoryWarning(_ notification: Notification?) {
        unloadSoundIDs()
    }
}
