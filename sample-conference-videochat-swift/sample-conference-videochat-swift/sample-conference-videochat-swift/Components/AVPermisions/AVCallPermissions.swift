//
//  AVCallPermissions.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import QuickbloxWebRTC

struct AVCallErrorConstant {
    static let cameraErrorTitle = NSLocalizedString("Camera error", comment: "")
    static let cameraErrorMessage = NSLocalizedString("The app doesn't have access to the camera, please go to settings and enable it.", comment: "")
    static let microphoneErrorTitle = NSLocalizedString("Microphone error", comment: "")
    static let microphoneErrorMessage = NSLocalizedString("The app doesn't have access to the microphone, please go to settings and enable it.", comment: "")
    static let alertCancelAction = NSLocalizedString("Cancel", comment: "")
    static let alertSettingsAction = NSLocalizedString("Settings", comment: "")
}

class AVCallPermissions {
    
    class func check(with conferenceType: QBRTCConferenceType, completion: @escaping PermissionBlock) {
        
        #if targetEnvironment(simulator)
        completion(true)
        return
        #endif
        
        self.requestPermissionToMicrophone(withCompletion: { granted in
            guard granted == true else {
                showAlert(withTitle: AVCallErrorConstant.microphoneErrorTitle,
                          message: AVCallErrorConstant.microphoneErrorMessage)
                completion(granted)
                return
            }
            switch conferenceType {
            case .audio: completion(granted)
            case .video:
                requestPermissionToCamera(withCompletion: { videoGranted in
                    if videoGranted == false {
                        showAlert(withTitle: AVCallErrorConstant.cameraErrorTitle,
                                  message: AVCallErrorConstant.cameraErrorMessage)
                    }
                    completion(videoGranted)
                })
            }
        })
    }
    
    class func requestPermissionToMicrophone(withCompletion completion: @escaping PermissionBlock) {
        AVAudioSession.sharedInstance().requestRecordPermission({ granted in
            DispatchQueue.main.async(execute: {
                completion(granted)
            })
        })
    }
    
    class func requestPermissionToCamera(withCompletion completion: @escaping PermissionBlock) {
        let mediaType = AVMediaType.video
        let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { granted in
                DispatchQueue.main.async(execute: {
                    completion(granted)
                })
            })
        case .restricted, .denied:
            completion(false)
        case .authorized:
            completion(true)
        }
    }
    
    // MARK: - Helpers
    // showing error alert with a suggestion
    // to go to the settings
    class func showAlert(withTitle title: String?, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: AVCallErrorConstant.alertCancelAction,
                                                style: .cancel))
        alertController.addAction(UIAlertAction(title: AVCallErrorConstant.alertSettingsAction,
                                                style: .default,
                                                handler: { action in
                                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                                        UIApplication.shared.open(url, options: [:])
                                                    }
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
    }
}

