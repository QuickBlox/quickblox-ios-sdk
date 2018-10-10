//
//  Settings.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 09.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

struct SettingsConstants {
    static let  kVideoFormatKey = "videoFormat"
    static let  kPreferredCameraPosition = "cameraPosition"
    static let  kMediaConfigKey = "mediaConfig"
}

class Settings {
    
    // MARK: shared Instance
    static let instance = Settings()
    
    var videoFormat: QBRTCVideoFormat?
    var mediaConfiguration: QBRTCMediaStreamConfiguration?
    var preferredCameraPostion: AVCaptureDevice.Position?
    
    public func saveToDisk() {
        
        // saving to disk
        let defaults = UserDefaults.standard
        let videFormatData = NSKeyedArchiver.archivedData(withRootObject: videoFormat as Any)
        let mediaConfig = NSKeyedArchiver.archivedData(withRootObject: mediaConfiguration as Any)
        
        defaults.set(preferredCameraPostion, forKey: SettingsConstants.kPreferredCameraPosition)
        
        defaults.set(videFormatData, forKey: SettingsConstants.kVideoFormatKey)
        defaults.set(mediaConfig, forKey: SettingsConstants.kMediaConfigKey)
        
        defaults.synchronize()
    }
    
    public func applyConfig() {
        
        // saving to config
        guard let mediaConfiguration = self.mediaConfiguration else { return }
        QBRTCConfig.setMediaStreamConfiguration(mediaConfiguration)
    }
    
    func load() {
        
        let defaults = UserDefaults.standard
        
        var postion = AVCaptureDevice.Position(rawValue: defaults.integer(forKey: SettingsConstants.kPreferredCameraPosition))
        
        if postion == .unspecified {
            //First launch
            postion = .front
        }
        
        preferredCameraPostion = postion
        
        let videoFormatData = defaults.object(forKey: SettingsConstants.kVideoFormatKey) as? Data
        if videoFormatData != nil {
            
            if let aData = videoFormatData, let aData1 = NSKeyedUnarchiver.unarchiveObject(with: aData) {
                videoFormat = aData1 as? QBRTCVideoFormat
            }
        } else {
            
            videoFormat = QBRTCVideoFormat.default()
        }
        
        let mediaConfigData = defaults.object(forKey: SettingsConstants.kMediaConfigKey) as? Data
        
        if mediaConfigData != nil {
            if let aData = mediaConfigData {
                mediaConfiguration = NSKeyedUnarchiver.unarchiveObject(with: aData) as? QBRTCMediaStreamConfiguration
            }
            applyConfig()
        } else {
            
            mediaConfiguration = QBRTCMediaStreamConfiguration.default()
        }
    }
}
