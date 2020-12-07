//
//  PushTextView.swift
//  sample-push-notifications-swift
//
//  Created by Injoit on 3/19/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

import UIKit

class PushTextView: UITextView {
    //MARK: - Life Cycle
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
//MARK: - UITextViewDelegate
extension PushTextView: UITextViewDelegate {
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    override var text: String! {
        didSet {
            if let placeholderLabel = viewWithTag(100) as? UILabel {
                placeholderLabel.isHidden = text.isEmpty == false
            }
        }
    }
    
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = viewWithTag(100) as? UILabel {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                addPlaceholder(newValue!)
            }
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        if let placeholderLabel = viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = text.isEmpty == false
        }
    }
    
    private func resizePlaceholder() {
        if let placeholderLabel = viewWithTag(100) as? UILabel {
            let labelX = textContainer.lineFragmentPadding + 10
            let labelY = textContainerInset.top + 2
            let labelWidth = frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = UIFont.systemFont(ofSize: 17.0)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.tag = 100
        
        placeholderLabel.isHidden = text.isEmpty == false
        
        addSubview(placeholderLabel)
        resizePlaceholder()
        delegate = self
    }
}
