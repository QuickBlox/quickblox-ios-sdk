//
//  PlaceHolderTextView.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

struct PlaceHolderConstant {
    static let placeholderDidChangeHeight = "com.quickblox.swiftchat.PlaceholderDidChangeHeight"
    static let defaultPlaceHolderColor = UIColor.black.withAlphaComponent(0.3)
    static let defaultFont: UIFont = .systemFont(ofSize: 16.0)
    static let defaultTextColor: UIColor = .black
    static let defaultTextAlignment: NSTextAlignment = .natural
}

/**
 *  A delegate object used to notify the receiver of paste events from a `PlaceHolderTextView`.
 */
protocol PlaceHolderTextViewPasteDelegate: class {
    /**
     *  Asks the delegate whether or not the `textView` should use the original implementation of `-[UITextView paste]`.
     *
     *  @discussion Use this delegate method to implement custom pasting behavior.
     *  You should return `NO` when you want to handle pasting.
     *  Return `YES` to defer functionality to the `textView`.
     */
    func placeHolderTextView(_ textView: PlaceHolderTextView, shouldPasteWithSender sender: Any?) -> Bool
}

class PlaceHolderTextView: UITextView {
    /**
     *  The object that acts as the paste delegate of the text view.
     */
    weak var placeholderTextViewPasteDelegate: PlaceHolderTextViewPasteDelegate?
    /**
     *  The text to be displayed when the text view is empty. The default value is `nil`.
     */
    @IBInspectable var placeHolder: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    /**
     *  The color of the place holder text. The default value is `[UIColor lightGrayColor]`.
     */
    @IBInspectable var placeHolderColor: UIColor = PlaceHolderConstant.defaultPlaceHolderColor {
        didSet {
            setNeedsDisplay()
        }
    }
    /**
     *  Determines whether or not the text view contains text after trimming white space
     *  from the front and back of its string.
     *
     *  @return `YES` if the text view contains text, `NO` otherwise.
     */
    
    override var hasText: Bool {
        return text.stringByTrimingWhitespace().isEmpty == false
    }
    
    override var bounds: CGRect {
        didSet {
            if contentSize.height <= self.bounds.size.height + 1 {
                contentOffset = CGPoint.zero // Fix wrong contentOfset
            }
        }
    }
    
    override var text: String! {
        didSet {
            setNeedsDisplay()
        }
    }
    /**
     *  Determines whether or not the text view contains image as NSTextAttachment
     *
     *
     *  @return `YES` if the text view contains attachment, `NO` otherwise.
     */
    
    private weak var heightConstraint: NSLayoutConstraint?
    private weak var minHeightConstraint: NSLayoutConstraint?
    private weak var maxHeightConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    func configureTextView() {
        
        translatesAutoresizingMaskIntoConstraints = false
        let cornerRadius: CGFloat = 6.0
        
        backgroundColor = .white
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = cornerRadius
        
        scrollIndicatorInsets = UIEdgeInsets(top: cornerRadius, left: 0.0,
                                             bottom: cornerRadius, right: 0.0)
        
        textContainerInset = UIEdgeInsets(top: 4.0, left: 2.0, bottom: 4.0, right: 2.0)
        contentInset = UIEdgeInsets(top: 1.0, left: 0.0, bottom: 1.0, right: 0.0)
        
        isScrollEnabled = true
        scrollsToTop = false
        isUserInteractionEnabled = true
        
        setupDefaultSettings()
        
        isSelectable = true
        
        contentMode = .redraw
        dataDetectorTypes = []
        keyboardAppearance = .default
        keyboardType = .default
        returnKeyType = .default
        
        text = nil
        
        associateConstraints()
        addTextViewNotificationObservers()
    }
    
    func setupDefaultSettings() {
        
        font = PlaceHolderConstant.defaultFont
        textColor = .black
        textAlignment = .natural
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        configureTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureTextView()
    }
    
    deinit {
        removeTextViewNotificationObservers()
    }

    func associateConstraints() {
        // iterate through all text view's constraints and identify
        // height, max height and min height constraints.
        
        for constraint in constraints {
            
            if constraint.firstAttribute == .height {
                if constraint.relation == .equal {
                    heightConstraint = constraint
                } else if constraint.relation == .lessThanOrEqual {
                    maxHeightConstraint = constraint
                } else if constraint.relation == .greaterThanOrEqual {
                    minHeightConstraint = constraint
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // calculate size needed for the text to be visible without scrolling
        var sizeThatFits = layoutManager.usedRect(for: textContainer).size
        sizeThatFits.height += textContainerInset.top + textContainerInset.bottom
        
        var newHeight: CGFloat = sizeThatFits.height
        
        // if there is any minimal height constraint set, make sure we consider that
        if let maxHeightConstraint = maxHeightConstraint {
            newHeight = min(newHeight, maxHeightConstraint.constant)
        }
        
        // if there is any maximal height constraint set, make sure we consider that
        if let minHeightConstraint = minHeightConstraint {
            newHeight = max(newHeight, minHeightConstraint.constant)
        }
        
        // update the height constraint
        heightConstraint?.constant = newHeight
    }
    
    // MARK: - Composer text view
    func hasTextAttachment() -> Bool {
        
        var hasTextAttachment = false
        let rangeLocation = NSRange(location: 0, length: attributedText?.length ?? 0)
        if attributedText?.length != nil {
            
            attributedText?.enumerateAttribute(.attachment, in: rangeLocation, options: []) { (value, range, stop)  in
                if (value is NSTextAttachment) {
                    let attachment = value as? NSTextAttachment
                    var image: UIImage? = nil
                    if attachment?.image != nil {
                        image = attachment?.image
                    } else {
                        image = attachment?.image(forBounds: attachment?.bounds ?? CGRect.zero, textContainer: nil, characterIndex: Int(range.location))
                    }
                    
                    if image != nil {
                        hasTextAttachment = true
                        stop[0] = true
                    }
                }
            }
        }
        return hasTextAttachment
    }
    
    // MARK: - UITextView overrides
    override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set(attributedText) {
            
            super.attributedText = attributedText
            setNeedsDisplay()
        }
    }
    
    override var font: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override  var textAlignment: NSTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func paste(_ sender: Any?) {
        
        if let _ = placeholderTextViewPasteDelegate?.placeHolderTextView(self, shouldPasteWithSender: sender) {
            super.paste(sender)
        } else if placeholderTextViewPasteDelegate == nil {
            super.paste(sender)
        }
    }
    
    // MARK: - Drawing
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if text.isEmpty == true, placeHolder.isEmpty == true, hasTextAttachment() == false {
            placeHolderColor.set()
            placeHolder.draw(in: rect.insetBy(dx: 7.0, dy: 5.0), withAttributes: placeholderTextAttributes())
        }
    }
    
    // MARK: - Notifications
    func addTextViewNotificationObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveTextViewNotification(_:)),
                                               name: UITextView.textDidChangeNotification,
                                               object: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveTextViewNotification(_:)),
                                               name: UITextView.textDidBeginEditingNotification,
                                               object: self)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveTextViewNotification(_:)),
                                               name: UITextView.textDidEndEditingNotification,
                                               object: self)
    }
    
    func removeTextViewNotificationObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UITextView.textDidChangeNotification,
                                                  object: self)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UITextView.textDidBeginEditingNotification,
                                                  object: self)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UITextView.textDidEndEditingNotification,
                                                  object: self)
    }
    
    @objc func didReceiveTextViewNotification(_ notification: Notification?) {
        setNeedsDisplay()
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if UIPasteboard.general.image != nil && action == #selector(self.paste(_:)) {
            return true
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    // MARK: - Utilities
    func placeholderTextAttributes() -> [NSAttributedString.Key : Any]? {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = textAlignment
        
        return [NSAttributedString.Key.font: font ?? PlaceHolderConstant.defaultFont,
                NSAttributedString.Key.foregroundColor: placeHolderColor,
                NSAttributedString.Key.paragraphStyle: paragraphStyle]
    }
    
    // MARK: - UIMenuController
    override var canBecomeFirstResponder: Bool {
        return super.canBecomeFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
}
