//
//  ImageView+Extension.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Photos

extension UIImageView {
    func setRoundedView(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        clipsToBounds = true
    }
}
