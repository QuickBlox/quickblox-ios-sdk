//
//  AttachmentDownloadManager.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVFoundation

class AttachmentDownloadManager {
    
    //MARK: - Properties
    private let imageCache = SDImageCache.shared()
    
    private lazy var imageDownloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "com.chatSwift.imageDownloadqueue"
        queue.qualityOfService = .userInteractive
        return queue
    }()
    
    //MARK: - Actions
    func downloadAttachment(_ ID: String,
                            attachmentName: String,
                            attachmentType: AttachmentType,
                            progressHandler: @escaping ProgressHandler,
                            successHandler: @escaping SuccessHandler,
                            errorHandler: @escaping ErrorHandler) {

        if attachmentType == .Image, let image = imageCache.imageFromCache(forKey: ID) {
            successHandler(image, nil, ID)
        } else {
            if let operations = (imageDownloadQueue.operations as? [AttachmentDownloadOperation])?.filter({$0.attachmentID == ID
                && $0.isFinished == false
                && $0.isExecuting == true }), let operation = operations.first {
                operation.queuePriority = .veryHigh
            } else {
                
                let operation = AttachmentDownloadOperation(attachmentID: ID, attachmentName: attachmentName, attachmentType: attachmentType, progress: { (progress, ID) in
                    progressHandler(progress, ID)
                }, success: { [weak self] (image, url, ID) in
                    if attachmentType == .Image, let image = image {
                        let fixImage = image.fixOrientation()
                        self?.imageCache.store(fixImage, forKey: ID, toDisk: false) {
                            successHandler(fixImage, nil, ID)
                        }
                        
                    } else if attachmentType == .Video, let url = url {
                        CacheManager.shared.getFileWith(stringUrl: url.absoluteString) { result in

                            switch result {
                            case .success(let videoURl):
                            videoURl.getThumbnailImageFromVideoUrl { thumbnailImage in
                                self?.imageCache.store(thumbnailImage, forKey: ID, toDisk: false) {
                                    successHandler(thumbnailImage, videoURl, ID)
                                }
                            }
                                break;
                            case .failure(let error):
                                print(error, " failure in the Cache of video")
                                break;
                            }
                        }

                    } else if attachmentType == .File, let url = url {
                        CacheManager.shared.getFileWith(stringUrl: url.absoluteString) { result in

                            switch result {
                            case .success(let fileURl):
                                fileURl.drawPDFfromURL { thumbnailImage in
                                    if let thumbnailImage = thumbnailImage {
                                        self?.imageCache.store(thumbnailImage, forKey: ID, toDisk: false) {
                                            successHandler(thumbnailImage, fileURl, ID)
                                        }
                                    } else {
                                        successHandler(nil, fileURl, ID)
                                    }
                                }
                                break;
                            case .failure(let error):
                                print(error, " failure in the Cache of file")
                                break;
                            }
                        }
                    }
                    }, error: { (error, ID) in
                        errorHandler(error,  ID)
                })
                imageDownloadQueue.addOperation(operation)
            }
        }
    }
    
    func cancelAllOperations() {
        if let operations = (imageDownloadQueue.operations as? [AttachmentDownloadOperation])?.filter({$0.isFinished == false
            && $0.isExecuting == true }) {
            for operation in operations {
                operation.cancel()
            }
        }
    }
    
    func cancelDownloadAttachment(_ ID: String) {
        if let operations = (imageDownloadQueue.operations as? [AttachmentDownloadOperation])?.filter({$0.attachmentID == ID
            && $0.isFinished == false
            && $0.isExecuting == true }), let operation = operations.first {
            operation.cancel()
        }
    }
    
    func slowDownloadAttachment(_ ID: String) {
        if let operations = (imageDownloadQueue.operations as? [AttachmentDownloadOperation])?.filter({$0.attachmentID == ID
            && $0.isFinished == false
            && $0.isExecuting == true }), let operation = operations.first {
            operation.queuePriority = .low
        }
    }
}
