//
//  ChatCell.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit


struct ChatCellLayoutModel {
    
    var avatarSize: CGSize
    var containerSize: CGSize
    var containerInsets: UIEdgeInsets
    var topLabelHeight: CGFloat
    var timeLabelHeight: CGFloat
    var staticContainerSize: CGSize
    var spaceBetweenTopLabelAndTextView: CGFloat
    var spaceBetweenTextViewAndBottomLabel: CGFloat
    var maxWidthMarginSpace: CGFloat
    var maxWidth: CGFloat
    var bottomInfoViewHeight: CGFloat
    
    init(avatarSize: CGSize = .zero,
         containerInsets: UIEdgeInsets = .init(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0),
         topLabelHeight: CGFloat = 0.0,
         timeLabelHeight: CGFloat = 0.0,
         spaceBetweenTextViewAndBottomLabel: CGFloat = 0.0,
         maxWidth: CGFloat = 0.0,
         staticContainerSize: CGSize = .zero,
         containerSize: CGSize = .zero,
         maxWidthMarginSpace: CGFloat = 0.0,
         spaceBetweenTopLabelAndTextView: CGFloat = 0.0,
         incomingAttachmentleft: CGFloat = 0.0,
         bottomInfoViewHeight:CGFloat = 0.0) {
        self.avatarSize = avatarSize
        self.containerInsets = containerInsets
        self.topLabelHeight = topLabelHeight
        self.timeLabelHeight = timeLabelHeight
        self.spaceBetweenTextViewAndBottomLabel = spaceBetweenTextViewAndBottomLabel
        self.maxWidth = maxWidth
        self.staticContainerSize = staticContainerSize
        self.containerSize = containerSize
        self.maxWidthMarginSpace = maxWidthMarginSpace
        self.spaceBetweenTopLabelAndTextView = spaceBetweenTopLabelAndTextView
        self.bottomInfoViewHeight = bottomInfoViewHeight
    }
}

protocol ChatCellProtocol {
    /**
     *  Model that allows modifying layout without changing constraints directly.
     *
     *  @return ChatCellLayoutModel struct
     */
    static func layoutModel() -> ChatCellLayoutModel
    /**
     Registers cell for data view
     
     @param dataView data view. UITableView or UICollectionView
     */
    static func registerForReuse(inView dataView: Any)
}

/**
 *  The `ChatCellDelegate` protocol defines methods that allow you to manage
 *  additional interactions within the collection view cell.
 */

@objc protocol ChatCellDelegate: NSObjectProtocol {
    /**
     *  Protocol methods down below are required to be implemented
     */
    /**
     *  Tells the delegate that the avatarImageView of the cell has been tapped.
     *
     *  @param cell The cell that received the tap touch event.
     */
    func chatCellDidTapAvatar(_ cell: ChatCell)
    
    /**
     *  Tells the delegate that the message container of the cell has been tapped.
     *
     *  @param cell The cell that received the tap touch event.
     */
    func chatCellDidTapContainer(_ cell: ChatCell)
    
    /**
     *  Protocol methods down below are optional and can be ignored
     */
    /**
     *  Tells the delegate that the cell has been tapped at the point specified by position.
     *
     *  @param cell The cell that received the tap touch event.
     *  @param position The location of the received touch in the cell's coordinate system.
     */
    @objc optional func chatCell(_ cell: ChatCell, didTapAtPosition position: CGPoint)
    
    /**
     *  Tells the delegate that an actions has been selected from the menu of this cell.
     *  This method is automatically called for any registered actions.
     *
     *  @param cell The cell that displayed the menu.
     *  @param action The action that has been performed.
     *  @param sender The object that initiated the action.
     *
     *  @see `ChatCell`
     */
    @objc optional func chatCell(_ cell: ChatCell, didPerformAction action: Selector, withSender sender: Any)
    
    /**
     *  Tells the delegate that cell receive a tap action on text with a specific checking result.
     *
     *  @param cell               cell that received action
     *  @param textCheckingResult text checking result
     */
    @objc optional func chatCell(_ cell: ChatCell, didTapOn textCheckingResult: NSTextCheckingResult)
}

class ChatCell: UICollectionViewCell,
                UIGestureRecognizerDelegate,
                ChatReusableViewProtocol,
                ChatCellProtocol {
    
    static var chatCellMenuActions: Set<AnyHashable> = []
    
    /**
     *  Returns the message container view of the cell. This view is the superview of
     *  the cell's textView, image view or other
     *
     *  @discussion You may customize the cell by adding custom views to this container view.
     *  To do so, override `collectionView:cellForItemAtIndexPath:`
     *
     *  @warning You should not try to manipulate any properties of this view, for example adjusting
     *  its frame, nor should you remove this view from the cell or remove any of its subviews.
     *  Doing so could result in unexpected behavior.
     */
    @IBOutlet weak var containerView: ChatContainerView!
    @IBOutlet private weak var messageContainer: UIView!
    /**
     *  Property to set avatar label
     */
    @IBOutlet weak var avatarLabel: UILabel! {
        didSet {
            avatarLabel.setRoundedLabel(cornerRadius: 20.0)
            avatarContainerViewWidthConstraint.constant = 0.0
            avatarContainerViewHeightConstraint.constant = 0.0
        }
    }
    /**
     *  Property to set avatar view
     */
    @IBOutlet weak var avatarView: UIImageView! {
        didSet {
            avatarView.backgroundColor = UIColor.clear
            avatarContainerViewWidthConstraint.constant = 0.0
            avatarContainerViewHeightConstraint.constant = 0.0
        }
    }
    @IBOutlet weak var previewContainer: UIView!
    
    
    /**
     *  Returns chat message attributed label.
     *
     *  @warning You should not try to manipulate any properties of this view, for example adjusting
     *  its frame, nor should you remove this view from the cell or remove any of its subviews.
     *  Doing so could result in unexpected behavior.
     */
    @IBOutlet weak var textView: UILabel!
    /**
     *  Returns top chat message attributed label.
     *
     *  @warning You should not try to manipulate any properties of this view, for example adjusting
     *  its frame, nor should you remove this view from the cell or remove any of its subviews.
     *  Doing so could result in unexpected behavior.
     */
    @IBOutlet weak var topLabel: UILabel!
    /**
     *  Returns bottom chat message attributed label.
     *
     *  @warning You should not try to manipulate any properties of this view, for example adjusting
     *  its frame, nor should you remove this view from the cell or remove any of its subviews.
     *  Doing so could result in unexpected behavior.
     */
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet private weak var containerWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageContainerTopInsetConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageContainerLeftInsetConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageContainerBottomInsetConstraint: NSLayoutConstraint!
    @IBOutlet private weak var messageContainerRightInsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomLabelVerticalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLabelTextViewVerticalSpaceConstraint: NSLayoutConstraint!
    
    
    /**
     *  Returns the avatar container view of the cell. This view is the superview of the cell's avatarImageView.
     *
     *  @discussion You may customize the cell by adding custom views to this container view.
     *  To do so, override `collectionView:cellForItemAtIndexPath:`
     *
     *  @warning You should not try to manipulate any properties of this view, for example adjusting
     *  its frame, nor should you remove this view from the cell or remove any of its subviews.
     *  Doing so could result in unexpected behavior.
     */
    weak var avatarContainerView: UIView?
    
    /**
     *  Returns the underlying gesture recognizer for tap gestures in the avatarContainerView of the cell.
     *  This gesture handles the tap event for the avatarContainerView and notifies the cell's delegate.
     */
    weak var tapGestureRecognizer: UITapGestureRecognizer?
    
    /**
     *  The object that acts as the delegate for the cell.
     */
    weak var delegate: ChatCellDelegate?
    
    //MARK: - Class methods
    
    /**
     *  Returns the `UINib` object initialized for the cell.
     *
     *  @return The initialized `UINib` object or `nil` if there were errors during
     *  initialization or the nib file could not be located.
     */
    class func nib() -> UINib? {
        return ChatResources.nib(withNibName: String(describing:self))
    }
    
    /**
     *  Returns the default string used to identify a reusable cell for text message items.
     *
     *  @return The string used to identify a reusable cell.
     */
    class func cellReuseIdentifier() -> String? {
        return String(describing:self).components(separatedBy: ".").last!
    }
    
    class func layoutModel() -> ChatCellLayoutModel {
        
        let containerInsets = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 4.0, right: 5.0)
        
        let defaultLayoutModel = ChatCellLayoutModel(avatarSize: CGSize(width: 0.0, height: 0.0),
                                                     containerInsets: containerInsets,
                                                     topLabelHeight: 15.0,
                                                     timeLabelHeight: 15.0,
                                                     maxWidth: 0.0,
                                                     containerSize: .zero,
                                                     maxWidthMarginSpace: 20.0,
                                                     spaceBetweenTopLabelAndTextView: 12.0)
        return defaultLayoutModel
    }
    
    class func registerForReuse(inView dataView: Any) {
        let cellIdentifier = cellReuseIdentifier()
        if cellIdentifier == nil {
            debugPrint("[\(ChatCell.className)] Invalid parameter not satisfying: cellIdentifier != nil")
            return
        }
        let nib = self.nib()
        if nib == nil {
            debugPrint("[\(ChatCell.className)] Invalid parameter not satisfying: nib != nil")
            return
        }
        if (dataView is UITableView) {
            (dataView as? UITableView)?.register(nib, forCellReuseIdentifier: cellIdentifier ?? "")
        } else if (dataView is UICollectionView) {
            (dataView as? UICollectionView)?.register(nib, forCellWithReuseIdentifier: cellIdentifier ?? "")
        } else {
            debugPrint("[\(ChatCell.className)] Trying to register cell for unsupported dataView")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.isOpaque = true
        messageContainerTopInsetConstraint?.constant = 0
        messageContainerLeftInsetConstraint?.constant = 0
        messageContainerBottomInsetConstraint?.constant = 0
        messageContainerRightInsetConstraint?.constant = 0
        
        topLabelHeightConstraint?.constant = 0
        
        topLabelTextViewVerticalSpaceConstraint?.constant = 0
        textViewBottomLabelVerticalSpaceConstraint?.constant = 0
        
        backgroundColor = UIColor.clear
        messageContainer?.backgroundColor = UIColor.clear
        topLabel?.backgroundColor = UIColor.clear
        textView?.backgroundColor = UIColor.clear
        
        containerView?.backgroundColor = UIColor.clear
        
        layer.drawsAsynchronously = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tap.delegate = self
        addGestureRecognizer(tap)
        tapGestureRecognizer = tap
    }
    
    @objc func handleTapGesture(_ tap: UITapGestureRecognizer?) {
        
        let touchPt: CGPoint? = tap?.location(in: self)
        
        if containerView.frame.contains(touchPt!) {
            delegate?.chatCellDidTapContainer(self)
        } else if let _ = delegate?.chatCell!(self, didTapAtPosition: touchPt!) {
            
            delegate?.chatCell!(self, didTapAtPosition: touchPt!)
        }
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        
        guard let customAttributes = layoutAttributes as? ChatCellLayoutAttributes else {
            return
        }
        if let avatarContainerViewHeightConstraint = avatarContainerViewHeightConstraint,
           let avatarContainerViewWidthConstraint = avatarContainerViewWidthConstraint {
            updateConstraint(avatarContainerViewHeightConstraint, withConstant: customAttributes.avatarSize.height)
            updateConstraint(avatarContainerViewWidthConstraint, withConstant: customAttributes.avatarSize.width)
        }
        
        if let topLabelHeightConstraint = topLabelHeightConstraint {
            updateConstraint(topLabelHeightConstraint, withConstant: customAttributes.topLabelHeight)
        }
        
        if let messageContainerTopInsetConstraint = messageContainerTopInsetConstraint,
           let messageContainerLeftInsetConstraint = messageContainerLeftInsetConstraint,
           let messageContainerBottomInsetConstraint = messageContainerBottomInsetConstraint,
           let messageContainerRightInsetConstraint = messageContainerRightInsetConstraint {
            updateConstraint(messageContainerTopInsetConstraint, withConstant: customAttributes.containerInsets.top)
            updateConstraint(messageContainerLeftInsetConstraint, withConstant: customAttributes.containerInsets.left)
            updateConstraint(messageContainerBottomInsetConstraint, withConstant: customAttributes.containerInsets.bottom)
            updateConstraint(messageContainerRightInsetConstraint, withConstant: customAttributes.containerInsets.right)
        }
        
        if let topLabelTextViewVerticalSpaceConstraint = topLabelTextViewVerticalSpaceConstraint {
            updateConstraint(topLabelTextViewVerticalSpaceConstraint, withConstant: customAttributes.spaceBetweenTopLabelAndTextView)
        }
        
        if let textViewBottomLabelVerticalSpaceConstraint = textViewBottomLabelVerticalSpaceConstraint {
            updateConstraint(textViewBottomLabelVerticalSpaceConstraint, withConstant: customAttributes.spaceBetweenTextViewAndBottomLabel)
        }
        
        if let containerWidthConstraint = containerWidthConstraint {
            updateConstraint(containerWidthConstraint, withConstant: customAttributes.containerSize.width)
        }
        
        layoutIfNeeded()
    }
    
    func updateConstraint(_ constraint: NSLayoutConstraint, withConstant constant: CGFloat) {
        if Int(constraint.constant) == Int(constant) {
            return
        }
        constraint.constant = constant
    }
    
    override var bounds: CGRect {
        didSet {
            if UIDevice.current.systemVersion.compare("8.0", options: .numeric, range: nil, locale: .current) == .orderedAscending {
                layoutIfNeeded()
                contentView.frame = bounds
            }
        }
    }
    
    //MARK: - Gesture recognizers
    func imageViewDidTap(_ imageView: UIImageView) {
        delegate?.chatCellDidTapAvatar(self)
    }
    
    //MARK: - Menu actions
    override class func responds(to aSelector: Selector) -> Bool {
        if chatCellMenuActions.contains(NSStringFromSelector(aSelector)) {
            return true
        }
        return super.responds(to: aSelector)
    }
}

extension ChatCell {
    func configure(with message: QBChatMessage, dialogType:QBChatDialogType) {
        if let dateCell = self as? ChatDateCell {
            dateCell.isUserInteractionEnabled = false
            dateCell.dateLabel.text = message.messageText().string
            delegate = nil
            return
        }
        
        if let notificationCell = self as? ChatNotificationCell {
            notificationCell.isUserInteractionEnabled = false
            notificationCell.notificationLabel.text = message.messageText().string
            delegate = nil
            return
        }
        
        let username = message.topLabelText()
        topLabel.text = username.string
        if (self is ChatIncomingCell || self is ChatAttachmentIncomingCell) && dialogType != .private {
            let userName = username.string
            avatarLabel.text = String(userName.capitalized.first ?? Character("QB"))
            avatarLabel.backgroundColor = message.senderID.generateColor()
        }
        
        timeLabel.text = message.timeLabelText().string
        if let chatOutgoingCell = self as? ChatOutgoingCell {
            let image = dialogType == .publicGroup ? UIImage() : message.statusImage()
            chatOutgoingCell.setupStatusImage(image)
            
        }
        
        if let textView = textView {
            textView.attributedText = message.messageText()
        }
        
        if let attachmentCell = self as? ChatAttachmentCell {
            guard let attachment = message.attachments?.first else {
                return
            }
            if message.isForwardedMessage == true {
                attachmentCell.forwardedLabel.attributedText = message.forwardedText()
                attachmentCell.forwardInfoHeightConstraint.constant = 35.0
            } else {
                attachmentCell.forwardInfoHeightConstraint.constant = 0.0
            }
            if attachmentCell is ChatAttachmentOutgoingCell {
                if let attachmentCell = attachmentCell as? ChatAttachmentOutgoingCell {
                    let image = dialogType == .publicGroup ? UIImage() : message.statusImage()
                    attachmentCell.setupStatusImage(image)
                }
            }
            attachmentCell.setupAttachment(attachment)
        }
    }
}
