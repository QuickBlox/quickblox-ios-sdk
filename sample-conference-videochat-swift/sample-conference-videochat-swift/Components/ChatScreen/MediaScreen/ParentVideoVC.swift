//
//  ParentVideoVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 11/29/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import AVKit
import Photos
import SVProgressHUD

class ParentVideoVC: UIViewController {
    private lazy var infoItem = UIBarButtonItem(image: UIImage(named: "moreInfo"),
                                                style: .plain,
                                                target: self,
                                                action:#selector(didTapInfo(_:)))
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
        
        navigationItem.rightBarButtonItem = infoItem
        infoItem.tintColor = .white
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

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
    
    @objc private func didTapInfo(_ sender: UIBarButtonItem) {
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: nil)
        guard let popVC = chatStoryboard.instantiateViewController(withIdentifier: "ChatPopVC") as? ChatPopVC else {
            return
        }
        popVC.actions = [.SaveAttachment]
        popVC.modalPresentationStyle = .popover
        let chatPopOverVc = popVC.popoverPresentationController
        chatPopOverVc?.delegate = self
        chatPopOverVc?.barButtonItem = infoItem
        chatPopOverVc?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        popVC.selectedAction = { [weak self] selectedAction in
            guard let _ = selectedAction else {
                return
            }
            self?.saveVideo()
        }
        present(popVC, animated: false)
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            debugPrint("Save error \(error.localizedDescription)")
            SVProgressHUD.showError(withStatus: "Save error")
        } else {
            SVProgressHUD.showSuccess(withStatus: "Saved!")
        }
    }
    
   private func saveVideo() {
        PHPhotoLibrary.requestAuthorization
            { [weak self] (status) -> Void in
                switch (status)
                {
                case .authorized:
                    if let videoURL = self?.videoURL, UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoURL.relativePath) == true {
                        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.relativePath, self, #selector(self?.video(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else {
                        self?.showAlertView("Save error", message: "Video is not compatible With Photos Album")
                    }
                case .denied:
                    // Permission Denied
                    debugPrint("User denied")
                default:
                    debugPrint("Restricted")
                }
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ParentVideoVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
