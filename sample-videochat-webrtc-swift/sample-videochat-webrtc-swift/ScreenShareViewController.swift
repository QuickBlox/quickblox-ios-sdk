//
//  ScreenShareViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

import QuickbloxWebRTC

class ScreenShareViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    open var session: QBRTCSession?
    
    var images: [String]!
    var screenCapture: ScreenCapture!
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView?.isPagingEnabled = true
        self.images = ["pres_img_1", "pres_img_2", "pres_img_3"]
        self.view.backgroundColor = UIColor.black
        
        self.screenCapture = ScreenCapture(view: self.view)
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
