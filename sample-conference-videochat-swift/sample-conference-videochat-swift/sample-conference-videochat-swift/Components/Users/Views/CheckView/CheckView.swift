//
//  CheckView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 17.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class CheckView: UIView {
    
    let checkboxNormalImage = UIImage(named: "checkbox-normal")
    let checkboxPressedImage = UIImage(named: "checkbox-pressed")
    private var imageView: UIImageView!
    
    var check: Bool? {
        didSet {
            setCheck(check!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView = UIImageView(image: checkboxNormalImage)
        imageView.frame = bounds
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
    }
    
    func setCheck(_ check: Bool) {
        imageView.image = check ? checkboxPressedImage : checkboxNormalImage
    }
}
