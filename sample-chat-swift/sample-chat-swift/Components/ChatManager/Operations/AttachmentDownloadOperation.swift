//
//  AttachmentDownloadOperation.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation
import UIKit

typealias ErrorHandler = (_ error: Error?, _ ID: String) -> Void
typealias SuccessHandler = (_ image: UIImage, _ ID: String) -> Void
typealias ProgressHandler = (_ progress: CGFloat, _ ID: String) -> Void

final class AttachmentDownloadOperation: AsyncOperation {
    
    //MARK: - Properties
    private var successHandler: SuccessHandler?
    private var progressHandler: ProgressHandler?
    private var errorHandler: ErrorHandler?
    var attachmentID: String
    
    //MARK: - Life Cycle
    public required init (attachmentID: String,
                          progress: @escaping ProgressHandler,
                          success: @escaping SuccessHandler,
                          error: @escaping ErrorHandler) {
        self.attachmentID = attachmentID
        self.progressHandler = progress
        self.successHandler = success
        self.errorHandler = error
        
        super.init()
    }
    
    //MARK: - Overrides
    override func main() {
        guard isCancelled == false else {
            self.state = .finished
            return
        }
        self.downloadAttachmentWithID(attachmentID)
    }
    
    //MARK: - Internal Methods
    private func downloadAttachmentWithID(_ ID: String) {
        self.state = .executing
        QBRequest.downloadFile(withUID: ID, successBlock: { [weak self] (response: QBResponse, fileData: Data)  in
            guard let image = UIImage(data: fileData) else {
                self?.state = .finished
                return
            }
            self?.successHandler?(image, ID)
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
