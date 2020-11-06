//
//  Settings.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/11/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

struct SettingsConstants {
    static let videoFormatKey = "videoFormat"
    static let preferredCameraPosition = "cameraPosition"
    static let mediaConfigKey = "mediaConfig"
}

class Settings {
    
    init() {
        load()
    }
    
    //MARK: - Properties
    var videoFormat = QBRTCVideoFormat.default()
    var mediaConfiguration = QBRTCMediaStreamConfiguration.default()
    var preferredCameraPostion: AVCaptureDevice.Position = .front
    
    //MARK: - Public Methods
    func saveToDisk() {
        // saving to disk
        let defaults = UserDefaults.standard
        do {
            let videFormatData = try NSKeyedArchiver.archivedData(withRootObject: videoFormat, requiringSecureCoding: false)
            let mediaConfig = try NSKeyedArchiver.archivedData(withRootObject: mediaConfiguration, requiringSecureCoding: false)
            defaults.set(preferredCameraPostion.rawValue, forKey: SettingsConstants.preferredCameraPosition)
            defaults.set(videFormatData, forKey: SettingsConstants.videoFormatKey)
            defaults.set(mediaConfig, forKey: SettingsConstants.mediaConfigKey)
            defaults.synchronize()
        } catch {
            print("Couldn't write file to UserDefaults")
        }
    }
    
    func applyConfig() {
        // saving to config
        QBRTCConfig.setMediaStreamConfiguration(mediaConfiguration)
    }
    
    private func load() {
        let defaults = UserDefaults.standard
        let defaultCameraPosition = defaults.integer(forKey: SettingsConstants.preferredCameraPosition)
        if let postion = AVCaptureDevice.Position(rawValue: defaultCameraPosition) {
            preferredCameraPostion = postion == .unspecified ? .front : postion
        }
        do {
            if let videoFormatData = defaults.object(forKey: SettingsConstants.videoFormatKey) as? Data,
               let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(videoFormatData) {
                videoFormat = data as? QBRTCVideoFormat ?? QBRTCVideoFormat.default()
            }
            if let mediaConfigData = defaults.object(forKey: SettingsConstants.mediaConfigKey) as? Data,
               let data = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(mediaConfigData) {
                mediaConfiguration = data as? QBRTCMediaStreamConfiguration ?? QBRTCMediaStreamConfiguration.default()
            }
        } catch {
            print("Couldn't read file from UserDefaults")
        }
        applyConfig()
    }
}
