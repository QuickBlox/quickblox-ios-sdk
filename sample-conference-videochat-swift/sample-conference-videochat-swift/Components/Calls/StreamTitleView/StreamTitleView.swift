//
//  StreamTitleView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 5/22/20.
//  Copyright © 2020 QuickBlox. All rights reserved.
//

import UIKit

class StreamTitleView: UIImageView {
    
    func setupStreamTitleViewOnLive(_ onLive: Bool) {
        self.frame = CGRect(x: 0, y: 0, width: 72.0, height: 20.0)
        image = onLive == true ? #imageLiteral(resourceName: "live_streaming") : #imageLiteral(resourceName: "end_stream")
    }
}
