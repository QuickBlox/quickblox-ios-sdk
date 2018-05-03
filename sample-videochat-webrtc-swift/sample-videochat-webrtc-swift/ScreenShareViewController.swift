//
//  ScreenShareViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import ReplayKit

import QuickbloxWebRTC
import SVProgressHUD

class ScreenShareViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    open var session: QBRTCSession?
    
    var images: [String]!
    var screenCapture: QBRTCVideoCapture!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView?.isPagingEnabled = true
        self.images = ["pres_img_1", "pres_img_2", "pres_img_3"]
        self.view.backgroundColor = UIColor.black
        
        if #available(iOS 11.0, *) {
            self.screenCapture = QBRTCVideoCapture()
            
            RPScreenRecorder.shared().startCapture(handler: { (sampleBuffer, type, error) in
                
                switch type {
                case .video :
                    let source = CMSampleBufferGetImageBuffer(sampleBuffer)
                    let frame = QBRTCVideoFrame(pixelBuffer: source, videoRotation: ._0)
                    self.screenCapture.adaptOutputFormat(toWidth: UInt(UIScreen.main.bounds.width), height: UInt(UIScreen.main.bounds.height), fps: 30)
                    self.screenCapture.send(frame)
                    break
                    
                default:
                    break
                }
                
            }) { (error) in
                if (error != nil) {
                    SVProgressHUD.showError(withStatus: error?.localizedDescription)
                }
            }
        }
        else {
            self.screenCapture = ScreenCapture(view: self.view)
        }
        
        self.session?.localMediaStream.videoTrack.videoCapture = self.screenCapture
        
        self.collectionView?.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0)
        
        if !(self.session?.localMediaStream.videoTrack.isEnabled)! {
            self.session?.localMediaStream.videoTrack.isEnabled = true
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: ShareCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareCollectionViewCell", for: indexPath) as! ShareCollectionViewCell
        cell.setImage(name: self.images[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return self.collectionView!.bounds.size
    }
}
