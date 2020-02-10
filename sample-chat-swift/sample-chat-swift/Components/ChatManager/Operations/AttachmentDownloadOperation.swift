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

enum AttachmentType {
    case Image
    case Video
    case Camera
    case File
    case Error
}

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
                self?.successHandler?(image, nil, ID)
            } else {
                let fileData = fileData as NSData
//                let fileName = ID
                let fileName = ID + "_" + attachmentName
                let filePath = NSTemporaryDirectory() + fileName
                let fileURL = URL(fileURLWithPath: filePath)
                if  fileData.write(to: fileURL, atomically: true) == true {
                    self?.successHandler?(nil, fileURL, ID)
                } else {
                    print("failure")
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
