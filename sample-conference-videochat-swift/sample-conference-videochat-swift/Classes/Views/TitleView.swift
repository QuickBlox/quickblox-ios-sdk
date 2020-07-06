//
//  TitleView.swift
//  sample-conference-videochat-swift
//
//  Created by Injoit on 10/10/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

class TitleView: UILabel {
    func setupTitleView(title: String, subTitle: String) {
    
        let titleString = title + "\n" + subTitle
        
        let attrString = NSMutableAttributedString(string: titleString)
        
        let titleRange: NSRange = (titleString as NSString).range(of: title)
        attrString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17.0), range: titleRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.white, range: titleRange)
        
        let numberChatsRange: NSRange = (titleString as NSString).range(of: subTitle)
        attrString.addAttribute(.font, value: UIFont.systemFont(ofSize: 13.0), range: numberChatsRange)
        attrString.addAttribute(.foregroundColor, value: UIColor.white.withAlphaComponent(0.6), range: numberChatsRange)
        
        numberOfLines = 2
        attributedText = attrString
        textAlignment = .center
        bounds.size.width = 200.0
    }
}
