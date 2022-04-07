//
//  AttachmentDownloadOperation.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation
import UIKit
import AVKit

typealias ErrorHandler = (_ error: Error?, _ ID: String) -> Void
typealias SuccessHandler = (_ image: UIImage?, _ videoUrl: URL?, _ ID: String) -> Void
typealias ProgressHandler = (_ progress: CGFloat, _ ID: String) -> Void

final class AttachmentDownloadOperation: AsyncOperation {
    
    //MARK: - Properties
    private var successHandler: SuccessHandler?
    private var progressHandler: ProgressHandler?
    private var errorHandler: ErrorHandler?
    var attachmentID: String
    var attachmentName: String
    var attachmentType: AttachmentType
    
    //MARK: - Life Cycle
    public required init (attachmentID: String,
                          attachmentName: String,
                          attachmentType: AttachmentType,
                          progress: @escaping ProgressHandler,
                          success: @escaping SuccessHandler,
                          error: @escaping ErrorHandler) {
        self.attachmentID = attachmentID
        self.attachmentName = attachmentName
        self.progressHandler = progress
        self.successHandler = success
        self.errorHandler = error
        self.attachmentType = attachmentType
        
        super.init()
    }
    
    //MARK: - Overrides
    override func main() {
        guard isCancelled == false else {
            self.state = .finished
            return
        }
        self.downloadAttachmentWithID(attachmentID, attachmentName: attachmentName, attachmentType: attachmentType)
    }
    
    //MARK: - Internal Methods
    private func downloadAttachmentWithID(_ ID: String, attachmentName: String, attachmentType: AttachmentType) {
        self.state = .executing
        QBRequest.downloadFile(withUID: ID, successBlock: { [weak self] (response: QBResponse, fileData: Data)  in
            if attachmentType == .Image, let image = UIImage(data: fileData) {
                let fixImage = image.fixOrientation()
                CacheManager.shared.store(fixImage, for: ID)
                self?.successHandler?(fixImage.fixOrientation(), nil, ID)
            } else {
                let fileData = fileData as NSData
                let fileName = ID + "_" + attachmentName
                let filePath = NSTemporaryDirectory() + fileName
                let fileURL = URL(fileURLWithPath: filePath)
                if  fileData.write(to: fileURL, atomically: true) == true {
                    CacheManager.shared.getFileWith(stringUrl: fileURL.absoluteString) { result in
                        switch result {
                        case .success(let fileURl):
                            fileURl.getThumbnailImage { thumbnailImage in
                                CacheManager.shared.store(thumbnailImage, for: ID)
                                self?.successHandler?(thumbnailImage, fileURl, ID)
                            }
                        case .failure(let error):
                            debugPrint(error, "[AttachmentDownloadManager]  failure in the Cache of video")
                            self?.successHandler?(nil, nil, ID)
                        }
                    }
                } else {
                    debugPrint("[AttachmentDownloadOperation] failure")
                }
            }
            self?.state = .finished
        }, statusBlock: { [weak self] (request: QBRequest, status: QBRequestStatus?) in
            guard let status = status else {
                return
            }
            let progress = CGFloat(status.percentOfCompletion)
            self?.progressHandler?(progress, ID)
        }, errorBlock: { [weak self] (response: QBResponse) in
            self?.errorHandler?(response.error?.error, ID)
            self?.state = .finished
        })
    }
}
