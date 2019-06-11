//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Injoit on 1/28/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

import UIKit
import Photos
import TTTAttributedLabel
import SafariServices
import CoreTelephony

var messageTimeDateFormatter: DateFormatter {
    struct Static {
        static let instance : DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
        }()
    }    
    return Static.instance
}

enum MessageStatus: Int {
    case sent
    case sending
    case notSent
}

struct ChatViewControllerConstant {
    static let messagePadding: CGFloat = 40.0
    static let attachmentBarHeight: CGFloat = 100.0
}

class ChatViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var collectionView: ChatCollectionView!
    /**
     *  Returns the input toolbar view object managed by this view controller.
     *  This view controller is the toolbar's delegate.
     */
    @IBOutlet private weak var inputToolbar: InputToolbar!
    
    
    //MARK: - Private IBOutlets
    @IBOutlet private weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var toolbarBottomLayoutGuide: NSLayoutConstraint!
    
    private lazy var infoItem = UIBarButtonItem(title: "Chat Info",
                                                style: .plain,
                                                target: self,
                                                action:#selector(didTapInfo(_:)))
    
    //MARK: - Properties
    private lazy var dataSource: ChatDataSource = {
        let dataSource = ChatDataSource()
        dataSource.delegate = self
        return dataSource
    }()
    private let chatManager = ChatManager.instance
    private var offsetY: CGFloat = 0.0
    private let blueBubble = UIImage(named: "ios_bubble_blue")
    private let grayBubble = UIImage(named: "ios_bubble_gray")
    
    private var isDeviceLocked = false
    
    private var isUploading = false
    private var attachmentMessage: QBChatMessage?
    
    /**
     *  This property is required when creating a ChatViewController.
     */
    var dialogID: String! {
        didSet {
            self.dialog = chatManager.storage.dialog(withID: dialogID)
        }
    }
    private var dialog: QBChatDialog!
    /**
     *  Cell's contact request delegate.
     */
    private var actionsHandler: ChatActionsHandler?
    /**
     *  The display name of the current user who is sending messages.
     *
     *  @discussion This value does not have to be unique. This value must not be `nil`.
     */
    internal var senderDisplayName = ""
    /**
     *  The string identifier that uniquely identifies the current user sending messages.
     *
     *  @discussion This property is used to determine if a message is incoming or outgoing.
     *  All message data objects returned by `collectionView:messageDataForItemAtIndexPath:` are
     *  checked against this identifier. This value must not be `nil`.
     */
    internal var senderID: UInt = 0
    /**
     *  Specifies whether or not the view controller should automatically scroll to the most recent message
     *  when the view appears and when sending, receiving, and composing a new message.
     *
     *  @discussion The default value is `true`, which allows the view controller to scroll automatically to the most recent message.
     *  Set to `false` if you want to manage scrolling yourself.
     */
    private var automaticallyScrollsToMostRecentMessage = true
    /**
     *  Specifies an additional inset amount to be added to the collectionView's contentInsets.top value.
     *
     *  @discussion Use this property to adjust the top content inset to account for a custom subview at the top of your view controller.
     */
    private var topContentAdditionalInset: CGFloat = 0.0 {
        didSet {
            updateCollectionViewInsets()
        }
    }
    /**
     *  Enable text checking types for cells. Must be set in view did load.
     */
    private var enableTextCheckingTypes: NSTextCheckingTypes = NSTextCheckingAllTypes
    /**
     Input bar start pos
     */
    private var inputToolBarStartPos: UInt = 0
    private var collectionBottomConstant: CGFloat = 0.0
    //MARK: - Private Properties
    private var isMenuVisible: Bool {
        return selectedIndexPathForMenu != nil && UIMenuController.shared.isMenuVisible
    }
    
    private lazy var pickerController: UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        return pickerController
    }()
    
    private var cancel = false
    
    private var willResignActiveBlock: AnyObject?
    private var willActiveBlock: AnyObject?
    
    private var selectedIndexPathForMenu: IndexPath?
    
    private lazy var systemInputToolbar: KVOView = {
        let inputToolbar = KVOView()
        inputToolbar.collectionView = collectionView
        inputToolbar.chatInputView = inputToolbar;
        inputToolbar.frame = .zero
        inputToolbar.hostViewFrameChangeBlock = { [weak self] (view: UIView?, animated: Bool) -> Void in
            guard let self = self,
                let superview = self.view.superview else {
                    return
            }
            
            let inputToolBarStartPos = CGFloat(self.inputToolBarStartPos)
            
            guard let view = view else {
                self.setupToolbarBottom(constraintValue:inputToolBarStartPos, animated: animated)
                return
            }
            
            let convertedViewPoint = superview.convert(view.frame.origin, to: view)
            var pos = view.frame.size.height - convertedViewPoint.y
            
            if self.inputToolbar.contentView.textView.isFirstResponder,
                superview.frame.origin.y > 0.0,
                pos <= 0.0 {
                return
            }
            if pos < inputToolBarStartPos {
                pos = inputToolBarStartPos
            }
            self.setupToolbarBottom(constraintValue:pos, animated: animated)
        }
        return inputToolbar
    }()
    
    private lazy var attachmentBar: AttachmentBar = {
        let attachmentBar = AttachmentBar()
        attachmentBar.setRoundBorderEdgeView(cornerRadius: 0.0, borderWidth: 0.5, borderColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
        return attachmentBar
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        QBChat.instance.addDelegate(self)
        setupViewMessages()
        dataSource.delegate = self
        inputToolbar.inputToolbarDelegate = self
        inputToolbar.setupBarButtonsEnabled(left: true, right: false)
        
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = [] //same UIRectEdgeNone
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        QBChat.instance.addDelegate(self)
        SVProgressHUD.dismiss()
        let currentUser = Profile()
        guard currentUser.isFull == true else {
                return
        }

        if QBChat.instance.isConnected == true {
            loadMessages()
        }
        
        senderID = currentUser.ID
        title = dialog.name ?? ""
        registerForNotifications(true)
        
        willResignActiveBlock = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification,
                                                                       object: nil,
                                                                       queue: nil) { [weak self] (notification) in
            self?.isDeviceLocked = true
        }
        willActiveBlock = NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification,
                                                                 object: nil,
                                                                 queue: nil) { [weak self] (notification) in
            self?.isDeviceLocked = false
            self?.collectionView.reloadData()
        }
        
        if inputToolbar.contentView.textView.isFirstResponder == false {
            toolbarBottomLayoutGuide.constant = CGFloat(inputToolBarStartPos)
        }
        updateCollectionViewInsets()
        collectionBottomConstraint.constant = collectionBottomConstant
        if dialog.type != .publicGroup {
            navigationItem.rightBarButtonItem = infoItem
        }
        
        //MARK: - Reachability
        let updateConnectionStatus: ((_ status: NetworkConnectionStatus) -> Void)? = { [weak self] status in
            let notConnection = status == .notConnection
            if notConnection == true, self?.isUploading == true {
                self?.cancelUploadFile()
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        updateConnectionStatus?(Reachability.instance.networkConnectionStatus())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let willResignActive = willResignActiveBlock {
            NotificationCenter.default.removeObserver(willResignActive)
        }
        if let willActiveBlock = willActiveBlock {
            NotificationCenter.default.removeObserver(willActiveBlock)
        }
        NotificationCenter.default.removeObserver(self)
        // clearing typing status blocks
        dialog.clearTypingStatusBlocks()
        registerForNotifications(false)
    }
    
    
    //MARK: - Internal Methods
    //MARK: - Setup
    private func setupViewMessages() {
        registerCells()
        collectionView.transform = CGAffineTransform(a: 1.0, b: 0.0, c: 0.0, d: -1.0, tx: 0.0, ty: 0.0)
        setupInputToolbar()
    }
    
    private func registerCells() {
        if let headerNib = HeaderCollectionReusableView.nib(),
            let headerIdentifier = HeaderCollectionReusableView.cellReuseIdentifier() {
            collectionView.register(headerNib,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                    withReuseIdentifier: headerIdentifier)
        }
        ChatNotificationCell.registerForReuse(inView: collectionView)
        ChatOutgoingCell.registerForReuse(inView: collectionView)
        ChatIncomingCell.registerForReuse(inView: collectionView)
        ChatAttachmentIncomingCell.registerForReuse(inView: collectionView)
        ChatAttachmentOutgoingCell.registerForReuse(inView: collectionView)
    }
    
    private func setupInputToolbar() {
        inputToolbar.delegate = self
        inputToolbar.contentView.textView.delegate = self
        
        let accessoryImage = UIImage(named: "attachment_ic")
        let normalImage = accessoryImage?.imageMasked(color: .lightGray)
        let highlightedImage = accessoryImage?.imageMasked(color: .darkGray)
        let accessorySize = CGSize(width: accessoryImage?.size.width ?? 32.0, height: 32.0)
        let accessoryButton = UIButton(frame: CGRect(origin: .zero, size: accessorySize))
        accessoryButton.setImage(normalImage, for: .normal)
        accessoryButton.setImage(highlightedImage, for: .highlighted)
        accessoryButton.contentMode = .scaleAspectFit
        accessoryButton.backgroundColor = .clear
        accessoryButton.tintColor = .lightGray
        
        inputToolbar.contentView.leftBarButtonItem = accessoryButton
        
        let sendTitle = "Send"
        
        let titleMaxHeight:CGFloat = 32.0
        let titleMaxSize = CGSize(width: .greatestFiniteMagnitude, height: titleMaxHeight)
        let titleLabel = UILabel(frame: CGRect(origin: .zero, size: titleMaxSize))
        let font = UIFont.boldSystemFont(ofSize: 17.0)
        titleLabel.font = font
        titleLabel.text = sendTitle
        titleLabel.sizeToFit()
        let titleSize = CGSize(width: titleLabel.frame.width, height: titleMaxHeight)
        
        let sendButton = UIButton(frame: CGRect(origin: .zero, size: titleSize))
        sendButton.titleLabel?.font = font
        
        sendButton.setTitle(sendTitle, for: .normal)
        sendButton.setTitleColor(.blue, for: .normal)
        sendButton.setTitleColor(.darkGray, for: .highlighted)
        sendButton.setTitleColor(.lightGray, for: .disabled)
        
        sendButton.backgroundColor = .clear
        sendButton.tintColor = .blue
        
        inputToolbar.contentView.rightBarButtonItem = sendButton
        inputToolbar.contentView.textView.inputAccessoryView = systemInputToolbar
    }
    
    private func setupToolbarBottom(constraintValue: CGFloat, animated: Bool) {
        if constraintValue < 0.0 {
            return
        }
        if animated == false {
            let offsetY = collectionView.contentOffset.y + constraintValue - toolbarBottomLayoutGuide.constant
            collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x, y: offsetY)
        }
        toolbarBottomLayoutGuide.constant = constraintValue
        if animated {
            view.layoutIfNeeded()
        }
    }
    
    //MARK: - Actions
    private func cancelUploadFile() {
        hideAttacnmentBar()
        isUploading = false
        let alertController = UIAlertController(title: "SA_STR_ERROR".localized,
                                                message: "SA_STR_FAILED_UPLOAD_ATTACHMENT".localized,
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel) { (action) in
            self.inputToolbar.setupBarButtonsEnabled(left: true, right: false)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func viewClass(forItem item: QBChatMessage) -> ChatReusableViewProtocol.Type {
        
        if item.customParameters["notification_type"] != nil || item.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            return ChatNotificationCell.self
        }
        let hasAttachment = item.attachments?.isEmpty == false
        if item.senderID != senderID {
            return hasAttachment ? ChatAttachmentIncomingCell.self : ChatIncomingCell.self
        } else {
            return hasAttachment ? ChatAttachmentOutgoingCell.self : ChatOutgoingCell.self
        }
    }
    
    private func attributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        guard let text = messageItem.text  else {
            return nil
        }
        var textString = text
        var textColor = messageItem.senderID == senderID ? UIColor.white : .black
        if messageItem.customParameters["notification_type"] != nil || messageItem.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            textColor = .black
        }
        if messageItem.customParameters["notification_type"] != nil {
            if let dateSent = messageItem.dateSent {
                textString = messageTimeDateFormatter.string(from: dateSent) + "\n" + textString
            }
        }
        let font = UIFont(name: "Helvetica", size: 17)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any]
        return NSAttributedString(string: textString, attributes: attributes)
    }
    
    private func topLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        if dialog.type == .private,
            messageItem.senderID == senderID {
                return nil
        }
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byTruncatingTail
        let color = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        let font = UIFont(name: "Helvetica", size: 17)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        let topLabelString = chatManager.storage.user(withID: messageItem.senderID)?.fullName ?? "@\(messageItem.senderID)"
        return NSAttributedString(string: topLabelString, attributes: attributes)
    }
    
    private func bottomLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        let textColor = messageItem.senderID == senderID ? UIColor.white : .black
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byWordWrapping
        let font = UIFont(name: "Helvetica", size: 13)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        guard let dateSent = messageItem.dateSent else {
            return NSAttributedString(string: "")
        }
        var text = messageTimeDateFormatter.string(from: dateSent)
        if messageItem.senderID == self.senderID {
            text = text + "\n" + statusStringFromMessage(message: messageItem)
        }
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    /**
     Builds a string
     Read: login1, login2, login3
     Delivered: login1, login3, @12345
     
     If user does not exist in usersMemoryStorage, then ID will be used instead of login
     
     - parameter message: QBChatMessage instance
     
     - returns: status string
     */
    private func statusStringFromMessage(message: QBChatMessage) -> String {
        var statusString = ""
        var readLogins: [String] = []
        //check and add users who read the message
        if let readIDs = message.readIDs?.filter({ $0 != NSNumber(value: senderID) }),
            readIDs.isEmpty == false {
            for readID in readIDs {
                guard let user = chatManager.storage.user(withID: readID.uintValue) else {
                    let userLogin = "@\(readID)"
                    readLogins.append(userLogin)
                    continue
                }
                let userName = user.fullName ?? user.login ?? ""
                if readLogins.contains(userName) {
                    continue
                }
                readLogins.append(userName)
            }
            statusString += message.attachments?.isEmpty == false ? "SA_STR_SEEN_STATUS".localized : "SA_STR_READ_STATUS".localized;
            statusString += ": " + readLogins.joined(separator: ", ")
        }
        //check and add users to whom the message was delivered
        if let deliveredIDs = message.deliveredIDs?.filter({ $0 != NSNumber(value: senderID) }) {
            var deliveredLogins: [String] = []
            for deliveredID in deliveredIDs {
                guard let user = chatManager.storage.user(withID: deliveredID.uintValue) else {
                    let userLogin = "@\(deliveredID)"
                    if readLogins.contains(userLogin) == false {
                        deliveredLogins.append(userLogin)
                    }
                    continue
                }
                let userName = user.fullName ?? user.login ?? ""
                if readLogins.contains(userName) {
                    continue
                }
                if deliveredLogins.contains(userName) {
                    continue
                }
                
                deliveredLogins.append(userName)
            }
            if deliveredLogins.isEmpty == false {
                if statusString.isEmpty == false {
                    statusString += "\n"
                }
                statusString += "SA_STR_DELIVERED_STATUS".localized + ": " + deliveredLogins.joined(separator: ", ")
            }
        }
        return statusString.isEmpty ? "SA_STR_SENT_STATUS".localized : statusString
    }
    
    
    @objc private func didTapInfo(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_INFO".localized, sender: nil)
    }
    
    /**
     *  Animates the sending of a new message. See `finishSendingMessageAnimated:` for more details.
     *
     *  @see `finishSendingMessageAnimated:`.
     */
    private func finishSendingMessage() {
        finishSendingMessage(animated: true)
    }
    
    /**
     *  Completes the "receiving" of a new message by adding a new collection view cell in the collection view,
     *  reloading the collection view, and scrolling to the newly sent message as specified by `automaticallyScrollsToMostRecentMessage`.
     *  Scrolling to the new message can be animated as specified by the animated parameter.
     *
     *  @param animated Specifies whether the receiving of a message should be animated or not. Pass `true` to animate changes, `false` otherwise.
     *
     *  @discussion You should call this method after adding a new "received" message to your data source and performing any related tasks.
     *
     *  @see `automaticallyScrollsToMostRecentMessage`.
     */
    private func finishSendingMessage(animated: Bool) {
        let textView = inputToolbar.contentView.textView
        textView?.setupDefaultSettings()
        
        textView?.text = nil
        textView?.attributedText = nil
        textView?.undoManager?.removeAllActions()
        
        if attachmentMessage != nil {
            attachmentMessage = nil
        }
        
        if isUploading == true {
            inputToolbar.setupBarButtonsEnabled(left: false, right: false)
        } else {
            inputToolbar.setupBarButtonsEnabled(left: true, right: false)
        }
        
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: textView)
        
        if automaticallyScrollsToMostRecentMessage {
            scrollToBottomAnimated(animated)
        }
    }
    
    /**
     *  Scrolls the collection view such that the bottom most cell is completely visible, above the `inputToolbar`.
     *
     *  @param animated Pass `true` if you want to animate scrolling, `false` if it should be immediate.
     */
    private func scrollToBottomAnimated(_ animated: Bool) {
        if collectionView.numberOfItems(inSection: 0) == 0 {
            return
        }
        
        var contentOffset = collectionView.contentOffset
        
        if contentOffset.y == 0 {
            return
        }
        contentOffset.y = 0
        collectionView.setContentOffset(contentOffset, animated: animated)
    }
    
    /**
     *  Hides keyboard
     *
     *  @param animated Pass `true` if you want to animate hiding, `false` if it should be immediate.
     */
    private func hideKeyboard(animated: Bool) {
        let hideKeyboardBlock = { [weak self] in
            if self?.inputToolbar.contentView.textView.isFirstResponder == true {
                self?.inputToolbar.contentView.resignFirstResponder()
            }
        }
        if animated {
            hideKeyboardBlock()
        } else {
            UIView.performWithoutAnimation(hideKeyboardBlock)
        }
    }
    
    private func loadMessages(with skip: Int = 0) {
        SVProgressHUD.show()
        chatManager.messages(withID: dialogID, skip: skip, successCompletion: { [weak self] (messages, cancel) in
            self?.cancel = cancel
            self?.dataSource.addMessages(messages)
            SVProgressHUD.dismiss()
            }, errorHandler: { [weak self] (error) in
                if error == ChatManagerConstant.notFound {
                    self?.dataSource.clear()
                    self?.dialog.clearTypingStatusBlocks()
                    self?.inputToolbar.isUserInteractionEnabled = false
                    self?.collectionView.isScrollEnabled = false
                    self?.collectionView.reloadData()
                    self?.title = ""
                    self?.navigationItem.rightBarButtonItem?.isEnabled = false
                }
                SVProgressHUD.showError(withStatus: error)
        })
    }
    
    private func updateCollectionViewInsets() {
        if topContentAdditionalInset > 0.0 {
            var contentInset = collectionView.contentInset
            contentInset.top = topContentAdditionalInset
            collectionView.contentInset = contentInset
            collectionView.scrollIndicatorInsets = contentInset
        }
    }
    
    private func showPickerController(_ pickerController: UIImagePickerController,
                                      withSourceType sourceType: UIImagePickerController.SourceType) {
        pickerController.sourceType = sourceType
        
        let show: (UIImagePickerController) -> Void = { [weak self] (pickerController) in
            DispatchQueue.main.async {
                pickerController.sourceType = sourceType
                self?.present(pickerController, animated: true, completion: nil)
                self?.inputToolbar.setupBarButtonsEnabled(left: false, right: false)
            }
        }
        
        let accessDenied: (_ withSourceType: UIImagePickerController.SourceType) -> Void = { [weak self] (sourceType) in
            let typeName = sourceType == .camera ? "Camera" : "Photos"
            let title = "\(typeName) Access Disabled"
            let message = "You can allow access to \(typeName) in Settings"
            let alertController = UIAlertController(title: title,
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsURL) {
                    UIApplication.shared.open(settingsURL, options: [:])
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self?.present(alertController, animated: true, completion: nil)
            }
        }
        //Check Access
        if sourceType == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
                
            }
        } else {
            //Photo Library Access
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        show(pickerController)
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            }
        }
    }
    
    private func showAttachmentBar(with image: UIImage) {
        view.addSubview(attachmentBar)
        attachmentBar.delegate = self
        attachmentBar.translatesAutoresizingMaskIntoConstraints = false
        attachmentBar.leftAnchor.constraint(equalTo: inputToolbar.leftAnchor).isActive = true
        attachmentBar.rightAnchor.constraint(equalTo: inputToolbar.rightAnchor).isActive = true
        attachmentBar.bottomAnchor.constraint(equalTo: inputToolbar.topAnchor).isActive = true
        attachmentBar.heightAnchor.constraint(equalToConstant: ChatViewControllerConstant.attachmentBarHeight).isActive = true
        
        attachmentBar.uploadAttachmentImage(image, sourceType: pickerController.sourceType)
        attachmentBar.cancelButton.isHidden = true
        collectionBottomConstant = ChatViewControllerConstant.attachmentBarHeight
        isUploading = true
        inputToolbar.setupBarButtonsEnabled(left: false, right: false)
        
    }
    
    private func hideAttacnmentBar() {
        attachmentBar.removeFromSuperview()
        attachmentBar.imageView.image = nil
        collectionBottomConstant = 0.0
        collectionBottomConstraint.constant = collectionBottomConstant
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func createAttachmentMessage(with attachment: QBChatAttachment) -> QBChatMessage {
        let message = QBChatMessage.markable()
        message.text = "[Attachment]"
        message.senderID = senderID
        message.dialogID = dialogID
        message.deliveredIDs = [(NSNumber(value: senderID))]
        message.readIDs = [(NSNumber(value: senderID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        message.attachments = [attachment]
        return message
    }
    
    private func didPressSend(_ button: UIButton) {
        
        if let attacmentMessage = attachmentMessage, isUploading == false {
            send(withAttachmentMessage: attacmentMessage)
        }
        if let messageText = currentlyComposedMessageText(), messageText.isEmpty == false {
            send(withMessageText: messageText)
        }
    }
    
    private func send(withAttachmentMessage attachmentMessage: QBChatMessage) {
        hideAttacnmentBar()
        sendMessage(message: attachmentMessage)
    }
    
    private func send(withMessageText text: String) {
        let message = QBChatMessage.markable()
        message.text = text
        message.senderID = senderID
        message.dialogID = dialogID
        message.deliveredIDs = [(NSNumber(value: senderID))]
        message.readIDs = [(NSNumber(value: senderID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        sendMessage(message: message)
    }
    
    private func sendMessage(message: QBChatMessage) {
        chatManager.send(message, to: dialog) { [weak self] (error) in
            if let error = error {
                debugPrint("[ChatViewController] sendMessage error: \(error.localizedDescription)")
                return
            }
            self?.dataSource.addMessage(message)
            self?.finishSendingMessage(animated: true)
        }
    }
    
    private func currentlyComposedMessageText() -> String? {
        //  auto-accept any auto-correct suggestions
        if let inputDelegate = inputToolbar.contentView.textView.inputDelegate {
            inputDelegate.selectionWillChange(inputToolbar.contentView.textView)
            inputDelegate.selectionDidChange(inputToolbar.contentView.textView)
        }
        return inputToolbar.contentView.textView.text.stringByTrimingWhitespace()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_INFO".localized {
            if let chatInfoViewController = segue.destination as? UsersInfoTableViewController {
                chatInfoViewController.dialogID = dialogID
            }
        }
    }
    
    //MARK: - Notifications
    private func registerForNotifications(_ registerForNotifications: Bool) {
        let defaultCenter = NotificationCenter.default
        if registerForNotifications {
            defaultCenter.addObserver(self,
                                      selector: #selector(didReceiveMenuWillShow(notification:)),
                                      name: UIMenuController.willShowMenuNotification,
                                      object: nil)
            
            defaultCenter.addObserver(self,
                                      selector: #selector(didReceiveMenuWillHide(notification:)),
                                      name: UIMenuController.willHideMenuNotification,
                                      object: nil)
        } else {
            defaultCenter.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
            defaultCenter.removeObserver(self, name: UIMenuController.willHideMenuNotification, object: nil)
        }
    }
    
    @objc private func didReceiveMenuWillShow(notification: Notification) {
        guard let selectedIndexPath = selectedIndexPathForMenu,
            let menu = notification.object as? UIMenuController,
            let selectedCell = collectionView.cellForItem(at: selectedIndexPath) else {
                return
        }
        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self, name: UIMenuController.willShowMenuNotification, object: nil)
        
        menu.setMenuVisible(false, animated: false)
        
        let selectedMessageBubbleFrame = selectedCell.convert(selectedCell.contentView.frame, to: view)
        
        menu.setTargetRect(selectedMessageBubbleFrame, in: view)
        menu.setMenuVisible(true, animated: true)
        
        defaultCenter.addObserver(self,
                                  selector: #selector(didReceiveMenuWillShow(notification:)),
                                  name: UIMenuController.willShowMenuNotification,
                                  object: nil)
    }
    
    @objc private func didReceiveMenuWillHide(notification: Notification) {
        if selectedIndexPathForMenu == nil {
            return
        }
        
        selectedIndexPathForMenu = nil
    }
    
    //MARK - Orientation
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil,
                            completion: { [weak self] (context) in
                                self?.updateCollectionViewInsets()
        })
        
        if inputToolbar.contentView.textView.isFirstResponder,
            let splitViewController = splitViewController,
            splitViewController.isCollapsed == false {
            inputToolbar.contentView.textView.resignFirstResponder()
        }
    }
}

//MARK: - UIScrollViewDelegate
extension ChatViewController: UIScrollViewDelegate {
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        // disabling scroll to bottom when tapping status bar
        return false
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        guard let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage else {
            return
        }
        inputToolbar.setupBarButtonsEnabled(left: false, right: false)
        showAttachmentBar(with: image)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Helper function.
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})}
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        inputToolbar.setupBarButtonsEnabled(left: true, right: false)
    }
}

//MARK: - ChatDataSourceDelegate
extension ChatViewController: ChatDataSourceDelegate {
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        willChangeWithMessageIDs IDs: [String]) {
        IDs.forEach{ collectionView.chatCollectionViewLayout?.removeSizeFromCache(forItemID: $0) }
    }
    
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        changeWithMessages messages: [QBChatMessage],
                        action: ChatDataSourceAction) {
        if messages.isEmpty {
            return
        }
        
        collectionView.performBatchUpdates({ [weak self] in
            guard let self = self else {
                return
            }
            
            let indexPaths = chatDataSource.performChangesFor(messages: messages, action: action)
            
            if indexPaths.isEmpty {
                return
            }
            
            switch action {
            case .add: self.collectionView.insertItems(at: indexPaths)
            case .update: self.collectionView.reloadItems(at: indexPaths)
            case .remove: self.collectionView.deleteItems(at: indexPaths)
            }
            
            }, completion: nil)
    }
}

//MARK: - InputToolbarDelegate
extension ChatViewController: InputToolbarDelegate {
    func messagesInputToolbar(_ toolbar: InputToolbar, didPressRightBarButton sender: UIButton) {
        if toolbar.sendButtonOnRight {
            didPressSend(sender)
        } else {
            didPressAccessoryButton(sender)
        }
    }
    
    func messagesInputToolbar(_ toolbar: InputToolbar, didPressLeftBarButton sender: UIButton) {
        if toolbar.sendButtonOnRight {
            didPressAccessoryButton(sender)
        } else {
            didPressSend(sender)
        }
    }
    
    func didPressAccessoryButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.showPickerController(self.pickerController, withSourceType: .camera)
        }))
        
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.showPickerController(self.pickerController, withSourceType: .photoLibrary)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alertController.popoverPresentationController {
            // iPad support
            popoverPresentationController.sourceView = sender
            popoverPresentationController.sourceRect = sender.bounds
        }
        present(alertController, animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDelegate
extension ChatViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        selectedIndexPathForMenu = indexPath
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        canPerformAction action: Selector,
                        forItemAt indexPath: IndexPath,
                        withSender sender: Any?) -> Bool {
        if action != #selector(copy(_:)) {
            return false
        }
        guard let item = dataSource.messageWithIndexPath(indexPath) else {
            return false
        }
        if  self.viewClass(forItem: item) === ChatNotificationCell.self {
            return false
        }
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return
        }
        if message.attachments?.isEmpty == false {
            return
        }
        UIPasteboard.general.string = message.text
    }
}

//MARK: - ChatCollectionViewDataSource
extension ChatViewController: ChatCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing:ChatIncomingCell.self),
                                                      for: indexPath)
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return cell
        }
        
        let cellClass = viewClass(forItem: message)
        
        guard let identifier = cellClass.cellReuseIdentifier() else {
            return cell
        }
        
        let chatCell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier,
                                                          for: indexPath)
        
        if let chatCollectionView = collectionView as? ChatCollectionView {
            self.collectionView(chatCollectionView, configureCell: chatCell, for: indexPath)
        }
        
        let lastSection = collectionView.numberOfSections - 1
        let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        
        if indexPath.section == lastSection,
            indexPath.item == lastItem,
            cancel == false  {
            loadMessages(with: dataSource.loadMessagesCount)
        }
        
        return chatCell
    }
    
    func collectionView(_ collectionView: ChatCollectionView, itemIdAt indexPath: IndexPath) -> String {
        guard let message = dataSource.messageWithIndexPath(indexPath), let ID = message.id else {
            return "0"
        }
        return ID
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // marking message as read if needed
        if isDeviceLocked == true {
            return
        }
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return
        }
        if message.readIDs?.contains(NSNumber(value: senderID)) == false {
            chatManager.read([message], dialog: dialog, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let item = dataSource.messageWithIndexPath(indexPath),
            let attachment = item.attachments?.first,
            let attachmentID = attachment.id else {
                return
        }
        let attachmentDownloadManager = AttachmentDownloadManager()
        attachmentDownloadManager.slowDownloadAttachment(attachmentID)
    }
    
    private func collectionView(_ collectionView: ChatCollectionView,
                                configureCell cell: UICollectionViewCell,
                                for indexPath: IndexPath) {
        
        guard let item = dataSource.messageWithIndexPath(indexPath) else {
            return
        }
        
        if let notificationCell = cell as? ChatNotificationCell {
            notificationCell.isUserInteractionEnabled = false
            notificationCell.notificationLabel.attributedText = attributedString(forItem: item)
            return
        }
        
        guard let chatCell = cell as? ChatCell else {
            return
        }
        
        if cell is ChatIncomingCell
            || cell is ChatOutgoingCell {
            chatCell.textView.enabledTextCheckingTypes = enableTextCheckingTypes
        }
        
        chatCell.topLabel.text = topLabelAttributedString(forItem: item)
        chatCell.bottomLabel.text = bottomLabelAttributedString(forItem: item)
        if let textView = chatCell.textView {
            textView.text = attributedString(forItem: item)
        }
        
        chatCell.delegate = self
        
        if let attachmentCell = cell as? ChatAttachmentCell {
            
            guard let attachment = item.attachments?.first,
                let attachmentID = attachment.id,
                attachment.type == "image" else {
                    return
            }
            //setup image to attachmentCell
            attachmentCell.setupAttachmentWithID(attachmentID)
            
            if attachmentCell is ChatAttachmentIncomingCell {
                chatCell.containerView.bubbleImageView.image = grayBubble
            }
            else if attachmentCell is ChatAttachmentOutgoingCell {
                chatCell.containerView.bubbleImageView.image = blueBubble
            }
            
        }
        else if chatCell is ChatIncomingCell {
            chatCell.containerView.bubbleImageView.image = grayBubble
        }
        else if chatCell is ChatOutgoingCell {
            chatCell.containerView.bubbleImageView.image = blueBubble
        }
    }
}


//MARK: - ChatCollectionViewDelegateFlowLayout
extension ChatViewController: ChatCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let chatLayout = collectionViewLayout as? ChatCollectionViewFlowLayout else {
            return .zero
        }
        return chatLayout.sizeForItem(at: indexPath)
    }
    
    func collectionView(_ collectionView: ChatCollectionView, layoutModelAt indexPath: IndexPath) -> ChatCellLayoutModel {
        guard let item = dataSource.messageWithIndexPath(indexPath),
            let _ = item.id,
            let cellClass = viewClass(forItem: item) as? ChatCellProtocol.Type else {
                return ChatCell.layoutModel()
        }
        var layoutModel = cellClass.layoutModel()
        
        layoutModel.avatarSize = .zero
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5.0
        layoutModel.maxWidthMarginSpace = 20.0
        
        if cellClass == ChatIncomingCell.self || cellClass == ChatAttachmentIncomingCell.self {
            
            if dialog.type != .private {
                let topAttributedString = topLabelAttributedString(forItem: item)
                let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString,
                                                                           withConstraints: CGSize(width: collectionView.frame.width - ChatViewControllerConstant.messagePadding,
                                                                                                   height: CGFloat.greatestFiniteMagnitude),
                                                                           limitedToNumberOfLines:1)
                layoutModel.topLabelHeight = size.height
                layoutModel.avatarSize = CGSize(width: 35.0, height: 36.0)
            }
            layoutModel.spaceBetweenTopLabelAndTextView = 5
        }
        
        let bottomAttributedString = bottomLabelAttributedString(forItem: item)
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: collectionView.frame.width - ChatViewControllerConstant.messagePadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
        layoutModel.bottomLabelHeight = floor(size.height)
        
        return layoutModel
    }
    
    func collectionView(_ collectionView: ChatCollectionView,
                        minWidthAt indexPath: IndexPath) -> CGFloat {
        guard let item = dataSource.messageWithIndexPath(indexPath),
            let _ = item.id else {
                return 0.0
        }
        
        let frameWidth = collectionView.frame.width
        let constraintsSize = CGSize(width:frameWidth - ChatViewControllerConstant.messagePadding,
                                     height: .greatestFiniteMagnitude)
        
        let attributedString = bottomLabelAttributedString(forItem: item)
        var size = TTTAttributedLabel.sizeThatFitsAttributedString(
            attributedString,
            withConstraints: constraintsSize,
            limitedToNumberOfLines:0)
        
        if dialog.type != .private {
            let attributedString = topLabelAttributedString(forItem: item)
            
            let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(
                attributedString,
                withConstraints: constraintsSize,
                limitedToNumberOfLines:0)
            
            if topLabelSize.width > size.width {
                size = topLabelSize
            }
        }
        return size.width
    }
    
    func collectionView(_ collectionView: ChatCollectionView, dynamicSizeAt indexPath: IndexPath, maxWidth: CGFloat) -> CGSize {
        var size: CGSize = .zero
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return size
        }
        let messageCellClass = viewClass(forItem: message)
        if messageCellClass === ChatAttachmentIncomingCell.self {
            size = CGSize(width: min(200, maxWidth), height: 200)
        } else if messageCellClass === ChatAttachmentOutgoingCell.self {
            let attributedString = bottomLabelAttributedString(forItem: message)
            let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString,
                                                                                  withConstraints: CGSize(width: min(200, maxWidth),
                                                                                                          height: CGFloat.greatestFiniteMagnitude),
                                                                                  limitedToNumberOfLines: 0)
            size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
        } else if messageCellClass === ChatNotificationCell.self {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString,
                                                                   withConstraints: CGSize(width: maxWidth,
                                                                                           height: CGFloat.greatestFiniteMagnitude),
                                                                   limitedToNumberOfLines: 0)
        } else {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString,
                                                                   withConstraints: CGSize(width: maxWidth,
                                                                                           height: CGFloat.greatestFiniteMagnitude),
                                                                   limitedToNumberOfLines: 0)
        }
        return size
    }
}

//MARK: - UITextViewDelegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView {
            return
        }
        if automaticallyScrollsToMostRecentMessage == true {
            collectionBottomConstraint.constant = collectionBottomConstant
            scrollToBottomAnimated(true)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView {
            return
        }
        if isUploading == true || attachmentMessage != nil {
            inputToolbar.setupBarButtonsEnabled(left: false, right: true)
        } else {
            inputToolbar.setupBarButtonsEnabled(left: true, right: true)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView {
            return
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length + range.location > textView.text.count {
            return false
        }
        return true
    }
}

//MARK: - ChatCellDelegate
extension ChatViewController: ChatCellDelegate {
    
    private func handleNotSentMessage(_ message: QBChatMessage,
                                      forCell cell: ChatCell) {
        
        let alertController = UIAlertController(title: "", message: "SA_STR_MESSAGE_FAILED_TO_SEND".localized, preferredStyle:.actionSheet)
        
        let resend = UIAlertAction(title: "SA_STR_TRY_AGAIN_MESSAGE".localized, style: .default) { (action) in
        }
        alertController.addAction(resend)
        
        let delete = UIAlertAction(title: "SA_STR_DELETE_MESSAGE".localized, style: .destructive) { (action) in
            
            self.dataSource.deleteMessage(message)
        }
        alertController.addAction(delete)
        
        let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel) { (action) in
        }
        
        alertController.addAction(cancelAction)
        
        if alertController.popoverPresentationController != nil {
            view.endEditing(true)
            alertController.popoverPresentationController!.sourceView = cell.containerView
            alertController.popoverPresentationController!.sourceRect = cell.containerView.bounds
        }
        
        self.present(alertController, animated: true) {
        }
    }
    
    func chatCellDidTapAvatar(_ cell: ChatCell) {
    }
    
    private func openZoomVC(image: UIImage) {
        let zoomedVC = ZoomedAttachmentViewController()
        zoomedVC.zoomImageView.image = image
        zoomedVC.modalPresentationStyle = .overCurrentContext
        zoomedVC.modalTransitionStyle = .crossDissolve
        present(zoomedVC, animated: true, completion: nil)
    }
    
    func chatCellDidTapContainer(_ cell: ChatCell) {
        if let attachmentCell = cell as? ChatAttachmentCell, let attachmentImage = attachmentCell.attachmentImageView.image {
            self.openZoomVC(image: attachmentImage)
        }
    }
    func chatCell(_ cell: ChatCell, didTapAtPosition position: CGPoint) {}
    func chatCell(_ cell: ChatCell, didPerformAction action: Selector, withSender sender: Any) {}
    func chatCell(_ cell: ChatCell, didTapOn result: NSTextCheckingResult) {
        
        switch result.resultType {
        case NSTextCheckingResult.CheckingType.link:
            guard let strUrl = result.url?.absoluteString else {
                return
            }
            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")
            if hasPrefix == true {
                guard let url = URL(string: strUrl) else {
                    return
                }
                let controller = SFSafariViewController(url: url)
                present(controller, animated: true, completion: nil)
            }
        case NSTextCheckingResult.CheckingType.phoneNumber:
            if canMakeACall() == false {
                SVProgressHUD.showInfo(withStatus: "Your Device can't make a phone call".localized, maskType: .none)
                break
            }
            view.endEditing(true)
            let alertController = UIAlertController(title: "",
                                                    message: result.phoneNumber,
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "SA_STR_CALL".localized, style: .destructive) { (action) in
                if let phoneNumber = result.phoneNumber,
                    let url = URL(string: "tel:" + phoneNumber) {
                    UIApplication.shared.open(url, options: [:])
                }
            }
            alertController.addAction(openAction)
            present(alertController, animated: true) {
            }
        default:
            break
        }
    }
    
    private func canMakeACall() -> Bool {
        var canMakeACall = false
        if let url = URL.init(string: "tel://"), UIApplication.shared.canOpenURL(url) == true {
            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            guard let carrier = networkInfo.subscriberCellularProvider else {
                return false
            }
            let mobileNetworkCode = carrier.mobileNetworkCode
            if mobileNetworkCode?.isEmpty == true {
                // Device cannot place a call at this time.  SIM might be removed.
            } else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        } else {
            // iOS Device is not capable for making calls
        }
        return canMakeACall
    }
}

//MARK: - QBChatDelegate
extension ChatViewController: QBChatDelegate {
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        if senderID == readerID || dialogID != self.dialogID {
            return
        }
        guard let message = dataSource.messageWithID(messageID) else {
            return
        }
        message.readIDs?.append(NSNumber(value: readerID))
        dataSource.updateMessage(message)
    }
    
    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        if senderID == userID || dialogID != self.dialogID {
            return
        }
        guard let message = dataSource.messageWithID(messageID) else {
            return
        }
        message.deliveredIDs?.append(NSNumber(value: userID))
        dataSource.updateMessage(message)
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        if message.dialogID == self.dialogID {
            dataSource.addMessage(message)
        }
    }
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        if dialogID == self.dialogID {
            dataSource.addMessage(message)
        }
    }
    
    func chatDidConnect() {
        refreshAndReadMessages()
    }
    
    func chatDidReconnect() {
        refreshAndReadMessages()
    }
    
    //MARK - Help
    private func refreshAndReadMessages() {
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_MESSAGES".localized, maskType: .clear)
        loadMessages()
    }
}

//MARK: - AttachmentBarDelegate
extension ChatViewController: AttachmentBarDelegate {
    func attachmentBarFailedUpLoadImage(_ attachmentBar: AttachmentBar) {
        cancelUploadFile()
    }
    
    func attachmentBar(_ attachmentBar: AttachmentBar, didUpLoadAttachment attachment: QBChatAttachment) {
        attachmentMessage = createAttachmentMessage(with: attachment)
        isUploading = false
        inputToolbar.setupBarButtonsEnabled(left: false, right: true)
    }
    
    func attachmentBar(_ attachmentBar: AttachmentBar, didTapCancelButton: UIButton) {
        attachmentMessage = nil
        inputToolbar.setupBarButtonsEnabled(left: true, right: false)
        hideAttacnmentBar()
    }
}
