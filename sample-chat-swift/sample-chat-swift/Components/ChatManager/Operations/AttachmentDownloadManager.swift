//
//  AttachmentDownloadManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AttachmentDownloadManager {
    
    //MARK: - Properties
    private let imageCache = CacheManager.shared
    
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
        if let image = imageCache.imageFromCache(for: ID) {
            successHandler(image, nil, ID)
        } else {
            let operation = AttachmentDownloadOperation(attachmentID: ID, attachmentName: attachmentName, attachmentType: attachmentType, progress: { (progress, ID) in
                progressHandler(progress, ID)
            }, success: { (image, url, ID) in
                guard let image = image else { return }
                successHandler(image, nil, ID)
            }, error: { (error, ID) in
                errorHandler(error,  ID)
            })
            imageDownloadQueue.addOperation(operation)
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
