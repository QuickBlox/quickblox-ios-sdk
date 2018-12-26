//
//  ScreenCapture.swift
//  sample-videochat-webrtc-swift
//
//  Created by Vladimir Nybozhinsky on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

/**
 *  By default sending frames in screen share using BiPlanarFullRange pixel format type.
 *  You can also send them using ARGB by setting this constant to NO.
 */
struct ScreenCaptureConstant {
    static let isUseBiPlanarFormatTypeForShare = true
}

/**
 *  Class implements screen sharing and converting screenshots to destination format
 *  in order to send frames to your opponents
 */
class ScreenCapture: QBRTCVideoCapture {
    
    lazy private var view: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy private var displayLink: CADisplayLink = {
        let displayLink = CADisplayLink()
        return displayLink
    }()
    
    /**
     * Initialize a video capturer view and start grabbing content of given view
     */
    init(view: UIView) {
        super.init()
        
        self.view = view
    }
    
    // MARK: - Enter BG / FG notifications
    @objc func willEnterForeground(_ note: Notification?) {
        displayLink.isPaused = false
    }
    
    @objc func didEnterBackground(_ note: Notification?) {
        displayLink.isPaused = true
    }
    
    // MARK: -
    func screenshot() -> UIImage? {
      
      var image = UIImage()
//            DispatchQueue.main.async {
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 1)
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: false)
//            }
              guard let imageContext = UIGraphicsGetImageFromCurrentImageContext() else {return image}
              UIGraphicsEndImageContext()
              image = imageContext
              
//      }
      
        return image
    }
    
    static let sharedGPUContextSharedContext: CIContext = {
        let options = [CIContextOption.priorityRequestLow: true]
        let sharedContext = CIContext(options: options)
        return sharedContext
    }()
    
    func sharedGPUContext() -> CIContext {
        return ScreenCapture.sharedGPUContextSharedContext
    }
    
    @objc func sendPixelBuffer(_ sender: CADisplayLink?) {
        
        videoQueue.async(execute: {
            
            let image = self.screenshot()
            
            let renderWidth = Int(image?.size.width ?? 0)
            let renderHeight = Int(image?.size.height ?? 0)
            
            var buffer: CVPixelBuffer? = nil
            
            var pixelFormatType: OSType?
            var pixelBufferAttributes: CFDictionary?
            if ScreenCaptureConstant.isUseBiPlanarFormatTypeForShare == true {
                
                pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                pixelBufferAttributes = ([kCVPixelBufferIOSurfacePropertiesKey as String: [:]]) as CFDictionary
            } else {
                
                pixelFormatType = kCVPixelFormatType_32ARGB
                pixelBufferAttributes = [kCVPixelBufferCGImageCompatibilityKey as String: false,
                                         kCVPixelBufferCGBitmapContextCompatibilityKey as String: false] as CFDictionary
            }
            if let pixelFormatType = pixelFormatType {
                let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                                 renderWidth,
                                                 renderHeight,
                                                 pixelFormatType,
                                                 pixelBufferAttributes,
                                                 &buffer)
                
                if let buffer = buffer,
                    status == kCVReturnSuccess {
                    
                    CVPixelBufferLockBaseAddress(buffer, [])
                    
                    guard let image = image,
                        let cgImage = image.cgImage else {
                            return
                    }
                    if let rImage = CIImage(image: image),
                        ScreenCaptureConstant.isUseBiPlanarFormatTypeForShare == true {
                        self.sharedGPUContext().render(rImage, to: buffer)
                        
                    } else {
                        
                        let pxdata = CVPixelBufferGetBaseAddress(buffer)
                        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
                        let context = CGContext(data: pxdata,
                                                width: renderWidth,
                                                height: renderHeight,
                                                bitsPerComponent: 8,
                                                bytesPerRow: renderWidth * 4,
                                                space: rgbColorSpace,
                                                bitmapInfo: bitmapInfo)
                        let rect = CGRect(x: 0, y: 0, width: renderWidth, height: renderHeight)
                        context?.draw(cgImage, in: rect)
                        
                    }
                    
                    CVPixelBufferUnlockBaseAddress(buffer, [])
                    
                    let videoFrame = QBRTCVideoFrame(pixelBuffer: buffer, videoRotation: QBRTCVideoRotation._0)
                    super.send(videoFrame)
                }
            }
        })
        
    }
    
    
    // MARK: - <QBRTCVideoCapture>
    override func didSet(to videoTrack: QBRTCLocalVideoTrack?) {
        super.didSet(to: videoTrack)
        
        displayLink = CADisplayLink(target: self, selector: #selector(sendPixelBuffer(_:)))
        displayLink.add(to: RunLoop.main, forMode: .common)
        displayLink.preferredFramesPerSecond = 12 //5 fps
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground(_:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground(_:)),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    override func didRemove(from videoTrack: QBRTCLocalVideoTrack?) {
        super.didRemove(from: videoTrack)
        
        displayLink.isPaused = true
        displayLink.remove(from: RunLoop.main, forMode: .common)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
    }
    
}

