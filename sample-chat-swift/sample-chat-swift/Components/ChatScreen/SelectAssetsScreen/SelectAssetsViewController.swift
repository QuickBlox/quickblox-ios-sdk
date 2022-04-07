//
//  SelectAssetsViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 12/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Photos

struct PhotoAsset: Equatable {
    var phAsset: PHAsset
    var image: UIImage
}

struct SelectAssetsConstant {
    static let itemsInRow: CGFloat = 3
    static let maximumMB: Double = 100
    static let dividerToMB: Double = 1048576
    static let minimumSpacing: CGFloat = 8.0
    static let reuseIdentifier = "SelectAssetCell"
    static let creationDate = "creationDate"
    static let fileSize = "fileSize"
}

class SelectAssetsViewController: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendAttachmentButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var allPhotos = PHFetchResult<PHAsset>()
    fileprivate let cachingImageManager = PHCachingImageManager()
    fileprivate var thumbnailImageSize: CGSize!
    fileprivate var previousRect = CGRect.zero
    var selectedAssetCompletion:((_ asset: PhotoAsset?) -> Void)?
    var selectedAsset: PhotoAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        reloadImages()
        updateCachedImages()
        containerView.roundTopCorners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let width = (UIScreen.main.bounds.width)/SelectAssetsConstant.itemsInRow -
        SelectAssetsConstant.minimumSpacing * (SelectAssetsConstant.itemsInRow - 1)
        thumbnailImageSize = CGSize(width: width, height: width)
    }
    
    fileprivate func reloadImages() {
        stopCachingImages()
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: SelectAssetsConstant.creationDate, ascending: true)]
        allPhotos = PHAsset.fetchAssets(with: fetchOptions)
        collectionView.reloadData()
    }
    
    fileprivate func updateCachedImages() {
        guard isViewLoaded && view.window != nil else { return }
        var originalRect = CGRect(origin: collectionView!.contentOffset,
                                  size: collectionView!.bounds.size)
        originalRect = originalRect.insetBy(dx: 0, dy: -0.5 * originalRect.height)
        let deltaY = abs(originalRect.midY - previousRect.midY)
        guard deltaY > view.bounds.height / 3 else { return }
        
        let (addedRects, removedRects) = compareRect(previousRect, originalRect)
        let assetsStartCaching = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in allPhotos.object(at: indexPath.item) }
        let assetsStopCaching = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in allPhotos.object(at: indexPath.item) }
        
        cachingImageManager.startCachingImages(for: assetsStartCaching,
                                               targetSize: thumbnailImageSize,
                                               contentMode: .aspectFill,
                                               options: nil)
        cachingImageManager.stopCachingImages(for: assetsStopCaching,
                                              targetSize: thumbnailImageSize,
                                              contentMode: .aspectFill,
                                              options: nil)
        previousRect = originalRect
    }
    
    // MARK: Asset Caching
    fileprivate func stopCachingImages() {
        cachingImageManager.stopCachingImagesForAllAssets()
        previousRect = .zero
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.selectedAssetCompletion?(nil)
        }
    }
    
    
    @IBAction func sendAttachmentButtonTapped(_ sender: UIButton) {
        guard let selectedAsset = selectedAsset else {
            return
        }
        let sendAsset: (Double) -> Void = { [weak self] (size) in
            let sizeMB = size/SelectAssetsConstant.dividerToMB
            if sizeMB.truncate(to: 2) > SelectAssetsConstant.maximumMB {
                self?.showAlertView("The uploaded file exceeds maximum file size (100MB)",
                                    message: nil, handler: nil)
            } else {
                self?.sendAttachmentButton.isEnabled = false
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.isNetworkAccessAllowed = true
                PHImageManager.default().requestImage(for: selectedAsset.phAsset,
                                                         targetSize: PHImageManagerMaximumSize,
                                                         contentMode: .aspectFill,
                                                         options: options) { (image, info) -> Void in
                    guard let image = image else {
                        self?.showAlertView("Error loading image", message: nil, handler: nil)
                        self?.sendAttachmentButton.isEnabled = true
                        return
                    }
                    let photoAsset = PhotoAsset(phAsset: selectedAsset.phAsset, image: image)
                    DispatchQueue.main.async {
                        self?.dismiss(animated: true) {
                            self?.selectedAssetCompletion?(photoAsset)
                        }
                    }
                }
            }
        }
        
        let res = PHAssetResource.assetResources(for: selectedAsset.phAsset)
        if let assetSize = res.first?.value(forKey: SelectAssetsConstant.fileSize) as? Double {
            sendAsset(assetSize)
        }
    }
}

extension SelectAssetsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async { [weak self] in
            self?.reloadImages()
            self?.updateCachedImages()
        }
    }
}

extension SelectAssetsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectAssetsConstant.reuseIdentifier, for: indexPath) as? SelectAssetCell else {
            return UICollectionViewCell()
        }
        let phAsset = allPhotos[indexPath.row]
        cell.representedAssetIdentifier = phAsset.localIdentifier
        cachingImageManager.requestImage(for: phAsset,
                                         targetSize: thumbnailImageSize,
                                         contentMode: .aspectFill,
                                         options: nil,
                                         resultHandler: { image, _ in
            if cell.representedAssetIdentifier == phAsset.localIdentifier, let image = image  {
                cell.assetImageView.image = image
            }
        })
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedImages()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let phAsset = allPhotos[indexPath.row]
        let photoAsset = PhotoAsset(phAsset: phAsset, image: UIImage())
        selectedAsset = photoAsset
        sendAttachmentButton.isHidden = collectionView.indexPathsForSelectedItems?.isEmpty == true
    }
}

extension SelectAssetsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width)/SelectAssetsConstant.itemsInRow -
        SelectAssetsConstant.minimumSpacing * (SelectAssetsConstant.itemsInRow - 1)
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SelectAssetsConstant.minimumSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SelectAssetsConstant.minimumSpacing
    }
}
