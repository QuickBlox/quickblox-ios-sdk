//
//  TypingIndicatorFooterView.swift
//  sample-chat-swift
//
//  Created by Injoit on 6/22/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class TypingIndicatorFooterView: QMTypingIndicatorFooterView {
    
    @IBOutlet weak var typingTextLabel: UILabel!
    
    override static func nib() -> UINib {
        return UINib(nibName: NSStringFromClass(self.self).componentsSeparatedByString(".").last!, bundle: NSBundle.mainBundle())
    }
    
    override static func footerReuseIdentifier() -> String {
        return NSStringFromClass(self.self).componentsSeparatedByString(".").last!
    }
    
}