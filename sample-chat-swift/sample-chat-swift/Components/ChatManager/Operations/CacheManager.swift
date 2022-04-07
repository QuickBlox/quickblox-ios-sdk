//
//  CacheManager.swift
//  sample-chat-swift
//
//  Created by Injoit on 21.12.2019.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import Foundation

public enum Result<T> {
    case success(T)
    case failure(NSError)
}

class CacheManager {
    static let shared = CacheManager()
    private let fileManager = FileManager.default
    lazy var cachesDirectoryUrl: URL = {
        let cachesDirectoryUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return cachesDirectoryUrl
    }()
    
    private lazy var imageCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.name = "chat.imageCache"
        cache.countLimit = 100 // Max 100 images in memory.
        cache.totalCostLimit = 1024 * 1024 * 90 // Max 90MB used.
        return cache
    }()

    private let lock = NSLock()

    public func imageFromCache(for key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        if let image = imageCache.object(forKey: key as AnyObject) as? UIImage {
            return image
        }
        return nil
    }
    
    public func store(_ image: UIImage?, for key: String) {
        guard let image = image else {
            return removeImage(for: key)
        }
        lock.lock()
        defer { lock.unlock() }
        imageCache.setObject(image, forKey: key as AnyObject, cost: 1)
    }
    
    public func removeImage(for key: String) {
        lock.lock()
        defer { lock.unlock() }
        imageCache.removeObject(forKey: key as AnyObject)
    }

    public func removeAllImages() {
        lock.lock()
        defer { lock.unlock() }
        imageCache.removeAllObjects()
    }

    public subscript(_ key: String) -> UIImage? {
        get {
            return imageFromCache(for: key)
        }
        set {
            return store(newValue, for: key)
        }
    }
    
    func clearCache(){
        removeAllImages()
        let cacheURL =  fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error {
                    debugPrint("[CacheManager] clearCache error: \(error)")
                }
            }
        } catch let error {
            debugPrint("[CacheManager] error \(error.localizedDescription)")
        }
    }
    
    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {
        let fileUrl = directoryFor(stringUrl: stringUrl)
        
        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: fileUrl.path)  else {
            completionHandler(Result.success(fileUrl))
            return
        }
        DispatchQueue.global().async {
            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: fileUrl, atomically: true)
                DispatchQueue.main.async {
                    completionHandler(Result.success(fileUrl))
                }
            } else {
                DispatchQueue.main.async {
                    let error = NSError(domain: "SomeErrorDomain", code: -2001 /* some error code */, userInfo: ["description": "Can't download video"])
                    
                    completionHandler(Result.failure(error))
                }
            }
        }
    }
    
    private func directoryFor(stringUrl: String) -> URL {
        let fileURL = URL(string: stringUrl)!.lastPathComponent
        let file = cachesDirectoryUrl.appendingPathComponent(fileURL)
        return file
    }
}
