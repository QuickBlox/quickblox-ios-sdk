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
import ReplayKit

struct SharingConstant {
   static let reuseIdentifier = "SharingCell"
}

class SharingViewController: BaseViewController, UICollectionViewDelegateFlowLayout, SharingView {
    
    var isReplayKit = true
    var session: QBRTCConferenceSession?
    private var images: [String] = []
    private weak var capture: QBRTCVideoCapture?
    private var enabled = false
    private var screenCapture: QBRTCVideoCapture?
    private var oldScreenCapture: ScreenCapture?
    private var indexPath: IndexPath?
    private var toolbarHideTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureGUI()
        
        images = ["pres_img_1", "pres_img_2", "pres_img_3"]
        view.backgroundColor = .black
        if let session = session {
            enabled = session.localMediaStream.videoTrack.isEnabled
            capture = session.localMediaStream.videoTrack.videoCapture

            if isReplayKit == true {
                screenCapture = QBRTCVideoCapture()
                session.localMediaStream.videoTrack.videoCapture = screenCapture
                startScreenSharing()
            } else {
                oldScreenCapture = ScreenCapture(view: view)
                session.localMediaStream.videoTrack.videoCapture = oldScreenCapture
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showControls(true)
        if let session = session {
            session.localMediaStream.videoTrack.isEnabled = true
        }
    }

    override func setupCollectionView() {
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.isPrefetchingEnabled = true
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .black
        collectionView.register(UINib(nibName: SharingConstant.reuseIdentifier, bundle: nil),
                                forCellWithReuseIdentifier: SharingConstant.reuseIdentifier)

    }
    
    override func configureNavigationBarItems() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: self,
                                                           action: nil)
        navigationItem.leftBarButtonItem?.tintColor = .clear
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    override func configureToolBar() {
        let screenShareEnabled = ButtonsFactory.screenShare()
        screenShareEnabled.pressed = true
        toolbar.add(screenShareEnabled, action: { [weak self] sender in
            guard let self = self else {
                return
            }
            if self.isReplayKit == true {
                self.stopScreenSharing()
            }
            self.session?.localMediaStream.videoTrack.videoCapture = self.capture
            self.invalidateHideToolbarTimer()
            self.navigationController?.popViewController(animated: true)
        })
        toolbar.updateItems()
    }
    
    private func stopScreenSharing() {
        let recorder = RPScreenRecorder.shared()
       recorder.stopCapture { error in
            if let error = error {
                debugPrint("self.recorder.stopCapture \(error.localizedDescription)")
            }
        }
    }
    
    private func startScreenSharing() {
        let recorder = RPScreenRecorder.shared()
        recorder.startCapture(handler: { (sampleBuffer, type, error) in
            if error != nil {
                    print("Capture error: ", error as Any)
                    return
                }

            switch type {
            case .video :
                let source = CMSampleBufferGetImageBuffer(sampleBuffer)
                let videoFrame = QBRTCVideoFrame(pixelBuffer: source, videoRotation: QBRTCVideoRotation._0)
                self.screenCapture?.send(videoFrame)
            default:
                break
            }
            
        }) { error in
            if let error = error {
                debugPrint("self.recorder.startCapture \(error.localizedDescription)")
            } else {
                print("Screen capture started.")
            }
        }
    }
    
    // MARK: <UICollectionViewDataSource>
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SharingConstant.reuseIdentifier,
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
    
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        showControls(true)
    }
}
