//
//  ParentVideoVC.swift
//  sample-chat-swift
//
//  Created by Injoit on 11/29/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import AVKit
import Photos

class ParentVideoVC: UIViewController {
    var videoURL: URL?
    let vc = AVPlayerViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        let saveAttachmentAction = UIAction(title: "Save attachment") { [weak self]  action in
            PHPhotoLibrary.requestAuthorization
                { [weak self] (status) -> Void in
                    switch (status)
                    {
                    case .authorized:
                        if let videoURL = self?.videoURL, UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.relativePath) == true {
                            UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, #selector(self?.video(_:didFinishSavingWithError:contextInfo:)), nil)
                        } else {
                            self?.showAlertView("Save error", message: "Video is not compatible With Photos Album", handler: nil)
                        }
                    case .denied:
                        // Permission Denied
                        debugPrint("[ParentVideoVC] User denied")
                    default:
                        debugPrint("[ParentVideoVC] Restricted")
                    }
            }
        }
        let menu = UIMenu(title: "", children: [saveAttachmentAction])
        let infoItem = UIBarButtonItem(image: UIImage(named: "moreInfo"),
                                                    menu: menu)
        navigationItem.rightBarButtonItem = infoItem
        infoItem.tintColor = .white

        guard let videoURL = videoURL else {
            return
        }
        
        let player = AVPlayer(url: videoURL)
        vc.player = player
        
        self.view.addSubview(vc.view)
        self.addChild(vc)
        vc.didMove(toParent: self)
        vc.player?.play()
    }
    
    //MARK: - Actions
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            debugPrint("[ParentVideoVC] Save error \(error.localizedDescription)")
            showAnimatedAlertView(nil, message: "Save error")
        } else {
            showAnimatedAlertView(nil, message: "Saved!")
        }
    }
}
