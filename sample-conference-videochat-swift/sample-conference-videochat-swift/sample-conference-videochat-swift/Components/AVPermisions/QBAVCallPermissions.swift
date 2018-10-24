//
//  QBAVCallPermissions.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 04.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import Foundation
import QuickbloxWebRTC

class QBAVCallPermissions {
    
    class func check(with conferenceType: QBRTCConferenceType, completion: @escaping PermissionBlock) {
        
        #if targetEnvironment(simulator)
        // Simulator
        completion(true)
        return
        #else
        // Device
        #endif
        
        self.requestPermissionToMicrophone(withCompletion: { granted in
            
            if granted {
                
                switch conferenceType {
                case .audio:
  
                        completion(granted)

                case .video:
                    
                    self.requestPermissionToCamera(withCompletion: { videoGranted in
                        
                        if !videoGranted {
                            
                            // showing error alert with a suggestion
                            // to go to the settings
                            self.showAlert(withTitle: NSLocalizedString("Camera error", comment: ""), message: NSLocalizedString("The app doesn't have access to the camera, please go to settings and enable it.", comment: ""))
                        }
                            completion(videoGranted)
                    })
                default:
                    break
                }
            } else {
                // showing error alert with a suggestion
                // to go to the settings
                self.showAlert(withTitle: NSLocalizedString("Microphone error", comment: ""), message: NSLocalizedString("The app doesn't have access to the microphone, please go to settings and enable it.", comment: ""))

                    completion(granted)
            }
        })
    }
    
    class func requestPermissionToMicrophone(withCompletion completion: @escaping PermissionBlock) {
        
        AVAudioSession.sharedInstance().requestRecordPermission({ granted in
            //if completion
            DispatchQueue.main.async(execute: {
                completion(granted)
            })
        })
    }
    
    class func requestPermissionToCamera(withCompletion completion: @escaping PermissionBlock) {
        
        let mediaType = AVMediaType.video
        let authStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
        switch authStatus {
        case .notDetermined:
            
            AVCaptureDevice.requestAccess(for: mediaType, completionHandler: { granted in
                
                //if completion
                
                DispatchQueue.main.async(execute: {
                    completion(granted)
                })
                
            })
        case .restricted, .denied:
            //if completion
            
            completion(false)
        case .authorized:
            //if completion
            
            completion(true)
        default:
            break
        }
    }
    // MARK: - Helpers
    class func showAlert(withTitle title: String?, message: String?) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { action in
            //Empty action
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: .default, handler: { action in
            
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)

            if let url = settingsUrl {
              UIApplication.shared.open(url, options: [:])
            }
        }))
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true)
    }
}

