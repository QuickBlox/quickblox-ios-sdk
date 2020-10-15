//
//  AttachmentUploadBar.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/8/20.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import UIKit

protocol AttachmentBarDelegate: class {
    func attachmentBarFailedUpLoadImage(_ attachmentBar: AttachmentUploadBar);
    func attachmentBar(_ attachmentBar: AttachmentUploadBar, didUpLoadAttachment  attachment: QBChatAttachment)
    func attachmentBar(_ attachmentBar: AttachmentUploadBar, didTapCancelButton: UIButton)
}

class AttachmentUploadBar: UIView {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var progressBar: CircularProgressBar!
    @IBOutlet weak var attachmentImageView: UIImageView!
    
    //MARK: - Properties
    weak var delegate: AttachmentBarDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cancelButton.isHidden = true
        progressBar.isHidden = true
        attachmentImageView.setRoundedView(cornerRadius: 8.0)
        attachmentImageView.contentMode = .scaleAspectFill
        self.setRoundBorderEdgeColorView(cornerRadius: 0.0, borderWidth: 0.5, borderColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        
    }
    
    //MARK: - Actions
    /**
     *  This method is called when the user finishes picking attachment image.
     *
     *  @param image    image that was picked by user
     */
    func uploadAttachmentImage(_ asset: PhotoAsset, url: URL? = nil, attachmentType: AttachmentType) {
        
        attachmentImageView.image = asset.image;
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            guard let self = self else { return }
            if let url = url {
                let name = FileManager.default.displayName(atPath: url.path)
                if attachmentType == .Video {
                    DispatchQueue.main.async(execute: {
                        QBRequest.uploadFile(with: url, fileName: name, contentType: "video/mp4", isPublic: true,
                                             successBlock: { [weak self] (response: QBResponse, uploadedBlob: QBCBlob) -> Void in
                                                guard let self = self else {
                                                    return
                                                }
                                                let attachment = QBChatAttachment()
                                                attachment.id = uploadedBlob.uid
                                                attachment.name = uploadedBlob.name
                                                attachment.type = "video"
                                                attachment["size"] = "\(uploadedBlob.size)"
                                                
                                                self.progressBar.isHidden = true
                                                self.cancelButton.isHidden = false
                                                self.delegate?.attachmentBar(self, didUpLoadAttachment: attachment)
                                                
                            }, statusBlock: { [weak self] (request : QBRequest?, status : QBRequestStatus?) -> Void in
                                if let status = status {
                                    DispatchQueue.main.async {
                                        let progress = CGFloat(status.percentOfCompletion)
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
                    
                } else if attachmentType == .File {
                    DispatchQueue.main.async(execute: {
                        QBRequest.uploadFile(with: url, fileName: name, contentType: "application/pdf", isPublic: true,
                                             successBlock: { [weak self] (response: QBResponse, uploadedBlob: QBCBlob) -> Void in
                                                guard let self = self else {
                                                    return
                                                }
                                                let attachment = QBChatAttachment()
                                                attachment.id = uploadedBlob.uid
                                                attachment.name = uploadedBlob.name
                                                attachment.type = "file"
                                                attachment["size"] = "\(uploadedBlob.size)"
                                                
                                                self.progressBar.isHidden = true
                                                self.cancelButton.isHidden = false
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
                
            } else {
                
                var name = "Test.png"
                if let fileName = asset.phAsset.value(forKey: "filename") as? String{
                    name = fileName
                }
                
                var newImage = asset.image
                if attachmentType == .Camera {
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
                    guard let imageData = resizedImage?.pngData() else {
                        return
                    }
                    QBRequest.tUploadFile(imageData, fileName: name,
                                          contentType: "image/png", isPublic: true,
                                          successBlock: { [weak self] (response: QBResponse, uploadedBlob: QBCBlob) -> Void in
                                            guard let self = self else {
                                                return
                                            }
                                            let attachment = QBChatAttachment()
                                            attachment.id = uploadedBlob.uid
                                            attachment.name = uploadedBlob.name
                                            attachment.type = "image"
                                            attachment["size"] = "\(uploadedBlob.size)"
                                            
                                            self.progressBar.isHidden = true
                                            self.cancelButton.isHidden = false
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
    }
    
    func updateLoadingProgress(_ progress: CGFloat) {
        if progressBar.isHidden == true {
            progressBar.isHidden = false
        }
        progressBar.setProgress(to: progress)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        cancelButton.isHidden = true
        delegate?.attachmentBar(self, didTapCancelButton: sender)
    }
    
}
