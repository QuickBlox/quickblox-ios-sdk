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
    static let defaultPlaceHolderColor = UIColor.black
    static let defaultFont: UIFont = .systemFont(ofSize: 15)
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
    @IBInspectable var placeHolder: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    /**
     *  The color of the place holder text. The default value is `UIColor.black`.
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
        placeholder = text.stringByTrimingWhitespace().isEmpty == false ? nil : "Send message"
        return text.stringByTrimingWhitespace().isEmpty == false
    }

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

    private func resizePlaceholder() {
        if let placeholderLabel = viewWithTag(100) as? UILabel {
            let labelX = textContainer.lineFragmentPadding + 1
            let labelY = textContainerInset.top + 0
            let labelWidth = frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height

            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }

    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()

        placeholderLabel.font = .systemFont(ofSize: 15, weight: .thin)
        placeholderLabel.textColor = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)
        placeholderLabel.tag = 100

        placeholderLabel.isHidden = text.isEmpty == false

        addSubview(placeholderLabel)
        resizePlaceholder()
        delegate = self
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
        let cornerRadius: CGFloat = 0.0

        backgroundColor = .white
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.white.cgColor
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

        placeholder = "Send message..."
        text = ""

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

        if text.isEmpty == true, placeHolder?.isEmpty == true, hasTextAttachment() == false {
            placeHolderColor.set()
            placeHolder?.draw(in: rect.insetBy(dx: 7.0, dy: 5.0), withAttributes: placeholderTextAttributes())
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

        return [.font: font ?? PlaceHolderConstant.defaultFont,
                .foregroundColor: placeHolderColor,
                .paragraphStyle: paragraphStyle]
    }

    // MARK: - UIMenuController
    override var canBecomeFirstResponder: Bool {
        return super.canBecomeFirstResponder
    }

    override func becomeFirstResponder() -> Bool {
        return super.becomeFirstResponder()
    }
}

extension PlaceHolderTextView: UITextViewDelegate {
     func textViewDidChange(_ textView: UITextView) {
           if let placeholderLabel = viewWithTag(100) as? UILabel {
               placeholderLabel.isHidden = text.isEmpty == false
           }
       }
}
