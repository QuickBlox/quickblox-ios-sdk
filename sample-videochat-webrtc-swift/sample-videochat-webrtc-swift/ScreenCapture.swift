//
//  ScreenCapture.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

import QuickbloxWebRTC

class ScreenCapture: QBRTCVideoCapture {
    
    /**
     *  By default sending frames in screen share using BiPlanarFullRange pixel format type.
     *  You can also send them using ARGB by setting this constant to NO.
     */
    let useBiPlanarFormatTypeForShare = true
    
    var view: UIView?
    var displayLink: CADisplayLink!
    
    private lazy var sharedGPUContext: CIContext = {
        CIContext.init(options: [kCIContextPriorityRequestLow : true])
    }()
    
    // MARK: Construction
    
    init(view: UIView) {
        self.view = view
    }
    
    // MARK: Enter BG / FG notifications
    
    @objc func willEnterForeground(notification: NSNotification!) {
        self.displayLink.isPaused = false
    }
    
    @objc func didEnterBackground(notification: NSNotification!) {
        self.displayLink.isPaused = true
    }
    
    // MARK: Functions
    
    func screenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.view!.frame.size, true, 1)
        self.view?.drawHierarchy(in: self.view!.bounds, afterScreenUpdates: false)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    @objc func sendPixelBuffer(sender: CADisplayLink) {
        
        self.videoQueue.async {
            
            autoreleasepool{
                
                let image = self.screenshot()
                
                let renderWidth = image.size.width
                let renderHeight = image.size.height
                
                var buffer: CVPixelBuffer? = nil
                
                var pixelFormatType: OSType?
                var pixelBufferAttributes: CFDictionary? = nil
                
                if self.useBiPlanarFormatTypeForShare {
                    pixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                    pixelBufferAttributes = [
                        String(kCVPixelBufferIOSurfacePropertiesKey) : [:]
                        ] as CFDictionary
                }
                else {
                    pixelFormatType = kCVPixelFormatType_32ARGB
                    pixelBufferAttributes = [
                        String(kCVPixelBufferCGImageCompatibilityKey) : false,
                        String(kCVPixelBufferCGBitmapContextCompatibilityKey) : false
                        ] as CFDictionary
                }
                
                let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(renderWidth), Int(renderHeight), pixelFormatType!, pixelBufferAttributes, &buffer)
                
                if status == kCVReturnSuccess && buffer != nil {
                    
                    CVPixelBufferLockBaseAddress(buffer!, CVPixelBufferLockFlags(rawValue: 0))
                    
                    if self.useBiPlanarFormatTypeForShare {
                        
                        let rImage = CIImage.init(image: image)
                        self.sharedGPUContext.render(rImage!, to: buffer!)
                    }
                    else {
                        
                        let pxdata = CVPixelBufferGetBaseAddress(buffer!)
                        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                        
                        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
                            .union(.byteOrder32Little)
                        
                        let context = CGContext(data: pxdata, width: Int(renderWidth), height: Int(renderHeight), bitsPerComponent: 8, bytesPerRow: Int(renderWidth * 4), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
                        
                        context?.draw(image.cgImage!, in: CGRect(x: 0.0, y: 0.0, width: renderWidth, height: renderHeight))
                    }
                    
                    CVPixelBufferUnlockBaseAddress(buffer!, CVPixelBufferLockFlags(rawValue: 0))
                    
                    let videoFrame = QBRTCVideoFrame(pixelBuffer: buffer, videoRotation: QBRTCVideoRotation._0)
                    
                    super.send(videoFrame)
                }
            }
        }
    }
    
    // MARK: QBRTCVideoCapture
    
    override func didSet(to videoTrack: QBRTCLocalVideoTrack!) {
        super.didSet(to: videoTrack)
        
        self.displayLink = CADisplayLink.init(target: self, selector: #selector(sendPixelBuffer(sender:)))
        self.displayLink.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        self.displayLink.frameInterval = 12 //5 fps
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(notification:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground(notification:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    override func didRemove(from videoTrack: QBRTCLocalVideoTrack!) {
        super.didRemove(from: videoTrack)
        
        self.displayLink.isPaused = true
        self.displayLink.remove(from: RunLoop.main, forMode: RunLoopMode.commonModes)
        self.displayLink = nil
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
}
