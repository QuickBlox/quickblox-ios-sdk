//
//  ScreenCapture.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import QuickbloxWebRTC

struct ScreenCaptureConstant {
    /**
     *  By default sending frames in screen share using BiPlanarFullRange pixel format type.
     *  You can also send them using ARGB by setting this constant to NO.
     */
    static let isUseBiPlanarFormatTypeForShare = true
}

/**
 *  Class implements screen sharing and converting screenshots to destination format
 *  in order to send frames to your opponents
 */
class ScreenCapture: QBRTCVideoCapture {
    
    //MARK: - Properties
    private var view = UIView()
    private var displayLink = CADisplayLink()
    
    static let sharedGPUContextSharedContext: CIContext = {
        let options = [CIContextOption.priorityRequestLow: true]
        let sharedContext = CIContext(options: options)
        return sharedContext
    }()
    
    //MARK: - Life Cycle
    /**
     * Initialize a video capturer view and start grabbing content of given view
     */
    init(view: UIView) {
        super.init()
        
        self.view = view
    }
    
    private func sharedContext() -> CIContext {
        return ScreenCapture.sharedGPUContextSharedContext
    }
    
   //MARK: - Enter Background / Fofeground notifications
    @objc func willEnterForeground(_ note: Notification?) {
        displayLink.isPaused = false
    }
    
    @objc func didEnterBackground(_ note: Notification?) {
        displayLink.isPaused = true
    }
    
    //MARK: - Internal Methods
    func screenshot() -> UIImage? {
        let layer = view.layer
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, true, 1);
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in:context)
        let screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshotImage
    }
    
    
    @objc private func sendPixelBuffer(_ sender: CADisplayLink?) {
        guard let image = self.screenshot() else {
            return
        }
        videoQueue.async(execute: { [weak self] in
            guard let self = self else {
                return
            }
            let renderWidth = Int(image.size.width)
            let renderHeight = Int(image.size.height)
            var pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
            var pixelBufferAttributes = [kCVPixelBufferIOSurfacePropertiesKey: [:]] as CFDictionary
            if ScreenCaptureConstant.isUseBiPlanarFormatTypeForShare == false {
                pixelFormatType = kCVPixelFormatType_32ARGB
                pixelBufferAttributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanFalse,
                                         kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanFalse] as CFDictionary
            }
            var pixelBuffer: CVPixelBuffer?
            let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                             renderWidth,
                                             renderHeight,
                                             pixelFormatType,
                                             pixelBufferAttributes,
                                             &pixelBuffer)
            if status != kCVReturnSuccess {
                return
            }
            guard let buffer = pixelBuffer else {
                return
            }
            
            CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            
            if let renderImage = CIImage(image: image),
                ScreenCaptureConstant.isUseBiPlanarFormatTypeForShare == true {
                self.sharedContext().render(renderImage, to: buffer)
            } else if let cgImage = image.cgImage {
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
            
            CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
            
            let videoFrame = QBRTCVideoFrame(pixelBuffer: buffer, videoRotation: QBRTCVideoRotation._0)
            self.send(videoFrame)
        })
        
    }
    
    // MARK: - <QBRTCVideoCapture>
    override func didSet(to videoTrack: QBRTCLocalVideoTrack?) {
        super.didSet(to: videoTrack)
        
        displayLink = CADisplayLink(target: self, selector: #selector(sendPixelBuffer(_:)))
        displayLink.add(to: .main, forMode: .common)
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
        displayLink.remove(from: .main, forMode: .common)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.willEnterForegroundNotification,
                                                  object: nil)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
    }
}
