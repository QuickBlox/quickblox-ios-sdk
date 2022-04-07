//
//  ZoomedAttachmentViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Photos

class ZoomedAttachmentViewController: UIViewController {
    //MARK: - Properties
    let zoomImageView = UIImageView()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        
        let saveAttachmentAction = UIAction(title: "Save attachment") { [weak self]  action in
            guard let self = self else { return }
            guard let image = self.zoomImageView.image else {
                return
            }
            PHPhotoLibrary.requestAuthorization
                { [weak self] (status) -> Void in
                    switch (status)
                    {
                    case .authorized:
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self?.image(_:didFinishSavingWithError:contextInfo:)), nil)
                    case .denied:
                        // Permission Denied
                        debugPrint("[ZoomedAttachmentViewController] User denied")
                    default:
                        debugPrint("[ZoomedAttachmentViewController] Restricted")
                    }
            }
        }
        let menu = UIMenu(title: "", children: [saveAttachmentAction])
        let infoItem = UIBarButtonItem(image: UIImage(named: "moreInfo"),
                                                    menu: menu)
        navigationItem.rightBarButtonItem = infoItem
        infoItem.tintColor = .white
        
        view.backgroundColor = .black
        zoomImageView.contentMode = .scaleAspectFit
        view.addSubview(zoomImageView)
        let navigationBarHeight = self.navigationController?.navigationBar.frame.size.height ?? 44.0
        zoomImageView.translatesAutoresizingMaskIntoConstraints = false
        zoomImageView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        zoomImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        zoomImageView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        zoomImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(navigationBarHeight)).isActive = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBackAction(_ :)))
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Actions
    @objc private func goBackAction(_ sender: UITapGestureRecognizer) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            showAnimatedAlertView(nil, message: "Save error")
        } else {
            showAnimatedAlertView(nil, message: "Saved!")
        }
    }
}
