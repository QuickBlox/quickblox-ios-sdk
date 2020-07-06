//
//  ChatAttachmentCell.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import AVFoundation
import Quickblox
import SVProgressHUD

class ChatAttachmentCell: ChatCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var forwardInfoView: UIView!
    @IBOutlet weak var forwardInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var forwardedLabel: UILabel!
    @IBOutlet weak var progressView: CircularProgressBar!
    @IBOutlet weak var attachmentInfoView: UIView!
    @IBOutlet weak var attachmentNameLabel: UILabel!
    @IBOutlet weak var attachmentSizeLabel: UILabel!
    @IBOutlet weak var attachmentContainerView: UIView!
    @IBOutlet weak var bottomInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoTopLineView: UIView!
    /**
     *  Attachment image view.     */
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var typeAttachmentImageView: UIImageView!
    //MARK: - Properties
    var attachmentUrl: URL?
    private var attachmentID: String = ""
    private var attachmentDownloadManager = AttachmentDownloadManager()
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        attachmentContainerView.layer.applyShadow(color: #colorLiteral(red: 0.8452011943, green: 0.8963350058, blue: 1, alpha: 1), alpha: 1.0, y: 3.0, blur: 48.0)
        attachmentImageView.backgroundColor = #colorLiteral(red: 0.7999122739, green: 0.8000505567, blue: 0.799903512, alpha: 1)
        attachmentImageView.contentMode = .scaleAspectFill
        infoTopLineView.backgroundColor = .clear
        playImageView.isHidden = true
        bottomInfoHeightConstraint.constant = 0
        forwardInfoHeightConstraint.constant = 0
        attachmentID = ""
        attachmentSizeLabel.text = ""
        progressView.isHidden = true
    }
    
    override class func layoutModel() -> ChatCellLayoutModel {
        var defaultLayoutModel = super.layoutModel()
        defaultLayoutModel.avatarSize = .zero;
        defaultLayoutModel.containerInsets = UIEdgeInsets(top: 0.0,
                                                          left: 16.0,
                                                          bottom: 0.0,
                                                          right: 16.0)
        defaultLayoutModel.topLabelHeight = 15.0;
        defaultLayoutModel.timeLabelHeight = 15.0;
        return defaultLayoutModel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        typeAttachmentImageView.image = nil
        attachmentImageView.image = nil
        attachmentImageView.contentMode = .scaleAspectFill
        playImageView.isHidden = true
        bottomInfoHeightConstraint.constant = 0
        forwardInfoHeightConstraint.constant = 0
        attachmentImageView.backgroundColor = #colorLiteral(red: 0.7999122739, green: 0.8000505567, blue: 0.799903512, alpha: 1)
        infoTopLineView.backgroundColor = .clear
        attachmentID = ""
        attachmentSizeLabel.text = ""
        progressView.isHidden = true
    }
    
    //MARK: - Actions
    func setupAttachment(_ attachment: QBChatAttachment, attachmentType: AttachmentType, completion:((_ videoURL: URL?)-> Void)? = nil) {
        guard let ID = attachment.id else {
            return
        }
       
        attachmentID = ID
        
        var attachmentName = "Attachment"
        if let name = attachment.name {
                  attachmentName = name
        }
        
        attachmentDownloadManager.downloadAttachment(attachmentID, attachmentName: attachmentName, attachmentType: attachmentType, progressHandler: { [weak self] (progress, ID) in
            if self?.attachmentID != ID {
                return
            }
            self?.isUserInteractionEnabled = false
            self?.updateLoadingProgress(progress)
            }, successHandler: { [weak self] (image, url, ID) in
                if self?.attachmentID != ID {
                    return
                }
                if attachmentType == .File, let fileURL = url {
                    self?.setupCellWithAttachment(image, attachment: attachment, attachmentType: .File)
                    completion?(fileURL)
                }
                if attachmentType == .Video, let videoURL = url, let image = image {
                    self?.setupCellWithAttachment(image, attachment: attachment, attachmentType: .Video)
                    completion?(videoURL)
                }
                if attachmentType == .Image, let image = image, url == nil {
                    self?.setupCellWithAttachment(image, attachment: attachment, attachmentType: .Image)
                }
            }, errorHandler: { [weak self] (error, ID) in
                if self?.attachmentID != ID {
                    return
                }
                let errorImage = UIImage(named: "image_attachment")!
                self?.setupCellWithAttachment(errorImage, attachment: attachment, attachmentType: .Error)
        })
    }
    
    //MARK: - Internal Methods
    private func setupCellWithAttachment(_ attachmentImage: UIImage?, attachment: QBChatAttachment, attachmentType: AttachmentType) {
        self.isUserInteractionEnabled = true
        self.progressView.isHidden = true
        attachmentNameLabel.text = attachment.name
        if attachmentType == .File, let attachmentImage = attachmentImage {
                typeAttachmentImageView.image = nil
                attachmentImageView.image = attachmentImage
                attachmentImageView.contentMode = .scaleAspectFit

        } else {
            typeAttachmentImageView.image = nil
            attachmentImageView.image = attachmentImage
        }
    }
    
    private func updateLoadingProgress(_ progress: CGFloat) {
        if progressView.isHidden == true {
            progressView.isHidden = false
        }
        if progress > 0.0 {
            DispatchQueue.main.async {
                self.progressView.setProgress(to: progress)
            }
        }
    }
}
