//
//  SelectAssetsVC.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 12/9/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Photos
import PDFKit
import SVProgressHUD

struct PhotoAsset: Equatable {
    var phAsset: PHAsset
    var image: UIImage
}

struct SelectAssetsConstant {
    static let maximumMB: Double = 100
    static let dividerToMB: Double = 1048576
    static let minimumSpacing: CGFloat = 8.0
    static let reuseIdentifier = "SelectAssetCell"
}

class SelectAssetsVC: UIViewController {
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendAttachmentButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var allPhotos: PHFetchResult<AnyObject>?
    var selectedAssetCompletion:((_ asset: PhotoAsset?) -> Void)?
    var selectedAsset: PhotoAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAssets()
        containerView.roundTopCorners()
    }
    
    private func fetchAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
        fetchOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        allPhotos = nil
        collectionView.reloadData()
        if let allPhotos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions) as? PHFetchResult<AnyObject> {
            self.allPhotos = allPhotos
            self.collectionView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.selectedAssetCompletion?(nil)
        }
    }
    
    @IBAction func sendAttachmentButtonTapped(_ sender: UIButton) {
        let sendAsset: (Double) -> Void = { [weak self] (size) in
            let sizeMB = size/SelectAssetsConstant.dividerToMB
            if sizeMB.truncate(to: 2) > SelectAssetsConstant.maximumMB {
                self?.showAlertView("The uploaded file exceeds maximum file size (100MB)", message: nil)
            } else {
                SVProgressHUD.show()
                self?.sendAttachmentButton.isEnabled = false
                if let selectedAsset = self?.selectedAsset {
                    let options = PHImageRequestOptions()
                    options.deliveryMode = .highQualityFormat
                    PHImageManager.default().requestImage(for: selectedAsset.phAsset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: options) { (image, info) -> Void in
                        SVProgressHUD.dismiss()
                        if let image = image {
                            let photoAsset = PhotoAsset(phAsset: selectedAsset.phAsset, image: image)
                            DispatchQueue.main.async {
                                self?.dismiss(animated: true) {
                                    self?.selectedAssetCompletion?(photoAsset)
                                }
                            }
                        } else {
                            self?.showAlertView("Error loading image", message: nil)
                        }
                    }
                }
            }
        }
        if let selectedAsset = selectedAsset {
            let res = PHAssetResource.assetResources(for: selectedAsset.phAsset)
            if let assetSize = res.first?.value(forKey: "fileSize") as? Double {
                sendAsset(assetSize)
            }
        }
    }
}

extension SelectAssetsVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allPhotos = allPhotos {
            return allPhotos.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SelectAssetCell, let phAsset = allPhotos?[indexPath.row] as? PHAsset, let size = cell.assetImageView?.bounds.size else {
            return
        }

        PHImageManager.default().requestImage(for: phAsset, targetSize: size, contentMode: .aspectFill, options: nil) { (image, info) -> Void in
            if let image = image {
                cell.assetImageView.image = image
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectAssetsConstant.reuseIdentifier, for: indexPath) as? SelectAssetCell else {
            return UICollectionViewCell()
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let phAsset = allPhotos?[indexPath.row] as? PHAsset else {
            return
        }
        let photoAsset = PhotoAsset(phAsset: phAsset, image: UIImage())
        self.selectedAsset = photoAsset
        self.sendAttachmentButton.isHidden = collectionView.indexPathsForSelectedItems?.isEmpty == false ? false : true
    }
}

extension SelectAssetsVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsInRow: CGFloat = 3
        let width = (UIScreen.main.bounds.width)/itemsInRow - SelectAssetsConstant.minimumSpacing * (itemsInRow - 1)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SelectAssetsConstant.minimumSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SelectAssetsConstant.minimumSpacing
    }
}
