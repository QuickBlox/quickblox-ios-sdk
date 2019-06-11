//
//  ToolbarContentView.swift
//  Swift-ChatViewController
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

enum ToolbarPosition : Int {
    case right
    case left
    case bottom
}

struct ToolbarConstant {
    /**
     *  A constant value representing the default spacing to use for the left and right edges
     *  of the toolbar content view.
     */
    static let horizontalSpacingDefault: CGFloat = 8.0
}

class ToolbarButton: UIButton {
    var position: ToolbarPosition?
}

/**
 *  A `ToolbarContentView` represents the content displayed in a `InputToolbar`.
 *  These subviews consist of a left button, a text view, and a right button. One button is used as
 *  the send button, and the other as the accessory button. The text view is used for composing messages.
 */
class ToolbarContentView: UIView {
    /**
     *  Returns the text view in which the user composes a message.
     */
    @IBOutlet weak var textView: PlaceHolderTextView!
    /**
     *  The container view for the leftBarButtonItem.
     *
     *  @discussion
     *  You may use this property to add additional button items to the left side of the toolbar content view.
     *  However, you will be completely responsible for responding to all touch events for these buttons
     *  in your `ChatViewController` subclass.
     */
    @IBOutlet weak var leftBarButtonContainerView: UIView!
    @IBOutlet private weak var leftBarButtonContainerViewWidthConstraint: NSLayoutConstraint!
    /**
     *  The container view for the rightBarButtonItem.
     *
     *  @discussion
     *  You may use this property to add additional button items to the right side of the toolbar content view.
     *  However, you will be completely responsible for responding to all touch events for these buttons
     *  in your `ChatViewController` subclass.
     */
    @IBOutlet weak var rightBarButtonContainerView: UIView!
    @IBOutlet private weak var rightBarButtonContainerViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var leftHorizontalSpacingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightHorizontalSpacingConstraint: NSLayoutConstraint!
    
    //MARK: - Properties
    override var backgroundColor: UIColor? {
        didSet {
            guard let color = backgroundColor,
                let leftContainer = leftBarButtonContainerView,
                let rightContainer =  rightBarButtonContainerView else {
                return
            }
            leftContainer.backgroundColor = color
            rightContainer.backgroundColor = color
        }
    }
    
    /**
     *  A custom button item displayed on the left of the toolbar content view.
     *
     *  @discussion The frame height of this button is ignored. When you set this property, the button
     *  is fitted within a pre-defined default content view, the leftBarButtonContainerView,
     *  whose height is determined by the height of the toolbar. However, the width of this button
     *  will be preserved. You may specify a new width using `leftBarButtonItemWidth`.
     *  If the frame of this button is equal to `CGRect.zero` when set, then a default frame size will be used.
     *  Set this value to `nil` to remove the button.
     */
    @objc dynamic var leftBarButtonItem: UIButton? {
        willSet {
            if (self.leftBarButtonItem != nil) {
                self.leftBarButtonItem?.removeFromSuperview()
            }
        }
        
        didSet {
            
            guard let leftBarButtonItem = leftBarButtonItem else {
                self.leftBarButtonItem = nil
                leftHorizontalSpacingConstraint.constant = 0.0
                leftBarButtonItemWidth = 0.0
                leftBarButtonContainerView.isHidden = true
                
                return
            }
            
            if leftBarButtonItem.frame.equalTo(CGRect.zero) {
                leftBarButtonItem.frame = leftBarButtonContainerView.bounds
            }
            
            leftBarButtonContainerView.isHidden = false
            leftHorizontalSpacingConstraint.constant = ToolbarConstant.horizontalSpacingDefault
            leftBarButtonItemWidth = leftBarButtonItem.frame.width
            
            leftBarButtonItem.translatesAutoresizingMaskIntoConstraints = false
            
            leftBarButtonContainerView.addSubview(leftBarButtonItem)
            
            leftBarButtonContainerView.pinAllEdges(ofSubview: leftBarButtonItem)
            setNeedsUpdateConstraints()
            
            self.leftBarButtonItem = leftBarButtonItem
        }
    }
    
    /**
     *  Specifies the amount of spacing between the content view and the leading edge of leftBarButtonItem.
     *
     *  @discussion The default value is `8.0f`.
     */
    var leftContentPadding: CGFloat {
        get {
            return leftHorizontalSpacingConstraint.constant
        }
        set(leftContentPadding) {
            leftHorizontalSpacingConstraint.constant = leftContentPadding
            setNeedsUpdateConstraints()
        }
    }
    /**
     *  Specifies the width of the leftBarButtonItem.
     *
     *  @discussion This property modifies the width of the leftBarButtonContainerView.
     */
    var leftBarButtonItemWidth: CGFloat {
        get {
            return leftBarButtonContainerViewWidthConstraint.constant
        }
        set(leftBarButtonItemWidth) {
            leftBarButtonContainerViewWidthConstraint.constant = leftBarButtonItemWidth
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     *  A custom button item displayed on the right of the toolbar content view.
     *
     *  @discussion The frame height of this button is ignored. When you set this property, the button
     *  is fitted within a pre-defined default content view, the rightBarButtonContainerView,
     *  whose height is determined by the height of the toolbar. However, the width of this button
     *  will be preserved. You may specify a new width using `rightBarButtonItemWidth`.
     *  If the frame of this button is equal to `CGRect.zero` when set, then a default frame size will be used.
     *  Set this value to `nil` to remove the button.
     */
    @objc dynamic var rightBarButtonItem: UIButton? {
        willSet {
            if self.rightBarButtonItem != nil {
                self.rightBarButtonItem?.removeFromSuperview()
            }
        }
        didSet {
            guard let rightBarButtonItem = rightBarButtonItem else {
                rightHorizontalSpacingConstraint.constant = 0.0
                rightBarButtonItemWidth = 0.0
                rightBarButtonContainerView.isHidden = true
                return
            }
            
            if rightBarButtonItem.frame.equalTo(.zero) {
                rightBarButtonItem.frame = rightBarButtonContainerView.bounds
            }
            
            rightBarButtonContainerView.isHidden = false
            rightHorizontalSpacingConstraint.constant = ToolbarConstant.horizontalSpacingDefault
            rightBarButtonItemWidth = rightBarButtonItem.frame.width
            
            rightBarButtonItem.translatesAutoresizingMaskIntoConstraints = false
            
            rightBarButtonContainerView.addSubview(rightBarButtonItem)
            
            rightBarButtonContainerView.pinAllEdges(ofSubview: rightBarButtonItem)
            setNeedsUpdateConstraints()
        }
    }
    
    /**
     *  Specifies the width of the rightBarButtonItem.
     *
     *  @discussion This property modifies the width of the rightBarButtonContainerView.
     */
    var rightBarButtonItemWidth: CGFloat {
        get {
            return rightBarButtonContainerViewWidthConstraint.constant
        }
        set(rightBarButtonItemWidth) {
            rightBarButtonContainerViewWidthConstraint.constant = rightBarButtonItemWidth
            setNeedsUpdateConstraints()
        }
    }
    /**
     *  Specifies the amount of spacing between the content view and the trailing edge of rightBarButtonItem.
     *
     *  @discussion The default value is `8.0f`.
     */
    var rightContentPadding: CGFloat {
        get {
            return rightHorizontalSpacingConstraint.constant
        }
        set(rightContentPadding) {
            rightHorizontalSpacingConstraint.constant = rightContentPadding
            setNeedsUpdateConstraints()
        }
    }
    
    //MARK: - Class methods
    
    /**
     *  Returns the `UINib` object initialized for a `ToolbarContentView`.
     *
     *  @return The initialized `UINib` object or `nil` if there were errors during
     *  initialization or the nib file could not be located.
     */
    class func nib() -> UINib? {
        return ChatResources.nib(withNibName: String(describing:ToolbarContentView.self))
    }
    
    //MARK: - Life Cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        leftHorizontalSpacingConstraint.constant = ToolbarConstant.horizontalSpacingDefault
        rightHorizontalSpacingConstraint.constant = ToolbarConstant.horizontalSpacingDefault
        backgroundColor = .clear
    }
    
    // MARK: - UIView overrides
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        if let textView = textView {
            textView.setNeedsDisplay()
        }
    }
}
