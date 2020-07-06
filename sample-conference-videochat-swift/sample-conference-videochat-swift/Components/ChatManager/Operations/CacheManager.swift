//
//  CacheManager.swift
//  sample-conference-videochat-swift
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
    
    func clearCache(){
        let cacheURL =  fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try fileManager.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil, options: [])
            for file in directoryContents {
                do {
                    try fileManager.removeItem(at: file)
                }
                catch let error {
                    debugPrint("Ooops! Something went wrong: \(error)")
                }

            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {

        let file = directoryFor(stringUrl: stringUrl)

        //return file path if already exists in cache directory
        guard !fileManager.fileExists(atPath: file.path)  else {
            completionHandler(Result.success(file))
            return
        }

        DispatchQueue.global().async {

            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
                videoData.write(to: file, atomically: true)
                DispatchQueue.main.async {
                    completionHandler(Result.success(file))
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
