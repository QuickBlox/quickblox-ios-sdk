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

class SharingViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var actionsBar: CallActionsBar!
    @IBOutlet weak var bottomView: CallGradientView! {
        didSet {
            bottomView.setupGradient(firstColor: UIColor.black.withAlphaComponent(0.0),
                                     secondColor: UIColor.black.withAlphaComponent(0.7))
        }
    }

    //MARK: - Properties
    private var images: [String] = []
    var media: MediaRouter!

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        actionsBar.setup(withActions: [
            (.share, action: { [weak self] sender in
                guard let self = self else {
                    return
                }
                let recorder = RPScreenRecorder.shared()
                recorder.stopCapture { [weak self] error in
                    if let error = error {
                        debugPrint("\(#function) recorder stopCapture error \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        self?.media.sharingEnabled = false
                        self?.navigationController?.popViewController(animated: false)
                    }
                }
            })
        ])
        
        actionsBar.select(true, type: .share)
        
        images = ["pres_img_1", "pres_img_2", "pres_img_3"]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startSharing()
    }

    //MARK: - Private Methods
    private func startSharing() {
        RPScreenRecorder.shared().startCapture { [weak self] (sampleBuffer, type, error) in
            guard let self = self else { return }
            if error != nil {
                debugPrint("\(#function) Capture error: ", error as Any)
                return
            }

            switch type {
            case .video :
                if let source = CMSampleBufferGetImageBuffer(sampleBuffer) {
                    self.media.sendScreenContent(source)
                }
            default:
                break
            }

        } completionHandler: { [weak self] (error) in
            guard let self = self else { return }
            if let error = error {
                debugPrint("\(#function) recorder startCapture error: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                let videoFormat = VideoFormat(width: UInt(UIScreen.main.bounds.width),
                                              height: UInt(UIScreen.main.bounds.height),
                                              fps: 12)
                self.media.startScreenSharing(withFormat: videoFormat)
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: <UICollectionViewDataSource>
extension SharingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    func collectionView(_ collectionView: UICollectionView,
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
}
