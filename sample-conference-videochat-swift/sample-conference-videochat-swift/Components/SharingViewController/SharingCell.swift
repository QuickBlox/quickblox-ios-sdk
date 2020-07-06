//
//  SharingCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 12/18/18.
//  Copyright © 2018 QuickBlox. All rights reserved.
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
