//
//  TitleView.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 10/10/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class TitleView: UILabel {
    var title = "" {
        didSet {
            text = title
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)

        font = .systemFont(ofSize: 17.0, weight: .bold)
        textColor = .white
        textAlignment = .center
        lineBreakMode = .byTruncatingTail
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
