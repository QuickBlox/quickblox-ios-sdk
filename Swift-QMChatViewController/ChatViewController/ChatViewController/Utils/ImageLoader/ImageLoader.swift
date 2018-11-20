//
//  ImageLoader.swift
//  Swift-QMChatViewController
//
//  Created by Vladimir Nybozhinsky on 11/15/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit
import SDWebImage
import Quickblox

typealias CustomTransformBlock = (URL, UIImage) -> UIImage

typealias WebImageCompletionWithFinishedBlock = (UIImage?, UIImage?, Error?, SDImageCacheType?, Bool?, URL?) -> Void

struct ImageLoaderConstant {
    static let runningOperations = "runningOperations"
}

class WebImageCombinedOperation: NSObject, SDWebImageOperation {
    deinit {
    }
    var isCancelled = false
    func cancel() {
        isCancelled = true
        if (cacheOperation != nil) {
            cacheOperation?.cancel()
            cacheOperation = nil
        }
        if (cancelBlock != nil) {
            cancelBlock!()
            cancelBlock = nil
        }
    }
    var operationID = ""
    var cancelBlock: SDWebImageNoParamsBlock? {
        didSet {
            if let cancelBlock = cancelBlock, isCancelled == true  {
                cancelBlock()
            }
        }
    }
    var cacheOperation: Operation?
}

enum ImageTransformType: Int {
    case scaleAndCrop
    case circle
    case rounding
    case custom
}

class ImageTransform {
    
    private var size = CGSize.zero
    private var transformType: ImageTransformType?
    private var isCircle = false
    private var customTransformBlock: CustomTransformBlock?
    private var spec = ""
    
    convenience init(type transformType: ImageTransformType, size: CGSize) {
        self.init()
        let transform = ImageTransform()
        transform.size = size
        transform.transformType = transformType
    }
    
    convenience init(size: CGSize, customTransformBlock: @escaping CustomTransformBlock) {
        self.init()
        let transform = ImageTransform()
        transform.size = size
        transform.transformType = ImageTransformType.custom
        transform.customTransformBlock = customTransformBlock
    }
    
    convenience init(size: CGSize, isCircle: Bool) {
        self.init()
        let transformType = isCircle ? ImageTransformType.circle : ImageTransformType.scaleAndCrop
        let transform = ImageTransform()
        transform.size = size
        transform.transformType = transformType
    }
    
    func key(with url: URL?) -> String? {
        let stringTransformType = stringWithImageTransformType(transformType: transformType!)
        return "\(stringTransformType))_\(NSCoder.string(for: size))_\(url?.absoluteString ?? "")"
    }
    
    func applyTransform(for image: UIImage?, completionBlock transformCompletionBlock: @escaping (_ transformedImage: UIImage?) -> Void) {
        
        DispatchQueue.global(qos: .default).async(execute: {
            
            let transformed: UIImage? = self.imageManager(nil, transformDownloadedImage: image, with: nil)
            
            DispatchQueue.main.async(execute: {
                
                transformCompletionBlock(transformed)
            })
        })
    }
    
    func imageManager(_ imageManager: SDWebImageManager?, transformDownloadedImage image: UIImage?, with imageURL: URL?) -> UIImage? {
        
        switch transformType?.rawValue {
        case ImageTransformType.scaleAndCrop.rawValue:
            
            return image?.byScaleAndCrop(size)
        case ImageTransformType.circle.rawValue:
            
            return image?.byCircularScaleAndCrop(size)
        case ImageTransformType.custom.rawValue:
            
            if let customTransformBlock = customTransformBlock, let image = image, let imageURL = imageURL {
                let transformedImage = customTransformBlock(imageURL, image)
                return transformedImage
            } else {
                assert(false, "self.customTransformBlock == nil")
            }
        case ImageTransformType.rounding.rawValue:
            
            return image?.withCornerRadius(4, targetSize: size)
        default:
            assert(false, "Undefined image transform type")
        }
        return nil
    }
    
    func stringWithImageTransformType(transformType: ImageTransformType) -> String {
        
        let arr = ["ImageTransformTypeScaleAndCrop",
                   "ImageTransformTypeCircle",
                   "ImageTransformTypeRounding",
                   "ImageTransformTypeCustom"]
        
        return arr[transformType.rawValue]
    }
    
    func descriptionMethod() -> String {
        let stringTransformType = stringWithImageTransformType(transformType: transformType!)
        return "\(self) size:\(NSCoder.string(for: size)) transformType:\(stringTransformType)"
    }
}
/*
 *  ImageLoader class interface.
 *  This class is responsible for image caching, loading and size handling using
 */
class ImageLoader: SDWebImageManager {
    
    // MARK: shared Instance
    static let sharedManager: ImageLoader = {
            
            var cache = SDImageCache()
            let groupIdentifier = QBSettings.applicationGroupIdentifier
            if (groupIdentifier?.count)! > 0 {
                
                let diskCacheDirectory = URL(fileURLWithPath: FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier!)?.path ?? "").appendingPathComponent("default").absoluteString
                
                cache = diskCacheDirectory.count != 0 ? SDImageCache(namespace: "default", diskCacheDirectory: diskCacheDirectory) : SDImageCache(namespace: "default")
            } else {
                cache = SDImageCache(namespace: "default")
            }
            
        cache.maxMemoryCost = 15 * 1024 * 1024
            
            let downloader = SDWebImageDownloader.shared()
            
         let loader = ImageLoader(cache: cache, downloader: downloader)
            return loader
    }()
    
    private var failedURLs: Set<AnyHashable> = []
    private var runningOperations: [AnyHashable: WebImageCombinedOperation] = [:]
    
    override func cancelAll() {
        
        let runningOperationsQueue = DispatchQueue(label: ImageLoaderConstant.runningOperations)
        runningOperationsQueue.sync {
            
            let copiedOperations = runningOperations.values
            for operation in copiedOperations {
                operation.cancel()
            }
            runningOperations.removeAll()
        }
    }
    
    func cancelImageOperation(for url: URL?) {
        
        let operationID = cacheKey(for: url)
        
        guard let operation = runningOperations[operationID] else { return }
        operation.cancel()
        
        let runningOperationsQueue = DispatchQueue(label: ImageLoaderConstant.runningOperations)
        runningOperationsQueue.sync {
            runningOperations.removeValue(forKey: operationID)
            runningOperations.removeValue(forKey: operation.operationID)
        }
    }

    
    override init(cache: SDImageCache, downloader: SDWebImageDownloader) {
        super.init(cache: cache, downloader: downloader)
    }
    
    func safelyRemoveOperation(fromRunning operation: WebImageCombinedOperation?) {
        let runningOperationsQueue = DispatchQueue(label: ImageLoaderConstant.runningOperations)
        runningOperationsQueue.sync {
            if let operation = operation {
                runningOperations.removeValue(forKey: operation.operationID)
            }
        }
    }
    
    func originalImage(with url: URL?) -> UIImage? {
        return imageCache!.imageFromDiskCache(forKey: url?.absoluteString)
    }
    
    func imageManager(_ imageManager: SDWebImageManager?, transform: ImageTransform?, transformDownloadedImage image: UIImage?, with imageURL: URL?) -> UIImage? {
        
        if transform != nil {
            
            let transformKey = transform?.key(with: imageURL)
            let transformedImage: UIImage? = transform?.imageManager(imageManager, transformDownloadedImage: image, with: imageURL)
            imageCache!.store(transformedImage, imageData: nil, forKey: transformKey, toDisk: true, completion: nil)
            
            return transformedImage
        }
        
        return nil
    }
    
    func cancelOperation(with url: URL?) {
        
        operation(with: url)?.cancel()
    }
    
    func operation(with url: URL?) -> WebImageCombinedOperation? {
        
        let key = cacheKey(for: url)
        
        var operation: WebImageCombinedOperation? = nil
        let runningOperationsQueue = DispatchQueue(label: ImageLoaderConstant.runningOperations)
        runningOperationsQueue.sync {
            operation = runningOperations[key]
        }
        return operation
    }
    
    func hasImageOperation(with url: URL?) -> Bool {
        
        return operation(with: url) != nil
    }
    
    func hasOriginalImage(with url: URL?) -> Bool {
        
        var exists = false
        
        let key = cacheKey(for: url)
        let path = imageCache!.defaultCachePath(forKey: key)
        if path != "" {
            exists = FileManager.default.fileExists(atPath: path!)
        }
        
        return exists
    }
    
    func pathForOriginalImage(with url: URL?) -> String? {
        
        let key = cacheKey(for: url)
        let path = imageCache!.defaultCachePath(forKey: key)
        
        if FileManager.default.fileExists(atPath: path!) {
            return path
        }
        
        return nil
    }
    
    func downloadImage(with url: URL?, transform: ImageTransform?,
                       options: SDWebImageOptions,
                       progress progressBlock: SDWebImageDownloaderProgressBlock?,
                       completed completedBlock: @escaping WebImageCompletionWithFinishedBlock) -> SDWebImageOperation? {
        return downloadImage(with: url, token: nil, transform: transform, options: options, progress: progressBlock, completed: completedBlock)
    }
    
    
    func downloadImage(with url: URL?, token: String?,
                       transform: ImageTransform?,
                       options: SDWebImageOptions,
                       progress progressBlock: SDWebImageDownloaderProgressBlock?,
                       completed completedBlock: WebImageCompletionWithFinishedBlock?) -> SDWebImageOperation? {

        // Invoking this method without a completedBlock is pointless
        assert(completedBlock != nil, "If you mean to prefetch the image, use SDWebImagePrefetcher.prefetchURLs instead")
        
        weak var `self` = self
        
        var imageUrl: URL?
        
        if let url = url {
            imageUrl = url
        }
        let operation = WebImageCombinedOperation()
        weak var weakOperation = operation
        
        var isFailedUrl = false
        let failedURLsQueue = DispatchQueue(label: "failedURLs")
        failedURLsQueue.sync {
            if let url = imageUrl {
                isFailedUrl = failedURLs.contains(url)
            }
        }
        
        if imageUrl?.absoluteString.isEmpty == true || (options.contains(.retryFailed) == false && isFailedUrl == true) {
            
            DispatchQueue.main.async {
                let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil)

                if let completedBlock = completedBlock {
                    completedBlock(nil, nil, error, SDImageCacheType.none, true, url)
                    
                }
            }
            return operation
        }
        
        let operationID = cacheKey(for: url)
        if let operationID = operationID {
            operation.operationID = operationID
        }
        
        let runningOperationsQueue = DispatchQueue(label: "runningOperations")
        runningOperationsQueue.sync {
            runningOperations[operationID] = operation
        }
        let key = cacheKey(for: url)
        let transformKey = transform!.key(with: url)
        
        typealias cache_operation = () -> Operation?
        
        let cacheOp: cache_operation = {
            
            guard let imageCache = self?.imageCache else {
                return nil
            }
            
            return imageCache.queryCacheOperation(forKey: key, done: { image, data, cacheType in
                
                if let weakOperation = weakOperation,  weakOperation.isCancelled == true {
                    self?.safelyRemoveOperation(fromRunning: weakOperation)
                    return
                }
                
                if (image == nil || options.contains(.refreshCached) == true)
//                    && (!self?.delegate?.responds(to: #selector(imageManager(_:shouldDownloadImageForURL:))) || self?.delegate.imageManager(self, shouldDownloadImageForURL: url))
                {
                    
                    if image != nil && options.contains(.refreshCached) == true {
                        DispatchQueue.main.async {
                            // If image was found in the cache but SDWebImageRefreshCached is provided, notify about the cached image
                            // AND try to re-download it in order to let a chance to NSURLCache to refresh it from server.
                            if let completedBlock = completedBlock {
                                completedBlock(image, nil, nil, cacheType, true, url)
                            }
                        }
                    }
                    
                    // download if no image or requested to refresh anyway, and download allowed by delegate
                    //                    var downloaderOptions: [SDWebImageDownloaderOptions] = []
                    var downloaderOptions: SDWebImageDownloaderOptions?
                    if options.contains(.lowPriority) == true {
                        downloaderOptions = SDWebImageDownloaderOptions.lowPriority
                    }
                    if options.contains(.progressiveDownload) == true {
                        downloaderOptions = SDWebImageDownloaderOptions.progressiveDownload
                    }
                    if options.contains(.refreshCached) == true {
                        downloaderOptions = SDWebImageDownloaderOptions.useNSURLCache
                    }
                    if options.contains(.continueInBackground) == true {
                        downloaderOptions = SDWebImageDownloaderOptions.continueInBackground
                    }
                    if options.contains(.handleCookies) == true {
                        downloaderOptions = SDWebImageDownloaderOptions.handleCookies
                    }
                    if options.contains(.allowInvalidSSLCertificates) == true {
                        downloaderOptions = SDWebImageDownloaderOptions.allowInvalidSSLCertificates
                    }
                    if options.contains(.highPriority) == true {
                        downloaderOptions = SDWebImageDownloaderOptions.highPriority
                    }
                    if image != nil && options.contains(.refreshCached) == true  {
                        // force progressive off if image already cached but forced refreshing
                        downloaderOptions = SDWebImageDownloaderOptions.progressiveDownload
                        // ignore image read from NSURLCache if image if cached but force refreshing
                        downloaderOptions = SDWebImageDownloaderOptions.ignoreCachedResponse
                    }
                    
                    var urlToDownload = url
                    
                    if (token != nil) {
                        var components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
                        
                        components?.query = "token=\(String(describing: token))"
                        
                        urlToDownload = components?.url
                    }

                    let subOperation: SDWebImageDownloadToken? = self?.imageDownloader?.downloadImage(with: urlToDownload, options: downloaderOptions!, progress: progressBlock, completed: { downloadedImage, data, error, finished in
                        let strongOperation = weakOperation
                        if strongOperation == nil || strongOperation!.isCancelled == true {
                            // Do nothing if the operation was cancelled
                            // See #699 for more details
                            // if we would call the completedBlock, there could be a race condition
                            // between this block and another completedBlock for the same object, so
                            // if this one is called second, we will overwrite the new data
                        } else if error != nil {
                            
                            DispatchQueue.main.async {
                                
                                if strongOperation != nil, strongOperation?.isCancelled == false {
                                    if let completedBlock = completedBlock {
                                        completedBlock(nil, nil, error, SDImageCacheType.none, finished, url)
                                    }
                                }
                            }
                            
                            if (error as NSError?)?.code != NSURLErrorNotConnectedToInternet &&
                                (error as NSError?)?.code != NSURLErrorCancelled &&
                                (error as NSError?)?.code != NSURLErrorTimedOut &&
                                (error as NSError?)?.code != NSURLErrorInternationalRoamingOff &&
                                (error as NSError?)?.code != NSURLErrorDataNotAllowed &&
                                (error as NSError?)?.code != NSURLErrorCannotFindHost &&
                                (error as NSError?)?.code != NSURLErrorCannotConnectToHost {
                                let weakFailedURLsQueue = DispatchQueue(label: "weakSelf.failedURLs")
                                weakFailedURLsQueue.sync {
                                    self?.failedURLs.insert(url)
                                }
                            }
                        } else {
                            if options.contains(.retryFailed) == true {
                                let weakFailedURLsQueue = DispatchQueue(label: "weakSelf.failedURLs")
                                weakFailedURLsQueue.sync {
                                    if (self?.failedURLs.contains(url))! {
                                        self?.failedURLs.remove(url)
                                    }
                                }
                            }
                            
                            let cacheOnDisk = !(options.contains(.cacheMemoryOnly))
                            
                            if options.contains(.refreshCached) == true, image != nil, downloadedImage != nil {
                                // Image refresh hit the NSURLCache cache, do not call the completion block
                            } else if downloadedImage != nil &&
                                (downloadedImage?.images == nil || options.contains(.transformAnimatedImage) == true) &&
                                transform != nil {
                                
                                
                                DispatchQueue.global(qos: .default).async(execute: {
                                    
                                    let transformedImage = self?.imageManager(self, transform: transform, transformDownloadedImage: downloadedImage, with: url)
                                    
                                    if transformedImage != nil && finished {
                                        
                                        let imageWasTransformed = !(transformedImage?.isEqual(downloadedImage) ?? false)
                                        
                                        self?.imageCache?.store(downloadedImage, imageData: (imageWasTransformed ? nil : data), forKey: key, toDisk: cacheOnDisk, completion: nil)
                                    }
                                    
                                    
                                    DispatchQueue.main.async {
                                        
                                        if (strongOperation != nil) && strongOperation?.isCancelled == false {
                                            if let completedBlock = completedBlock {
                                                completedBlock(downloadedImage, transformedImage, nil, SDImageCacheType.none, finished, url)
                                                
                                            }
                                        }
                                    }
                                })
                            } else {
                                
                                if (downloadedImage != nil) && finished == true {
                                    
                                    self?.imageCache?.store(downloadedImage, imageData: data, forKey: key, toDisk: cacheOnDisk, completion: nil)
                                }
                                
                                
                                DispatchQueue.main.async {
                                    
                                    if (strongOperation != nil) && strongOperation?.isCancelled == false {
                                        if let completedBlock = completedBlock {
                                            completedBlock(downloadedImage, nil, nil, SDImageCacheType.none, finished, url)
                                            
                                        }
                                    }
                                }
                            }
                        }
                        if finished == true {
                            
                            self?.safelyRemoveOperation(fromRunning: operation)
                        }
                        
                    })
                    
                    let operationQueue = DispatchQueue(label: "operation")
                    operationQueue.sync {
   
                            weak var weakSuboperation = subOperation
                            weakOperation?.cancelBlock = {
                                
                                self?.imageDownloader?.cancel(weakSuboperation)
                                let strongOperation = weakOperation
                                self?.safelyRemoveOperation(fromRunning: strongOperation)
                        }
                    }
                }
                   else if image != nil {
                        let strongOperation = weakOperation
                        if transform != nil {
                            DispatchQueue.global(qos: .default).async(execute: {
                                var transformedImage: UIImage? = self?.imageCache?.imageFromDiskCache(forKey: transformKey)
                                if transformedImage == nil {
                                    transformedImage = self?.imageManager(self, transform: transform, transformDownloadedImage: image, with: url)
                                    DispatchQueue.main.async {
                                        if (strongOperation != nil) && strongOperation?.isCancelled == false {
                                            if let completedBlock = completedBlock {
                                                completedBlock(image, transformedImage, nil, cacheType, true, url)
                                            }
                                        }
                                    }
                                    let weakRunningOperationsQueue = DispatchQueue(label: "weakSelf.runningOperations")
                                    weakRunningOperationsQueue.sync {
                                        self?.runningOperations.removeValue(forKey: operationID)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        if (strongOperation != nil) && strongOperation?.isCancelled == false {
                                            if let completedBlock = completedBlock {
                                                completedBlock(image, transformedImage, nil, cacheType, true, url)
                                            }
                                        }
                                    }
                                    let weakRunningOperationsQueue = DispatchQueue(label: "weakSelf.runningOperations")
                                    weakRunningOperationsQueue.sync {
                                        self?.runningOperations.removeValue(forKey: operationID)
                                    }
                                }
                            })
                        
                    } else {
                        //
                        DispatchQueue.main.async {
                            
                            if (strongOperation != nil) && strongOperation?.isCancelled == false {
                                if let completedBlock = completedBlock {
                                    completedBlock(image, nil, nil, cacheType, true, url)
                                    
                                }
                            }
                        }
                        self?.safelyRemoveOperation(fromRunning: weakOperation)
                    }
                } else {
                    // Image not in cache and download disallowed by delegate
                    
                    DispatchQueue.main.async {
                        let strongOperation = weakOperation
                        if (strongOperation != nil) && strongOperation?.isCancelled == false {
                            if let completedBlock = completedBlock {
                                completedBlock(nil, nil, nil, SDImageCacheType.none, true, url)
                            }
                        }
                    }
                    self?.safelyRemoveOperation(fromRunning: weakOperation)
                }
            })
        }

            if transform != nil {
                
                self?.imageCache?.queryCacheOperation(forKey: transformKey, done: { tranformedImageFromCache, data, cacheType in
                    if tranformedImageFromCache != nil {
                        
                        let strongOperation = weakOperation
                        
                        DispatchQueue.main.async {
                            
                            if (strongOperation != nil) && strongOperation?.isCancelled == false {
                                if let completedBlock = completedBlock {
                                    completedBlock(nil, tranformedImageFromCache, nil, cacheType, true, url)
                                }
                            }
                        }
                        
                        self?.safelyRemoveOperation(fromRunning: weakOperation)
                        return
                    }
                    
                    weakOperation?.cacheOperation = cacheOp()
                })
            } else {
                
                operation.cacheOperation = cacheOp()
            }
            
            return operation
            
        }
}
