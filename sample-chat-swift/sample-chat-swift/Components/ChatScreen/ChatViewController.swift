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
import AVKit
import SDWebImage
import PDFKit

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

enum ChatAction: String {
    case Delete
    case Forward
    case ChatInfo
    case ViewedBy
    case DeliveredTo
}

struct ChatViewControllerConstant {
    static let leaveChat = "Leave_Chat"
    static let groupInfo = "Group_Info"
    static let forwardedFrom = "Forwarded from "
    static let messagePadding: CGFloat = 40.0
    static let attachmentBarHeight: CGFloat = 100.0
    static let maxNumberСharacters: Int = 1000
}

class ChatViewController: UIViewController, ChatContextMenu {
    
    //MARK: - IBOutlets
    @IBOutlet weak var collectionView: ChatCollectionView!
    /**
     *  Returns the input toolbar view object managed by this view controller.
     *  This view controller is the toolbar's delegate.
     */
    @IBOutlet weak var inputToolbar: InputToolbar!
    
    
    //MARK: - Private IBOutlets
    @IBOutlet private weak var collectionBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var toolbarBottomLayoutGuide: NSLayoutConstraint!
    
    private lazy var infoItem = UIBarButtonItem(image: UIImage(named: "moreInfo"),
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
    internal var currentUserID: UInt = 0
    
    private var onlineUsersIDs: Set<UInt> = []
    private var typingUsers: Set<UInt> = []
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
    private var topContentAdditionalInset: CGFloat = 28.0 {
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
    
    private var actionsMenuVC: ActionsMenuViewController?
    
    private lazy var attachmentBar: AttachmentUploadBar = {
        let attachmentBar = AttachmentUploadBar.loadNib()
        return attachmentBar
    }()
    
    private lazy var chatPrivateTitleView: ChatPrivateTitleView = {
        let chatPrivateTitleView = ChatPrivateTitleView()
        return chatPrivateTitleView
    }()
    
    private lazy var typingView: TypingView = {
        let typingView = TypingView()
        typingView.backgroundColor = #colorLiteral(red: 0.9565117955, green: 0.9645770192, blue: 0.9769250751, alpha: 1)
        return typingView
    }()
    private var privateUserIsTypingTimer: Timer?
    private var stopTimer: Timer?
    private var isOpponentTyping = false
    private var isOpenPopVC = false
    
    private var attachmentDownloadManager = AttachmentDownloadManager()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        QBChat.instance.addDelegate(self)
        setupViewMessages()
        dataSource.delegate = self
        inputToolbar.inputToolbarDelegate = self
        inputToolbar.toggleSendButtonEnabled(isUploaded: isUploading)
        
        edgesForExtendedLayout = [] //same UIRectEdgeNone
        
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "chevron"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(didTapBack(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
        backButtonItem.tintColor = .white
        infoItem.tintColor = .white
        
        let currentUser = Profile()
        guard currentUser.isFull == true else {
            return
        }
        
        currentUserID = currentUser.ID
        
        setupTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        QBChat.instance.addDelegate(self)
        
        selectedIndexPathForMenu = nil
        
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
            guard let self = self else {
                return
            }
            let notConnection = status == .notConnection
            if notConnection == true, self.isUploading == true {
                self.cancelUploadFile()
            } else if notConnection == true {
                self.showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            } else {
                if QBChat.instance.isConnected == false {
                    self.chatManager.connect()
                }
                // Autojoin to the group chat
                if self.dialog.type != .private, self.dialog.isJoined() == false {
                    self.dialog.join(completionBlock: { error in
                        guard let error = error else {
                            return
                        }
                        debugPrint("[ChatViewController] dialog.join error: \(error.localizedDescription)")
                    })
                }
                self.loadMessages()
            }
        }
        Reachability.instance.networkStatusBlock = { status in
            updateConnectionStatus?(status)
        }
        updateConnectionStatus?(Reachability.instance.networkConnectionStatus())
        
        //request Online Users for group and public chats
        dialog.requestOnlineUsers { (onlineUsersIDs, error) in
            if let onlineUsersIDs = onlineUsersIDs as? [NSNumber] {
                for userID in onlineUsersIDs {
                    if userID.uintValue != self.currentUserID  {
                        self.onlineUsersIDs.insert(userID.uintValue)
                    }
                }
            } else if let error = error {
                debugPrint("[ChatViewController] requestOnlineUsers error \(error.localizedDescription)")
            }
        }
        
        // online/offline for group and public chats
        dialog.onJoinOccupant = { [weak self] userID in
            guard let self = self else {
                return
            }
            if userID == self.currentUserID  {
                return
            }
            self.onlineUsersIDs.insert(userID)
        }
        
        dialog.onLeaveOccupant = { [weak self] userID in
            guard let self = self else {
                return
            }
            if userID == self.currentUserID  {
                return
            }
            self.onlineUsersIDs.remove(userID)
            self.typingUsers.remove(userID)
            if self.typingUsers.isEmpty == true {
                self.hideTypingView()
                self.isOpponentTyping = false
            } else {
                self.typingView.setupTypingView(self.typingUsers)
            }
        }
        
        // typingStatus
        if dialog.type == .private {
            
            // handling typing status
            dialog.onUserIsTyping = { [weak self] userID in
                guard let self = self else {
                    return
                }
                if userID == self.currentUserID  {
                    return
                }
                self.typingUsers.insert(userID)
                self.typingView.setupTypingView(self.typingUsers)
                self.showTypingView()
                self.isOpponentTyping = true
                
                if self.privateUserIsTypingTimer != nil {
                    self.privateUserIsTypingTimer?.invalidate()
                    self.privateUserIsTypingTimer = nil
                }
                
                self.privateUserIsTypingTimer = Timer.scheduledTimer(timeInterval: 10.0,
                                                                     target: self,
                                                                     selector: #selector(self.hideTypingView),
                                                                     userInfo: nil,
                                                                     repeats: false)
            }
            
            // Handling user stopped typing.
            dialog.onUserStoppedTyping = { [weak self] userID in
                if userID == self?.currentUserID  {
                    return
                }
                self?.typingUsers.remove(userID)
                self?.hideTypingView()
                self?.isOpponentTyping = false
            }
            
        } else {
            // handling typing status
            dialog.onUserIsTyping = { [weak self] userID in
                if userID == self?.currentUserID  {
                    return
                }
                
                self?.typingUsers.insert(userID)
                self?.typingView.setupTypingView(self?.typingUsers)
                self?.showTypingView()
                self?.isOpponentTyping = true
            }
            
            // Handling user stopped typing.
            dialog.onUserStoppedTyping = { [weak self] userID in
                if userID == self?.currentUserID  {
                    return
                }
                
                self?.typingUsers.remove(userID)
                if self?.typingUsers.isEmpty == true {
                    self?.hideTypingView()
                    self?.isOpponentTyping = false
                } else {
                    self?.typingView.setupTypingView(self?.typingUsers)
                }
            }
        }
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
        
        QBChat.instance.removeDelegate(self)
    }
    
    //MARK: - Internal Methods
    @objc func didTapBack(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    private func loadMessages(with skip: Int = 0) {
        SVProgressHUD.show()
        chatManager.messages(withID: dialogID, skip: skip, limit: ChatManagerConstant.messagesLimitPerDialog, successCompletion: { [weak self] (messages, cancel) in
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
            SVProgressHUD.dismiss()
        })
    }
    
    //MARK: - Setup
    fileprivate func setupTitleView() {
        if dialog.type == .private {
            if let userID = dialog.occupantIDs?.filter({$0.uintValue != self.currentUserID}).first as? UInt {
                if let opponentUser = chatManager.storage.user(withID: userID) {
                    chatPrivateTitleView.setupPrivateChatTitleView(opponentUser)
                    navigationItem.titleView = chatPrivateTitleView
                    
                } else {
                    ChatManager.instance.loadUser(userID) { [weak self] (opponentUser) in
                        if let opponentUser = opponentUser {
                            self?.chatPrivateTitleView.setupPrivateChatTitleView(opponentUser)
                            self?.navigationItem.titleView = self?.chatPrivateTitleView
                        }
                    }
                }
            }
            
        } else {
            title = dialog.name
        }
    }
    
    
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
        ChatDateCell.registerForReuse(inView: collectionView)
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
        let normalImage = accessoryImage?.imageMasked(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1))
        let highlightedImage = accessoryImage?.imageMasked(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1))
        let accessorySize = CGSize(width: accessoryImage?.size.width ?? 32.0, height: 32.0)
        let accessoryButton = UIButton(frame: CGRect(origin: .zero, size: accessorySize))
        accessoryButton.setImage(normalImage, for: .normal)
        accessoryButton.setImage(highlightedImage, for: .highlighted)
        accessoryButton.contentMode = .scaleAspectFit
        accessoryButton.backgroundColor = .clear
        accessoryButton.tintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
        
        inputToolbar.contentView.leftBarButtonItem = accessoryButton
        
        let accessorySendImage = UIImage(named: "send")
        let normalSendImage = accessorySendImage?.imageMasked(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1))
        let highlightedSendImage = accessorySendImage?.imageMasked(color: #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1))
        let accessorySendSize = CGSize(width: accessoryImage?.size.width ?? 32.0, height: 28.0)
        let accessorySendButton = UIButton(frame: CGRect(origin: .zero, size: accessorySendSize))
        accessorySendButton.setImage(normalSendImage, for: .normal)
        accessorySendButton.setImage(highlightedSendImage, for: .highlighted)
        accessorySendButton.contentMode = .scaleAspectFit
        accessorySendButton.backgroundColor = .clear
        accessorySendButton.tintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
        
        inputToolbar.contentView.rightBarButtonItem = accessorySendButton
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
            self.inputToolbar.toggleSendButtonEnabled(isUploaded: self.isUploading)
        }
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func viewClass(forItem item: QBChatMessage) -> ChatReusableViewProtocol.Type {
        
        if item.customParameters["notification_type"] != nil {
            return ChatNotificationCell.self
        }
        if item.customParameters[ChatDataSourceConstant.dateDividerKey] as? Bool == true {
            return ChatDateCell.self
        }
        let hasAttachment = item.attachments?.isEmpty == false
        if item.senderID != currentUserID {
            return hasAttachment ? ChatAttachmentIncomingCell.self : ChatIncomingCell.self
        } else {
            return hasAttachment ? ChatAttachmentOutgoingCell.self : ChatOutgoingCell.self
        }
    }
    
    private func attributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        guard let text = messageItem.text  else {
            return NSAttributedString(string: "@")
        }
        let textColor = messageItem.senderID == currentUserID ? UIColor.white : .black
        
        let font = UIFont(name: "Helvetica", size: 15)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any]
        if let originForwardedName = messageItem.customParameters[ChatDataSourceConstant.forwardedMessage] as? String {
            let forwardedColor = messageItem.senderID == currentUserID ? UIColor.white.withAlphaComponent(0.6) : #colorLiteral(red: 0.4091697037, green: 0.4803909063, blue: 0.5925986171, alpha: 1)
            let fontForwarded = UIFont.systemFont(ofSize: 13, weight: .light)
            let fontForwardedName = UIFont.systemFont(ofSize: 13, weight: .semibold)
            let attributesForwarded: [NSAttributedString.Key: Any] = [.foregroundColor: forwardedColor,
                                                                      .font: fontForwarded as Any]
            let attributesForwardedName: [NSAttributedString.Key: Any] = [.foregroundColor: forwardedColor,
                                                                          .font: fontForwardedName as Any]
            let textForwarded = NSMutableAttributedString(string: ChatViewControllerConstant.forwardedFrom, attributes: attributesForwarded)
            let forwardedName = NSAttributedString(string: originForwardedName + "\n", attributes: attributesForwardedName)
            textForwarded.append(forwardedName)
            textForwarded.append(NSAttributedString(string: text, attributes: attributes))
            return textForwarded
        }
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    private func forwardedAttachmentAttributedString(forOriginName originForwardedName: String) -> NSAttributedString? {
        let forwardedColor =  #colorLiteral(red: 0.4091697037, green: 0.4803909063, blue: 0.5925986171, alpha: 1)
        let fontForwarded = UIFont.systemFont(ofSize: 13, weight: .light)
        let fontForwardedName = UIFont.systemFont(ofSize: 13, weight: .semibold)
        let attributesForwarded: [NSAttributedString.Key: Any] = [.foregroundColor: forwardedColor,
                                                                  .font: fontForwarded as Any]
        let attributesForwardedName: [NSAttributedString.Key: Any] = [.foregroundColor: forwardedColor,
                                                                      .font: fontForwardedName as Any]
        let textForwarded = NSMutableAttributedString(string: ChatViewControllerConstant.forwardedFrom, attributes: attributesForwarded)
        let forwardedName = NSAttributedString(string: originForwardedName + "\n", attributes: attributesForwardedName)
        textForwarded.append(forwardedName)
        return textForwarded
    }
    
    private func topLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString? {
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byClipping
        let color = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)
        let font = UIFont.systemFont(ofSize: 13.0, weight: .semibold)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: color,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        var topLabelString = ""
        if messageItem.senderID == currentUserID {
            topLabelString = "You"
        } else {
            if let fullName = chatManager.storage.user(withID: messageItem.senderID)?.fullName {
                topLabelString = fullName
            } else {
                return nil
            }
        }
        
        return NSAttributedString(string: topLabelString, attributes: attributes)
    }
    
    private func timeLabelAttributedString(forItem messageItem: QBChatMessage) -> NSAttributedString {
        let textColor = #colorLiteral(red: 0.4255777597, green: 0.476770997, blue: 0.5723374486, alpha: 1)
        let paragrpahStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = .byWordWrapping
        let font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: textColor,
                                                         .font: font as Any,
                                                         .paragraphStyle: paragrpahStyle]
        guard let dateSent = messageItem.dateSent else {
            return NSAttributedString(string: "")
        }
        let text = messageTimeDateFormatter.string(from: dateSent)
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    private func statusImageForMessage(message: QBChatMessage) -> UIImage {
        //check and add users who read the message
        if let readIDs = message.readIDs?.filter({ $0 != NSNumber(value: currentUserID) }),
           readIDs.isEmpty == false {
            return #imageLiteral(resourceName: "delivered").withTintColor(#colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1))
        }
        //check and add users to whom the message was delivered
        if let deliveredIDs = message.deliveredIDs?.filter({ $0 != NSNumber(value: currentUserID) }),
           deliveredIDs.isEmpty == false  {
            return #imageLiteral(resourceName: "delivered")
        }
        return UIImage(named: "sent")!
    }
    
    @objc private func didTapInfo(_ sender: UIBarButtonItem) {
        guard let actionsMenuVC = storyboard?.instantiateViewController(withIdentifier: "ActionsMenuViewController") as? ActionsMenuViewController else {
            return
        }
        actionsMenuVC.modalPresentationStyle = .popover
        let presentation = actionsMenuVC.popoverPresentationController
        presentation?.delegate = self
        presentation?.barButtonItem = infoItem
        presentation?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        let leaveChatAction = MenuAction(title: "Leave Chat") { [weak self] in
            self?.didTapDelete()
        }
        let chatInfoAction = MenuAction(title: "Chat info") { [weak self]  in
            self?.performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_INFO".localized, sender: ChatAction.ChatInfo)
        }
        
        if dialog.type == .private {
            actionsMenuVC.addAction(leaveChatAction)
        } else {
            actionsMenuVC.addAction(leaveChatAction)
            actionsMenuVC.addAction(chatInfoAction)
        }
        
        actionsMenuVC.cancelAction = {
            self.hideKeyboard(animated: false)
        }
        
        present(actionsMenuVC, animated: false)
    }
    
    //MARK - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SA_STR_SEGUE_GO_TO_INFO".localized {
            if let chatInfoViewController = segue.destination as? UsersInfoTableViewController {
                chatInfoViewController.dialogID = dialogID
                if let selectedIndexPathForMenu = selectedIndexPathForMenu,
                   let message = dataSource.messageWithIndexPath(selectedIndexPathForMenu) {
                    chatInfoViewController.message = message
                    if (sender as? ChatAction) != nil {
                        chatInfoViewController.dataSource = dataSource
                    }
                }
                chatInfoViewController.action = sender as? ChatAction
            }
        }
    }
    
    private func didTapDelete() {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            SVProgressHUD.dismiss()
            return
        }
        
        let alertController = UIAlertController(title: "SA_STR_WARNING".localized,
                                                message: "SA_STR_DO_YOU_REALLY_WANT_TO_DELETE_SELECTED_DIALOG".localized,
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel, handler: nil)
        
        let leaveAction = UIAlertAction(title: "SA_STR_DELETE".localized, style: .default) { (action:UIAlertAction) in
            
            SVProgressHUD.show(withStatus: "SA_STR_DELETING".localized)
            self.infoItem.isEnabled = false
            
            guard let dialogID = self.dialog.id else {
                SVProgressHUD.dismiss()
                return
            }
            
            if self.dialog.type == .private {
                self.chatManager.leaveDialog(withID: dialogID)
                self.navigationController?.popViewController(animated: true)
            } else {
                
                let currentUser = Profile()
                guard currentUser.isFull == true else {
                    return
                }
                // group
                self.dialog.pullOccupantsIDs = [(NSNumber(value: currentUser.ID)).stringValue]
                
                let message = "\(currentUser.fullName) " + "SA_STR_USER_HAS_LEFT".localized
                // Notifies occupants that user left the dialog.
                self.chatManager.sendLeaveMessage(message, to: self.dialog, completion: { (error) in
                    if let error = error {
                        self.infoItem.isEnabled = true
                        debugPrint("[ChatViewController] sendLeaveMessage error: \(error.localizedDescription)")
                        SVProgressHUD.dismiss()
                        return
                    }
                    self.chatManager.leaveDialog(withID: dialogID)
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(leaveAction)
        present(alertController, animated: true, completion: nil)
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
                self?.inputToolbar.contentView.textView.resignFirstResponder()
            }
        }
        if animated {
            hideKeyboardBlock()
        } else {
            UIView.performWithoutAnimation(hideKeyboardBlock)
        }
    }
    
    private func updateCollectionViewInsets() {
        if topContentAdditionalInset > 0.0 {
            var contentInset = collectionView.contentInset
            contentInset.top = topContentAdditionalInset
            collectionView.contentInset = contentInset
            collectionView.scrollIndicatorInsets = contentInset
        }
    }
    
    private func showPickerController(_ pickerController:UIImagePickerController?, sourceType: UIImagePickerController.SourceType) {
        let show: (UIImagePickerController) -> Void = { [weak self] (pickerController) in
            DispatchQueue.main.async {
                pickerController.sourceType = sourceType
                self?.present(pickerController, animated: true, completion: nil)
            }
        }
        
        let showAllAssets: () -> Void = { [weak self]  in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                guard let selectAssetsVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectAssetsVC") as? SelectAssetsVC else {
                    return
                }
                selectAssetsVC.modalPresentationStyle = .overCurrentContext
                selectAssetsVC.selectedAssetCompletion = { [weak self] selectedAsset in
                    if let selectedAsset = selectedAsset {
                        DispatchQueue.main.async {
                            self?.showAttachmentBar(with: selectedAsset, attachmentType: .Image)
                        }
                    }
                }
                self.present(selectAssetsVC, animated: false)
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
        if let pickerController = pickerController, sourceType == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                show(pickerController)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        DispatchQueue.main.async {
                            show(pickerController)
                        }
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            }
        } else {
            //Photo Library
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                showAllAssets()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized {
                        showAllAssets()
                    } else {
                        accessDenied(sourceType)
                    }
                }
            case .denied, .restricted:
                accessDenied(sourceType)
            case .limited:
                showAllAssets()
            }
        }
    }
    
    private func showAttachmentBar(with asset: PhotoAsset, url: URL? = nil, attachmentType: AttachmentType) {
        view.addSubview(attachmentBar)
        attachmentBar.delegate = self
        attachmentBar.translatesAutoresizingMaskIntoConstraints = false
        attachmentBar.leftAnchor.constraint(equalTo: inputToolbar.leftAnchor).isActive = true
        attachmentBar.rightAnchor.constraint(equalTo: inputToolbar.rightAnchor).isActive = true
        attachmentBar.bottomAnchor.constraint(equalTo: inputToolbar.topAnchor).isActive = true
        attachmentBar.heightAnchor.constraint(equalToConstant: ChatViewControllerConstant.attachmentBarHeight).isActive = true
        attachmentBar.uploadAttachmentImage(asset, url: url, attachmentType: attachmentType)
        attachmentBar.cancelButton.isHidden = true
        collectionBottomConstant = ChatViewControllerConstant.attachmentBarHeight
        collectionBottomConstraint.constant = collectionBottomConstant
        isUploading = true
        inputToolbar.toggleSendButtonEnabled(isUploaded: isUploading)
    }
    
    private func hideAttacnmentBar() {
        isUploading = false
        inputToolbar.toggleSendButtonEnabled(isUploaded: isUploading)
        attachmentBar.removeFromSuperview()
        attachmentBar.attachmentImageView.image = nil
        collectionBottomConstant = 0.0
        collectionBottomConstraint.constant = collectionBottomConstant
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    private func createAttachmentMessage(with attachment: QBChatAttachment) -> QBChatMessage {
        let message = QBChatMessage.markable()
        message.text = "[Attachment]"
        message.senderID = currentUserID
        message.dialogID = dialogID
        message.deliveredIDs = [(NSNumber(value: currentUserID))]
        message.readIDs = [(NSNumber(value: currentUserID))]
        message.dateSent = Date()
        message.customParameters["save_to_history"] = true
        message.attachments = [attachment]
        return message
    }
    
    private func didPressSend(_ button: UIButton) {
        if Reachability.instance.networkConnectionStatus() == .notConnection {
            showAlertView(LoginConstant.checkInternet, message: LoginConstant.checkInternetMessage)
            inputToolbar.toggleSendButtonEnabled(isUploaded: self.isUploading)
            SVProgressHUD.dismiss()
            return
        }
        if let attacmentMessage = attachmentMessage {
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
        message.senderID = currentUserID
        message.dialogID = dialogID
        message.deliveredIDs = [(NSNumber(value: currentUserID))]
        message.readIDs = [(NSNumber(value: currentUserID))]
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
            self?.stopTyping()
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
        guard let text = inputToolbar.contentView.textView.text else {
            return nil
        }
        return text
    }
    
    private func showTypingView() {
        view.addSubview(typingView)
        typingView.translatesAutoresizingMaskIntoConstraints = false
        typingView.leftAnchor.constraint(equalTo: inputToolbar.leftAnchor).isActive = true
        typingView.rightAnchor.constraint(equalTo: inputToolbar.rightAnchor).isActive = true
        typingView.bottomAnchor.constraint(equalTo: inputToolbar.topAnchor).isActive = true
        typingView.heightAnchor.constraint(equalToConstant: topContentAdditionalInset).isActive = true
        collectionBottomConstraint.constant = collectionBottomConstant + topContentAdditionalInset
    }
    
    @objc private func hideTypingView() {
        typingView.removeFromSuperview()
        collectionBottomConstant = 0.0
        collectionBottomConstraint.constant = collectionBottomConstant
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
        isOpponentTyping = false
        privateUserIsTypingTimer?.invalidate()
        privateUserIsTypingTimer = nil
    }
    
    @objc private func stopTyping() {
        stopTimer?.invalidate()
        stopTimer = nil
        dialog.sendUserStoppedTyping()
    }
    
    private func sendIsTypingStatus() {
        dialog.sendUserIsTyping()
        stopTimer?.invalidate()
        stopTimer = nil
        stopTimer = Timer.scheduledTimer(timeInterval: 6.0,
                                         target: self,
                                         selector: #selector(stopTyping),
                                         userInfo: nil,
                                         repeats: false)
    }
    
    //MARK: - ChatContextMenu Protocol
    internal func deliveredToAction() {
        performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_INFO".localized, sender: ChatAction.DeliveredTo)
    }
    
    internal func viewedByAction() {
        performSegue(withIdentifier: "SA_STR_SEGUE_GO_TO_INFO".localized, sender: ChatAction.ViewedBy)
    }
    
    internal func forwardAction() {
        guard let selectedIndexPathForMenu = selectedIndexPathForMenu,
              let message = dataSource.messageWithIndexPath(selectedIndexPathForMenu) else {
            return
        }
        let storyboard = UIStoryboard(name: "Dialogs", bundle: nil)
        if let dialogsSelection = storyboard.instantiateViewController(withIdentifier: "DialogsSelectionVC") as? DialogsSelectionVC {
            dialogsSelection.action = ChatAction.Forward
            dialogsSelection.message = message
            
            let navVC = UINavigationController(rootViewController: dialogsSelection)
            navVC.navigationBar.barTintColor = #colorLiteral(red: 0.2216441333, green: 0.4713830948, blue: 0.9869660735, alpha: 1)
            navVC.navigationBar.barStyle = .black
            navVC.navigationBar.shadowImage = UIImage(named: "navbar-shadow")
            navVC.navigationBar.isTranslucent = false
            navVC.modalPresentationStyle = .fullScreen
            present(navVC, animated: false)
        }
    }
    
    internal func saveFileAttachment(fromCell cell: ChatAttachmentCell) {
        guard let url = cell.attachmentUrl else {
            return
        }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // delete original copy
        try? FileManager.default.removeItem(at: destinationURL)
        // copy from temp to Document
        do {
            try FileManager.default.copyItem(at: url, to: destinationURL)
            SVProgressHUD.showSuccess(withStatus: "Saved!")
        } catch let error {
            SVProgressHUD.showError(withStatus: "Save error")
            debugPrint("[ChatViewController] Copy Error: \(error.localizedDescription)")
        }
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
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL.rawValue] as? URL {
            inputToolbar.toggleSendButtonEnabled(isUploaded: isUploading)
            do {
                let asset = AVURLAsset(url: videoURL, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                let photoAsset = PhotoAsset(phAsset: PHAsset(), image: thumbnail)
                showAttachmentBar(with: photoAsset, url: videoURL, attachmentType: .Video)
                picker.dismiss(animated: true, completion: nil)
            } catch let error {
                debugPrint("[ChatViewController] Error generating thumbnail: \(error.localizedDescription)")
                picker.dismiss(animated: true, completion: nil)
            }
            
        }
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            let photoAsset = PhotoAsset(phAsset: PHAsset(), image: image)
            showAttachmentBar(with: photoAsset, attachmentType: .Image)
        }
    }
    
    // Helper function.
    private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})}
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        inputToolbar.toggleSendButtonEnabled(isUploaded: isUploading)
    }
}

//MARK: - ChatDataSourceDelegate
extension ChatViewController: ChatDataSourceDelegate {
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        willChangeWithMessageIDs IDs: [String]) {
        IDs.forEach{ collectionView.chatCollectionViewLayout?.removeSizeFromCache(forItemID: $0)
            
        }
    }
    
    func chatDataSource(_ chatDataSource: ChatDataSource,
                        changeWithMessages messages: [QBChatMessage],
                        action: ChatDataSourceAction) {
        if messages.isEmpty {
            return
        }
        var messagesArray = messages.sorted(by: {
            guard let firstUpdateAt = $0.dateSent, let lastUpdate = $1.dateSent else {
                return false
            }
            return firstUpdateAt > lastUpdate
        })
        
        messagesArray.reverse()
        
        collectionView.performBatchUpdates({ [weak self] in
            guard let self = self else {
                return
            }
            
            let indexPaths = chatDataSource.performChangesFor(messages: messagesArray, action: action)
            
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
        if isUploading {
            showAlertView("You can send 1 attachment per message", message: nil)
        } else {
            
            inputToolbar.contentView.textView.resignFirstResponder()
            
            let alertController = UIAlertController(title: nil,
                                                    message: nil,
                                                    preferredStyle: .actionSheet)
            #if targetEnvironment(simulator)
            debugPrint("[ChatViewController] targetEnvironment simulator")
            
            #else
            alertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.showPickerController(self.pickerController, sourceType:.camera)
            }))
            #endif
            
            alertController.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (action) in
                self.showPickerController(nil, sourceType: .photoLibrary)
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
}

//MARK: - UICollectionViewDelegate - ContextMenu
extension ChatViewController: UICollectionViewDelegate {
    private func targetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let selectedIndexPath = selectedIndexPathForMenu,
              let selectedCell = collectionView.cellForItem(at: selectedIndexPath) as? ChatCell,
              let message = dataSource.messageWithIndexPath(selectedIndexPath) else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        var roundingCorners: UIRectCorner = [.bottomLeft, .topLeft, .topRight]
        
        if message.senderID != currentUserID {
            roundingCorners = [.topLeft, .topRight, .bottomRight]
        }
        let cornerRadius = selectedCell is ChatAttachmentCell ? 6.0 : 20.0
        
        parameters.visiblePath = UIBezierPath(roundedRect: selectedCell.previewContainer.bounds,
                                              byRoundingCorners:  roundingCorners,
                                              cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        return UITargetedPreview(view: selectedCell.previewContainer, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return targetedPreview(for: configuration)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return targetedPreview(for: configuration)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        selectedIndexPathForMenu = indexPath
        
        guard let  message = dataSource.messageWithIndexPath(indexPath) else {
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            if let attachmentCell = collectionView.cellForItem(at: indexPath) as? ChatAttachmentCell,
               let attachment = message.attachments?.first,
               attachment.type == "file" {
                return self.chatContextMenu(forSender: false, forCell: attachmentCell)
            }
            if self.dialog.type == .private || message.senderID != self.currentUserID {
                return self.chatContextMenu(forSender: false)
            } else {
                return self.chatContextMenu(forSender: true)
            }
        }
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
        
        guard let chatCell = cell as? ChatCell else {
            return
        }
        
        if (cell is ChatIncomingCell || cell is ChatAttachmentIncomingCell) && dialog.type != .private,
           chatManager.storage.user(withID: message.senderID) == nil {
            ChatManager.instance.loadUser(message.senderID) { (user) in
                guard let loadedUser = user,
                      let userName = loadedUser.fullName,
                      userName.isEmpty == false else {return}
                
                chatCell.topLabel.text = userName
                chatCell.avatarLabel.text = String(userName.capitalized.first ?? Character("QB"))
                chatCell.avatarLabel.backgroundColor = message.senderID.generateColor()
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if cell is ChatAttachmentCell {
            guard let item = dataSource.messageWithIndexPath(indexPath),
                  let attachment = item.attachments?.first,
                  let attachmentID = attachment.id else {
                return
            }
            let attachmentDownloadManager = AttachmentDownloadManager()
            attachmentDownloadManager.slowDownloadAttachment(attachmentID)
        }
    }
    
    private func collectionView(_ collectionView: ChatCollectionView,
                                configureCell cell: UICollectionViewCell,
                                for indexPath: IndexPath) {
        
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return
        }
        
        if message.readIDs?.contains(NSNumber(value: currentUserID)) == false {
            if QBChat.instance.isConnected == false {
                dataSource.messagesForRead.insert(message)
            } else {
                chatManager.read(message, dialog: dialog) { [weak self] (error) in
                    guard let self = self else {return}
                    message.readIDs?.append(NSNumber(value: self.currentUserID))
                    self.dataSource.updateMessage(message)
                    self.dataSource.messagesForRead.remove(message)
                }
            }
        }
        
        if let dateCell = cell as? ChatDateCell {
            dateCell.isUserInteractionEnabled = false
            dateCell.dateLabel.text = attributedString(forItem: message)?.string ?? ""
            return
        }
        
        if let notificationCell = cell as? ChatNotificationCell {
            notificationCell.isUserInteractionEnabled = false
            notificationCell.notificationLabel.text = attributedString(forItem: message)?.string
            return
        }
        
        guard let chatCell = cell as? ChatCell else {
            return
        }
        
        if cell is ChatIncomingCell
            || cell is ChatOutgoingCell {
            chatCell.textView.enabledTextCheckingTypes = enableTextCheckingTypes
        }
        
        let username = topLabelAttributedString(forItem: message)
        chatCell.topLabel.text = username
        if (cell is ChatIncomingCell || cell is ChatAttachmentIncomingCell) && dialog.type != .private {
            let userName = username?.string
            chatCell.avatarLabel.text = String(userName?.capitalized.first ?? Character("QB"))
            chatCell.avatarLabel.backgroundColor = message.senderID.generateColor()
        }

        chatCell.timeLabel.text = timeLabelAttributedString(forItem: message)
        if let chatOutgoingCell = chatCell as? ChatOutgoingCell {
            chatOutgoingCell.setupStatusImage(statusImageForMessage(message: message))
        }
        
        if let textView = chatCell.textView {
            textView.text = attributedString(forItem: message)
        }
        
        chatCell.delegate = self
        
        if let attachmentCell = cell as? ChatAttachmentCell {
            guard let attachment = message.attachments?.first else {
                return
            }
            
            if let originForwardName = message.customParameters[ChatDataSourceConstant.forwardedMessage] as? String {
                attachmentCell.forwardInfoHeightConstraint.constant = 35.0
                attachmentCell.forwardedLabel.attributedText = forwardedAttachmentAttributedString(forOriginName: originForwardName)
            } else {
                attachmentCell.forwardInfoHeightConstraint.constant = 0.0
            }
            
            if attachmentCell is ChatAttachmentOutgoingCell {
                if let attachmentCell = attachmentCell as? ChatAttachmentOutgoingCell {
                    attachmentCell.setupStatusImage(statusImageForMessage(message: message))
                }
            }
            attachmentCell.setupAttachment(attachment)
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
        layoutModel.maxWidthMarginSpace = 20.0
        
        if cellClass == ChatIncomingCell.self || cellClass == ChatAttachmentIncomingCell.self {
            
            if dialog.type != .private {
                layoutModel.avatarSize = CGSize(width: 40.0, height: 40.0)
            } else {
                layoutModel.avatarSize = CGSize.zero
                let left:CGFloat = cellClass == ChatIncomingCell.self ? 10.0 : 0.0
                layoutModel.containerInsets = UIEdgeInsets(top: 0.0,
                                                           left: left,
                                                           bottom: 16.0,
                                                           right: 16.0)
            }
        }
        
        layoutModel.spaceBetweenTopLabelAndTextView = 12.0
        
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
        
        let dateAttributedString = timeLabelAttributedString(forItem: item)
        let sizeDateAttributedString = TTTAttributedLabel.sizeThatFitsAttributedString(
            dateAttributedString,
            withConstraints: constraintsSize,
            limitedToNumberOfLines:1)
        
        
        let nameAttributedString = topLabelAttributedString(forItem: item)
        
        let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(
            nameAttributedString,
            withConstraints: constraintsSize,
            limitedToNumberOfLines:1)
        
        if item.senderID == currentUserID {
            let statusWidth: CGFloat = 46.0
            return topLabelSize.width + sizeDateAttributedString.width + statusWidth
        }
        let topLabelWidth = topLabelSize.width + sizeDateAttributedString.width
        return topLabelWidth > 86.0 ? topLabelWidth : 86.0
    }
    
    func collectionView(_ collectionView: ChatCollectionView, dynamicSizeAt indexPath: IndexPath, maxWidth: CGFloat) -> CGSize {
        var size: CGSize = .zero
        guard let message = dataSource.messageWithIndexPath(indexPath) else {
            return size
        }
        let messageCellClass = viewClass(forItem: message)
        
        if messageCellClass === ChatAttachmentIncomingCell.self || messageCellClass === ChatAttachmentOutgoingCell.self {
            size = CGSize(width: min(260, maxWidth), height: 180)
            
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
        if textView.text.hasPrefix(" ") {
            textView.text = String(textView.text.dropFirst())
        }
        
        if textView.text.count > ChatViewControllerConstant.maxNumberСharacters {
            textView.text = String(textView.text.prefix(ChatViewControllerConstant.maxNumberСharacters - 1))
        }
        
        sendIsTypingStatus()
        inputToolbar.toggleSendButtonEnabled(isUploaded: isUploading)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView != inputToolbar.contentView.textView {
            return
        }
        stopTyping()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView != inputToolbar.contentView.textView {
            return false
        }
        
        return true
    }
    
    override func paste(_ sender: Any?) {
        let textAttachment = NSTextAttachment()
        textAttachment.image = UIPasteboard.general.image
        let attributedText = NSAttributedString(attachment: textAttachment)
        if let textView = inputToolbar.contentView.textView {
            textView.attributedText = attributedText
        }
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
    
    func chatCellDidTapContainer(_ cell: ChatCell) {
        if let attachmentCell = cell as? ChatAttachmentCell {
            guard let indexpath = collectionView.indexPath(for: attachmentCell),
                  let item = dataSource.messageWithIndexPath(indexpath),
                  let attachment = item.attachments?.first,
                  let attachmentID = attachment.id else {
                return
            }
            if attachment.type == "image" {
                if let attachmentImage = attachmentCell.attachmentImageView.image {
                    let zoomedVC = ZoomedAttachmentViewController()
                    zoomedVC.zoomImageView.image = attachmentImage
                    let navVC = UINavigationController(rootViewController: zoomedVC)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: false)
                }
            } else if attachment.type == "video" {
                let videoURL = CacheManager.shared.cachesDirectoryUrl.appendingPathComponent(attachmentID + "_" + (attachment.name ?? "video.mp4"))
                if FileManager.default.fileExists(atPath: videoURL.path) == true {
                    let parentVideoVC = ParentVideoVC()
                    parentVideoVC.videoURL = videoURL
                    parentVideoVC.title = attachment.name ?? ""
                    let navVC = UINavigationController(rootViewController: parentVideoVC)
                    navVC.modalPresentationStyle = .fullScreen
                    present(navVC, animated: false)
                }
            }
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
                SVProgressHUD.showError(withStatus: "Your Device can't make a phone call".localized)
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
        if let url = URL(string: "tel://"), UIApplication.shared.canOpenURL(url) == true {
            // Check if iOS Device supports phone calls
            guard let carrier = CTTelephonyNetworkInfo().serviceSubscriberCellularProviders?.first?.value,
                  let mobileNetworkCode = carrier.mobileNetworkCode else {
                return false
            }
            
            if mobileNetworkCode.isEmpty == true {
                // Device cannot place a call at this time.  SIM might be removed.
                return false
            } else {
                // iOS Device is capable for making calls
                return true
            }
        } else {
            // iOS Device is not capable for making calls
            return false
        }
    }
}

//MARK: - QBChatDelegate
extension ChatViewController: QBChatDelegate {
    func chatDidReadMessage(withID messageID: String, dialogID: String, readerID: UInt) {
        if currentUserID == readerID || dialogID != self.dialogID {
            return
        }
        guard let message = dataSource.messageWithID(messageID),
              message.readIDs?.contains(NSNumber(value: readerID)) == false else {
            return
        }
        message.readIDs?.append(NSNumber(value: readerID))
        dataSource.updateMessage(message)
    }
    
    func chatDidDeliverMessage(withID messageID: String, dialogID: String, toUserID userID: UInt) {
        if currentUserID == userID || dialogID != self.dialogID {
            return
        }
        guard let message = dataSource.messageWithID(messageID),
              message.deliveredIDs?.contains(NSNumber(value: userID)) == false else {
            return
        }
        message.deliveredIDs?.append(NSNumber(value: userID))
        dataSource.updateMessage(message)
    }
    
    func chatDidReceive(_ message: QBChatMessage) {
        if message.dialogID == self.dialogID && message.senderID != currentUserID {
            dataSource.addMessage(message)
        }
    }
    func chatRoomDidReceive(_ message: QBChatMessage, fromDialogID dialogID: String) {
        if dialogID == self.dialogID && message.senderID != currentUserID {
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
        // Autojoin to the group chat
        if dialog.type != .private, dialog.isJoined() == false {
            dialog.join(completionBlock: { error in
                guard let error = error else {
                    return
                }
                debugPrint("[ChatViewController] dialog.join error: \(error.localizedDescription)")
            })
        }
        if dataSource.messagesForRead.isEmpty == false {
            let messages = Array(dataSource.messagesForRead)
            for message in messages {
                chatManager.read(message, dialog: dialog) { [weak self] (error) in
                    guard let self = self else {return}
                    message.readIDs?.append(NSNumber(value: self.currentUserID))
                    self.dataSource.updateMessage(message)
                    self.dataSource.messagesForRead.remove(message)
                }
            }
        }
        loadMessages()
    }
}

//MARK: - AttachmentBarDelegate
extension ChatViewController: AttachmentBarDelegate {
    func attachmentBarFailedUpLoadImage(_ attachmentBar: AttachmentUploadBar) {
        cancelUploadFile()
    }
    
    func attachmentBar(_ attachmentBar: AttachmentUploadBar, didUpLoadAttachment attachment: QBChatAttachment) {
        attachmentMessage = createAttachmentMessage(with: attachment)
        inputToolbar.toggleSendButtonEnabled(isUploaded: isUploading)
    }
    
    func attachmentBar(_ attachmentBar: AttachmentUploadBar, didTapCancelButton: UIButton) {
        attachmentMessage = nil
        hideAttacnmentBar()
    }
}

//MARK: - UIPopoverPresentationControllerDelegate
extension ChatViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
