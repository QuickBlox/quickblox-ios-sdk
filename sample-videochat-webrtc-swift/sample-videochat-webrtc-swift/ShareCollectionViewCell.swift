//
//  ShareCollectionViewCell.swift
//  sample-videochat-webrtc-swift
//
//  Created by QuickBlox team
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class ShareCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setImage(name: String!) {
        self.imageView.image = UIImage(named: name)
    }
}
