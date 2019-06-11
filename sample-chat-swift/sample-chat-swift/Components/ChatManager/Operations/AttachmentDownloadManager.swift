//
//  AttachmentDownloadManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

final class AttachmentDownloadManager {
    
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
                            progressHandler: @escaping ProgressHandler,
                            successHandler: @escaping SuccessHandler,
                            errorHandler: @escaping ErrorHandler) {
        
        if let image = imageCache.imageFromCache(forKey: ID) {
            successHandler(image, ID)
        } else {
            if let operations = (imageDownloadQueue.operations as? [AttachmentDownloadOperation])?.filter({$0.attachmentID == ID
                && $0.isFinished == false
                && $0.isExecuting == true }), let operation = operations.first {
                operation.queuePriority = .veryHigh
            } else {
                
                let operation = AttachmentDownloadOperation(attachmentID: ID, progress: { (progress, ID) in
                    progressHandler(progress, ID)
                }, success: { [weak self] (image, ID) in
                    self?.imageCache.store(image, forKey: ID, toDisk: false) {
                        successHandler(image, ID)
                    }
                    }, error: { (error, ID) in
                        errorHandler(error,  ID)
                })
                imageDownloadQueue.addOperation(operation)
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
