//
//  SharingViewController.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

private let reuseIdentifier = "SharingCell"
class SharingViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var session: QBRTCSession?
    private var images: [String] = []
    private weak var capture: QBRTCVideoCapture?
    private var enabled = false
    private var screenCapture: ScreenCapture?
    private var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.isPagingEnabled = true
        images = ["pres_img_1", "pres_img_2", "pres_img_3"]
        view.backgroundColor = .black
        if let session = session {
            enabled = session.localMediaStream.videoTrack.isEnabled
            capture = session.localMediaStream.videoTrack.videoCapture
            
            //Switch to sharing
            screenCapture = ScreenCapture(view: view)
            session.localMediaStream.videoTrack.videoCapture = screenCapture
            
        }
        collectionView.contentInset = UIEdgeInsets.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let session = session,
            enabled == false {
            session.localMediaStream.videoTrack.isEnabled = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent == true,
            enabled == false,
            let session = session {
            session.localMediaStream.videoTrack.isEnabled = false
            session.localMediaStream.videoTrack.videoCapture = capture
        }
    }
    
    // MARK: <UICollectionViewDataSource>
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                            for: indexPath) as? SharingCell else {
                                                                return UICollectionViewCell()
        }
        cell.imageName = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if let indexPath = collectionView.indexPathsForVisibleItems.first {
            self.indexPath = indexPath
        }
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        guard let indexPath = indexPath else {
            return
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        self.indexPath = nil
    }
}
