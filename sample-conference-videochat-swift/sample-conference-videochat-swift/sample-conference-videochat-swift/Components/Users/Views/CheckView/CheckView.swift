//
//  CheckView.swift
//  sample-conference-videochat-swift
//
//  Created by Vladimir Nybozhinsky on 17.10.2018.
//  Copyright © 2018 QuickBlox. All rights reserved.
//

import UIKit

class CheckView: UIView {
    
    var check: Bool? {
        didSet {
            debugPrint("chek did set \(String(describing: check))")
        }
    }
    
    private var imageView: UIImageView?
    
    func checkboxNormalImage() -> UIImage? {
        
        var _qm_checkbox_normal: UIImage? = nil
        
        var onceToken: Int = 0
        if (onceToken == 0) {
            _qm_checkbox_normal = UIImage(named: "checkbox-normal")
        }
        onceToken = 1
        
        return _qm_checkbox_normal
    }
    
    func checkboxPressedImage() -> UIImage? {
        
        var _qm_checkbox_pressed: UIImage? = nil
        
        var onceToken: Int = 0
        if (onceToken == 0) {
            
            _qm_checkbox_pressed = UIImage(named: "checkbox-pressed")
        }
        onceToken = 1
        
        return _qm_checkbox_pressed
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView = UIImageView(image: checkboxNormalImage())
        imageView?.frame = bounds
        if let aView = imageView {
            addSubview(aView)
        }
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        imageView?.frame = bounds
    }
    
    func setCheck(_ check: Bool) {
        
        if self.check != check {
            self.check = check
            
            imageView?.image = check ? checkboxPressedImage() : checkboxNormalImage()
        }
    }
}
