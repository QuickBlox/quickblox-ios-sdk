//
//  ChatAttachmentCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

enum AttachmentType: String {
    case Image = "image"
    case Video = "video"
    case Camera = "camera"
    case File = "file"
    case PDF = "pdf"
    case MP3 = "mp3"
    case Error = "error"
}

class ChatAttachmentCell: ChatCell {
    
    //MARK: - IBOutlets
    @IBOutlet weak var forwardInfoView: UIView!
    @IBOutlet weak var forwardInfoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var forwardedLabel: UILabel!
    @IBOutlet weak var progressView: CircularProgressBar!
    @IBOutlet weak var attachmentInfoView: UIView!
    @IBOutlet weak var attachmentNameLabel: UILabel!
    @IBOutlet weak var attachmentSizeLabel: UILabel!
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
    private let color =  #colorLiteral(red: 0.8452011943, green: 0.8963350058, blue: 1, alpha: 1)
    
    //MARK: - Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        previewContainer.layer.applyShadow(color: color, alpha: 1.0, y: 3.0, blur: 48.0)
        attachmentImageView.backgroundColor = color
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
        attachmentImageView.backgroundColor = color
        infoTopLineView.backgroundColor = .clear
        attachmentID = ""
        attachmentSizeLabel.text = ""
        progressView.isHidden = true
    }
    
    //MARK: - Actions
    // MARK: - Public Methods
    func setupAttachment(_ attachment: QBChatAttachment) {
        guard let ID = attachment.id else {
            return
        }
        
        attachmentID = ID
        
        if attachment.type == AttachmentType.Image.rawValue {
            self.bottomInfoHeightConstraint.constant = 0.0
            self.typeAttachmentImageView.image = #imageLiteral(resourceName: "image_attachment")
            self.setupAttachment(attachment, attachmentType: .Image)
            
        } else if attachment.type == AttachmentType.Video.rawValue {
            self.bottomInfoHeightConstraint.constant = 60.0
            self.playImageView.isHidden = false
            self.attachmentNameLabel.text = attachment.name
            if let size = attachment.customParameters?[Key.attachmentSize],
               let sizeMB = Double(size) {
                self.attachmentSizeLabel.text = String(format: "%.02f", sizeMB/1048576) + " MB"
            }
             
            if let videoURL = attachment.cachedUrl, FileManager.default.fileExists(atPath: videoURL.path) == true {
                self.attachmentUrl = videoURL
                if let image = CacheManager.shared.imageFromCache(for: attachmentID) {
                    self.attachmentImageView.image = image
                } else {
                    
                    videoURL.getThumbnailImage { image in
                        if let image = image {
                            self.attachmentImageView.image = image
                            CacheManager.shared.store(image, for: ID)
                        }
                    }
                }
            } else {
                self.typeAttachmentImageView.image = #imageLiteral(resourceName: "video_attachment")
                self.setupAttachment(attachment, attachmentType: .Video) { videoURL in
                    if let videoURL = videoURL {
                        self.attachmentUrl = videoURL
                    }
                }
            }
        } else if attachment.type == AttachmentType.File.rawValue {
            self.attachmentNameLabel.text = attachment.name
            self.bottomInfoHeightConstraint.constant = 60.0
            self.attachmentImageView.backgroundColor = .white
            self.infoTopLineView.backgroundColor = color
            self.typeAttachmentImageView.image = #imageLiteral(resourceName: "file")
            if let size = attachment.customParameters?[Key.attachmentSize],
               let sizeMB = Double(size) {
                self.attachmentSizeLabel.text = String(format: "%.02f", sizeMB/1048576) + " MB"
            }
            if let fileURL = attachment.cachedUrl, FileManager.default.fileExists(atPath: fileURL.path) == true {
                self.attachmentUrl = fileURL
                self.isUserInteractionEnabled = true
                if let image = CacheManager.shared.imageFromCache(for: attachmentID) {
                    self.attachmentImageView.image = image
                    self.typeAttachmentImageView.image = nil
                    self.attachmentImageView.contentMode = .scaleAspectFit
                } else {
                    if attachment.name?.hasSuffix("pdf") == true {
                        fileURL.getThumbnailImage { image in
                            if let image = image {
                                self.attachmentImageView.image = image
                                self.typeAttachmentImageView.image = nil
                            }
                            self.attachmentImageView.contentMode = .scaleAspectFit
                            CacheManager.shared.store(image, for: ID)
                        }
                    } else if attachment.name?.hasSuffix("mp3") == true {
                        
                    }
                }
            } else {
                self.setupAttachment(attachment, attachmentType: .File) { fileURL in
                    if let fileURL = fileURL {
                        self.attachmentUrl = fileURL
                    }
                }
            }
        }
    }
    
    //MARK: - Internal Methods
    private func setupAttachment(_ attachment: QBChatAttachment, attachmentType: AttachmentType, completion:((_ videoURL: URL?)-> Void)? = nil) {
        
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
