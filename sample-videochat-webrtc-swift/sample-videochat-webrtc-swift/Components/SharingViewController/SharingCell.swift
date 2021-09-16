//
//  SharingCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 28.12.2020.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

class SharingCell: UICollectionViewCell {

    @IBOutlet private weak var imagePreview: UIImageView!
    
    var imageName = "" {
        didSet {
            imagePreview.image = UIImage(named: imageName)
        }
    }
}
