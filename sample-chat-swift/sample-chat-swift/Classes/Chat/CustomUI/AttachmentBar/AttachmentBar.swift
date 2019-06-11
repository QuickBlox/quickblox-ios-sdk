//
//  AttachmentBar.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

protocol AttachmentBarDelegate: class {
    func attachmentBarFailedUpLoadImage(_ attachmentBar: AttachmentBar);
    func attachmentBar(_ attachmentBar: AttachmentBar, didUpLoadAttachment  attachment: QBChatAttachment)
    func attachmentBar(_ attachmentBar: AttachmentBar, didTapCancelButton: UIButton)
}

class AttachmentBar: UIView {
    
    //MARK: - Properties
    weak var delegate: AttachmentBarDelegate?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.setRoundedView(cornerRadius: 8.0)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20.0).isActive = true
        imageView.topAnchor.constraint(equalTo: topAnchor, constant: 10.0).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var progressLabel: UILabel = {
        let progressLabel = UILabel()
        progressLabel.textAlignment = .center
        progressLabel.font = .systemFont(ofSize: 16.0)
        progressLabel.textColor = .white
        imageView.addSubview(progressLabel)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        progressLabel.leftAnchor.constraint(equalTo: imageView.leftAnchor).isActive = true
        progressLabel.rightAnchor.constraint(equalTo: imageView.rightAnchor).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        progressLabel.heightAnchor.constraint(equalToConstant: 40.0).isActive = true
        return progressLabel
    }()
    
    lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setImage(UIImage(named: "ic_cancel"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
        cancelButton.tintColor = .white
        cancelButton.isEnabled = true
        addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -2.0).isActive = true
        cancelButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 2.0).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(_:)), for: .touchUpInside)
        cancelButton.isHidden = true
        return cancelButton
    }()
    
    //MARK: - Actions
    /**
     *  This method is called when the user finishes picking attachment image.
     *
     *  @param image    image that was picked by user
     */
    func uploadAttachmentImage(_ image: UIImage, sourceType: UIImagePickerController.SourceType) {
        
        imageView.image = image;
        cancelButton.isHidden = true;
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            guard let self = self else { return }
            
            var newImage = image
            if sourceType == .camera {
                newImage = newImage.fixOrientation()
            }
            
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
            
            // create smaller image
            UIGraphicsBeginImageContext(newSize)
            
            newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // Sending attachment.
            DispatchQueue.main.async(execute: {
                // sendAttachmentMessage method always firstly adds message to memory storage
                guard let imageData = resizedImage?.pngData() else {
                    return
                }
                QBRequest.tUploadFile(imageData, fileName: "test.png",
                                      contentType: "image/png", isPublic: false,
                                      successBlock: { [weak self] (response: QBResponse, uploadedBlob: QBCBlob) -> Void in
                                        guard let self = self else {
                                                return
                                        }
                                        let attachment = QBChatAttachment()
                                        if let privateUrl = uploadedBlob.privateUrl() {
                                            attachment.url = privateUrl
                                        } else if let publicUrl = uploadedBlob.publicUrl() {
                                            attachment.url = publicUrl
                                        } else {
                                            return
                                        }
                                        attachment.id = uploadedBlob.uid
                                        attachment.name = uploadedBlob.name
                                        attachment.type = "image"
                                        
                                        self.delegate?.attachmentBar(self, didUpLoadAttachment: attachment)
                                        
                    }, statusBlock: { [weak self] (request : QBRequest?, status : QBRequestStatus?) -> Void in
                        if let status = status {
                            DispatchQueue.main.async {
                                let progress = CGFloat(Float(status.percentOfCompletion))
                                self?.updateLoadingProgress(progress)
                            }
                        }
                }) { [weak self] (response : QBResponse) -> Void in
                    guard let self = self else {
                        return
                    }
                    self.delegate?.attachmentBarFailedUpLoadImage(self)

                }
            })
        }
    }
    
    
    @objc func cancelButtonPressed(_ sender: UIButton) {
        cancelButton.isHidden = true
        delegate?.attachmentBar(self, didTapCancelButton: sender)
    }
    
    func updateLoadingProgress(_ progress: CGFloat) {
        if progress > 0.0 {
            progressLabel.isHidden = false
            progressLabel.text = String(format: "%2.0f %%", progress * 100.0)
        }
        if progress > 0.99 {
            progressLabel.isHidden = true
            cancelButton.isHidden = false
        }
    }
}
