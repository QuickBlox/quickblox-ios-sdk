//
//  PHAsset+Extention.swift
//  sample-chat-swift
//
//  Created by Injoit on 04.01.2020.
//  Copyright © 2020 quickBlox. All rights reserved.
//

import Foundation
import Photos

extension PHAsset {
    func fetchImage(contentMode: PHImageContentMode,
                    targetSize: CGSize,
                    completionHandler : @escaping ((_ image : UIImage?) -> Void)) {
        var image: UIImage?
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        PHImageManager.default().requestImage(for: self, targetSize: targetSize, contentMode: contentMode, options: options) { fetchedImage, info in
            if let fetchedImage = fetchedImage {
                completionHandler(fetchedImage)
            } else {
                print(info![PHImageErrorKey])
                completionHandler(nil)
            }
        }
    }
    
    func fetchVideoURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (avAsset, avAudioMix, info) in
            if let avURLAsset = avAsset as? AVURLAsset {
                let videoURL = avURLAsset.url
                completionHandler(videoURL)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func fetchAudioURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: self, options: options) { (avAsset, avAudioMix, info) in
            if let avURLAsset = avAsset as? AVURLAsset {
                let videoURL = avURLAsset.url
                completionHandler(videoURL)
            } else {
                completionHandler(nil)
            }
        }
    }
}
