//
//  InputToolbar.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit

/**
 *  The `InputToolbarDelegate` protocol defines methods for interacting with
 *  a `ChatMessageInputToolbar` object.
 */
protocol InputToolbarDelegate: UIToolbarDelegate {
    /**
     *  Tells the delegate that the toolbar's `rightBarButtonItem` has been pressed.
     *
     *  @param toolbar The object representing the toolbar sending this information.
     *  @param sender  The button that received the touch event.
     */
    func messagesInputToolbar(_ toolbar: InputToolbar, didPressRightBarButton sender: UIButton)
    /**
     *  Tells the delegate that the toolbar's `leftBarButtonItem` has been pressed.
     *
     *  @param toolbar The object representing the toolbar sending this information.
     *  @param sender  The button that received the touch event.
     */
    func messagesInputToolbar(_ toolbar: InputToolbar, didPressLeftBarButton sender: UIButton)
}

class InputToolbar: UIToolbar {
    
    private var rightButtonStatusObserver:NSKeyValueObservation?
    private var leftButtonStatusObserver:NSKeyValueObservation?
    
    /**
     *  An instance of `InputToolbar` defines the input toolbar for
     *  composing a new message. It is displayed above and follow the movement of
     *  the system keyboard.
     */
    
    /**
     *  The object that acts as the delegate of the toolbar.
     */
    weak var inputToolbarDelegate: InputToolbarDelegate?
    
    override weak var delegate: UIToolbarDelegate? {
        didSet{
            inputToolbarDelegate = delegate as? InputToolbarDelegate
        }
    }
    /**
     *  Returns the content view of the toolbar. This view contains all subviews of the toolbar.
     */
    lazy public private(set) var contentView = loadToolbarContentView()
    /**
     *  A boolean value indicating whether the send button is on the right side of the toolbar or not.
     *
     *  @discussion The default value is `YES`, which indicates that the send button is the right-most subview of
     *  the toolbar's `contentView`. Set to `NO` to specify that the send button is on the left. This
     *  property is used to determine which touch events correspond to which actions.
     *
     *  @warning Note, this property *does not* change the positions of buttons in the toolbar's content view.
     *  It only specifies whether the `rightBarButtonItem `or the `leftBarButtonItem` is the send button.
     *  The other button then acts as the accessory button.
     */
    var sendButtonOnRight = true
    /**
     *  Specifies the default height for the toolbar. The default value is `44.0`. This value must be positive.
     */
    var preferredDefaultHeight: CGFloat = 44.0 {
        didSet {
            assert(preferredDefaultHeight > 0.0, "Invalid parameter not satisfying: preferredDefaultHeight > 0.0")
        }
    }
    
    /**
     *  Enables or disables the send button based on whether or not its `textView` has text.
     *  That is, the send button will be enabled if there is text in the `textView`, and disabled otherwise.
     */
    func setupBarButtonsEnabled(left: Bool, right: Bool) {
        contentView.rightBarButtonItem?.isEnabled = right
        contentView.leftBarButtonItem?.isEnabled = left
    }
    
    func toggleSendButtonEnabled(isUploaded: Bool) {
        let hasText = contentView.textView.hasText
        if sendButtonOnRight == true || isUploaded == true {
            contentView.rightBarButtonItem?.isEnabled = hasText || isUploaded
        }
    }
    
    /**
     *  Loads the content view for the toolbar.
     *
     *  @discussion Override this method to provide a custom content view for the toolbar.
     *
     *  @return An initialized `ToolbarContentView` if successful, otherwise `nil`.
     */
    open func loadToolbarContentView() -> ToolbarContentView {
        let nibName = String(describing:ToolbarContentView.self)
        let objects = Bundle.main.loadNibNamed(nibName, owner: nil)
        let toolbarContentView = objects!.first as! ToolbarContentView
        return toolbarContentView
    }
    
    // MARK: - Initialization
    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        layoutIfNeeded()
        let toolbarContentView: ToolbarContentView? = loadToolbarContentView()
        
        if let toolbarContentView = toolbarContentView {
            addSubview(toolbarContentView)
            contentView = toolbarContentView
            setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        }
        pinAllEdges(ofSubview: toolbarContentView)
        setNeedsUpdateConstraints()
        
        addObservers()
        toggleSendButtonEnabled(isUploaded: false)
    }
    
    deinit {
        removeObservers()
        contentView.removeFromSuperview()
    }
    
    // MARK: - Actions
    @objc func leftBarButtonPressed(_ sender: UIButton) {
        inputToolbarDelegate?.messagesInputToolbar(self, didPressLeftBarButton: sender)
    }
    
    @objc func rightBarButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        inputToolbarDelegate?.messagesInputToolbar(self, didPressRightBarButton: sender)
    }
    
    // MARK: - observing
    func addObservers() {
        leftButtonStatusObserver = contentView.observe(\ToolbarContentView.leftBarButtonItem,
                                                       options: [.new, .old],
                                                       changeHandler: {[weak self] (contentView, change) in
                                                        guard let self = self else {
                                                            return
                                                        }
                                                        
                                                        guard let leftButton = change.newValue  as? UIButton else {
                                                            return
                                                        }
                                                        leftButton.addTarget(self,
                                                                             action: #selector(self.leftBarButtonPressed(_:)),
                                                                             for: .touchUpInside)
        })
        
        rightButtonStatusObserver = contentView.observe(\ToolbarContentView.rightBarButtonItem,
                                                        options: [.new, .old],
                                                        changeHandler: {[weak self] (contentView, change) in
                                                            guard let self = self else {
                                                                return
                                                            }
                                                            
                                                            guard let leftButton = change.newValue  as? UIButton else {
                                                                return
                                                            }
                                                            
                                                            leftButton.addTarget(self,
                                                                                 action: #selector(self.rightBarButtonPressed(_:)),
                                                                                 for: .touchUpInside)
        })
        
    }
    
    func removeObservers() {
        if let leftButtonObserver = leftButtonStatusObserver {
            leftButtonObserver.invalidate()
            leftButtonStatusObserver = nil
        }
        if let rightButtonObserver = rightButtonStatusObserver {
            rightButtonObserver.invalidate()
            rightButtonStatusObserver = nil
        }
    }
}
