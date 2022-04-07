//
//  QBChatAttachment+Extension.swift
//  sample-chat-swift
//
//  Created by Injoit on 18.03.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import Foundation

extension QBChatAttachment {
    var cachedUrl: URL? {
        guard let attachmentID = self.id else {
            return nil
        }
        if type == AttachmentType.Video.rawValue {
            return CacheManager.shared.cachesDirectoryUrl.appendingPathComponent(attachmentID + "_" + (name ?? "video.mp4"))
        } else if type == AttachmentType.File.rawValue {
            if name?.hasSuffix(AttachmentType.PDF.rawValue) == true {
                return CacheManager.shared.cachesDirectoryUrl.appendingPathComponent(attachmentID + "_" + (name ?? "file.pdf"))
            } else if name?.hasSuffix(AttachmentType.MP3.rawValue) == true {
                return CacheManager.shared.cachesDirectoryUrl.appendingPathComponent(attachmentID + "_" + (name ?? "file.mp3"))
            }
        }
        return nil
    }
}
