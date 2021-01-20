//
//  ZoomedAttachmentViewController.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Photos
import SVProgressHUD

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
        dismiss(animated: false, completion: nil)
    }
    
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    @objc private func didTapInfo(_ sender: UIBarButtonItem) {
        guard let actionsMenuVC = ScreenFactory().makeActionsMenuOutput() else { return }
        actionsMenuVC.typeActionsMenuVC = .mediaInfo
        actionsMenuVC.modalPresentationStyle = .overFullScreen
        
        let saveAttachmentAction = MenuAction(title: "Save attachment", action: .saveAttachment) { [weak self] (action) in
            guard let image = self?.zoomImageView.image else {
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
        actionsMenuVC.addAction(saveAttachmentAction)
        
        present(actionsMenuVC, animated: false)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            SVProgressHUD.showError(withStatus: "Save error")
        } else {
            SVProgressHUD.showSuccess(withStatus: "Saved!")
        }
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ZoomedAttachmentViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
