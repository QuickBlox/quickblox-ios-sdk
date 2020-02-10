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
    
    private lazy var infoItem = UIBarButtonItem(image: UIImage(named: "moreInfo"),
                                                style: .plain,
                                                target: self,
                                                action:#selector(didTapInfo(_:)))
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
        
        navigationItem.rightBarButtonItem = infoItem
        infoItem.tintColor = .white
        
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
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
        dismiss(animated: true, completion: nil)
    }
    
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
            self?.saveImage()
        }
        present(popVC, animated: false)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            SVProgressHUD.showError(withStatus: "Save error")
        } else {
            SVProgressHUD.showSuccess(withStatus: "Saved!")
        }
    }
    
    func saveImage() {
        guard let image = zoomImageView.image else {
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
                    debugPrint("User denied")
                default:
                    debugPrint("Restricted")
                }
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ZoomedAttachmentViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
