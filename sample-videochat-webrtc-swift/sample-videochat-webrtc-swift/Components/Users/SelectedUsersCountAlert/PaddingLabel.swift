//
//  PaddingLabel.swift
//  sample-videochat-webrtc-swift
//
//  Created by Injoit on 30.07.2021.
//  Copyright © 2021 QuickBlox. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    //MARK: - Properties
    var textPaddingInsets = UIEdgeInsets.zero {
         didSet { invalidateIntrinsicContentSize() }
     }
     
    //MARK: - Life Cycle
     override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
         let textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
         let invertedInsets = UIEdgeInsets(top: -textPaddingInsets.top,
                                           left: -textPaddingInsets.left,
                                           bottom: -textPaddingInsets.bottom,
                                           right: -textPaddingInsets.right)
         return textRect.inset(by: invertedInsets)
     }
     
     override func drawText(in rect: CGRect) {
         super.drawText(in: rect.inset(by: textPaddingInsets))
     }
}
