//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import CoreTelephony
import SafariServices

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

extension String {
    var length: Int {
        return (self as NSString).length
    }
    
}

class ChatViewController: QMChatViewController, QMChatServiceDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate, QMChatCellDelegate {
    
    let maxCharactersNumber = 1024 // 0 - unlimited
    
    
    var dialog: QBChatDialog!
    var willResignActiveBlock: AnyObject?
    var attachmentCellsMap: NSMapTable<AnyObject, AnyObject>!
    var detailedCells: Set<String> = []
    
    var typingTimer: Timer?
    var popoverController: UIPopoverController?
    
    lazy var imagePickerViewController : UIImagePickerController = {
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        
        return imagePickerViewController
    }()
    
    var unreadMessages: [QBChatMessage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // top layout inset for collectionView
        self.topContentAdditionalInset = self.navigationController!.navigationBar.frame.size.height + UIApplication.shared.statusBarFrame.size.height;
        
        if let currentUser = ServicesManager.instance().currentUser() {
            self.senderID = currentUser.id
            self.senderDisplayName = currentUser.login
            
            self.heightForSectionHeader = 40.0
            
            self.updateTitle()
            
            self.collectionView?.backgroundColor = UIColor.white
            self.inputToolbar?.contentView?.backgroundColor = UIColor.white
            self.inputToolbar?.contentView?.textView?.placeHolder = "SA_STR_MESSAGE_PLACEHOLDER".localized
            
            self.attachmentCellsMap = NSMapTable(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
            
            if self.dialog.type == QBChatDialogType.private {
                
                self.dialog.onUserIsTyping = {
                    [weak self] (userID)-> Void in
                    
                    if ServicesManager.instance().currentUser()?.id == userID {
                        return
                    }
                    
                    self?.title = "SA_STR_TYPING".localized
                }
                
                self.dialog.onUserStoppedTyping = {
                    [weak self] (userID)-> Void in
                    
                    if ServicesManager.instance().currentUser()?.id == userID {
                        return
                    }
                    
                    self?.updateTitle()
                }
            }
            
            ServicesManager.instance().chatService.addDelegate(self)
            ServicesManager.instance().chatService.chatAttachmentService.delegate = self
            
            // Retrieving messages
            if ((self.storedMessages()?.count)! > 0 && self.chatSectionManager.totalMessagesCount == 0) {
                
                self.chatSectionManager.add(self.storedMessages()!)
            }
            
            self.loadMessages()
            
            self.enableTextCheckingTypes = NSTextCheckingAllTypes
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.willResignActiveBlock = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] (notification) in
            
            self?.fireSendStopTypingIfNecessary()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Saving current dialog ID.
        ServicesManager.instance().currentDialogID = self.dialog.id!
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let willResignActive = self.willResignActiveBlock {
            NotificationCenter.default.removeObserver(willResignActive)
        }
        
        // Resetting current dialog ID.
        ServicesManager.instance().currentDialogID = ""
        
        // clearing typing status blocks
        self.dialog.clearTypingStatusBlocks()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let chatInfoViewController = segue.destination as? ChatUsersInfoTableViewController {
            chatInfoViewController.dialog = self.dialog
        }
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Update
    
    func updateTitle() {
        
        if self.dialog.type != QBChatDialogType.private {
            
            self.title = self.dialog.name
        }
        else {
            
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(self.dialog!.recipientID)) {
                
                self.title = recipient.login
            }
        }
    }
    
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messages(withDialogID: self.dialog.id!)
    }
    
    func loadMessages() {
        // Retrieving messages for chat dialog ID.
        guard let currentDialogID = self.dialog.id else {
            print ("Current chat dialog is nil")
            return
        }
        
        ServicesManager.instance().chatService.messages(withChatDialogID: currentDialogID, completion: {
            [weak self] (response: QBResponse, messages: [QBChatMessage]?) -> Void in
            
            guard let strongSelf = self else { return }
            
            guard response.error == nil else {
                SVProgressHUD.showError(withStatus: response.error?.error?.localizedDescription)
                return
            }
            
            if (messages?.count)! > 0 {
                strongSelf.chatSectionManager.add(messages)
            }
            SVProgressHUD.dismiss()
            
            })
    }
    
    func sendReadStatusForMessage(message: QBChatMessage) {
        
        guard QBSession.current().currentUser != nil else {
            return
        }
        guard message.senderID != QBSession.current().currentUser?.id else {
            return
        }
        
        let currentUserID = NSNumber(value: QBSession.current().currentUser!.id)
        
        if (message.readIDs == nil || !message.readIDs!.contains(currentUserID)) {
            ServicesManager.instance().chatService.read(message, completion: { (error) -> Void in
                
                guard error == nil else {
                    print("Problems while marking message as read! Error: %@", error!)
                    return
                }
                
                if UIApplication.shared.applicationIconBadgeNumber > 0 {
                    let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
                    UIApplication.shared.applicationIconBadgeNumber = badgeNumber - 1
                }
            })
        }
    }
    
    func readMessages(messages: [QBChatMessage]) {
        
        if QBChat.instance().isConnected {
            
            ServicesManager.instance().chatService.read(messages, forDialogID: self.dialog.id!, completion: nil)
        }
        else {
            
            self.unreadMessages = messages
        }
        
        var messageIDs = [String]()
        
        for message in messages {
            messageIDs.append(message.id!)
        }
    }
    
    // MARK: Actions
    
    override func didPickAttachmentImage(_ image: UIImage!) {
        
        let message = QBChatMessage()
        message.senderID = self.senderID
        message.dialogID = self.dialog.id
        message.dateSent = Date()
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            guard let strongSelf = self else { return }
            
            var newImage : UIImage! = image
            if strongSelf.imagePickerViewController.sourceType == UIImagePickerControllerSourceType.camera {
                newImage = newImage.fixOrientation()
            }
            
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
            
            // create smaller image
            
            UIGraphicsBeginImageContext(newSize)
            
            newImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // Sending attachment.
            DispatchQueue.main.async(execute: {
                
                
                // sendAttachmentMessage method always firstly adds message to memory storage
                ServicesManager.instance().chatService.sendAttachmentMessage(message, to: self!.dialog, withAttachmentImage: resizedImage!, completion: {
                    [weak self] (error) -> Void in
                    
                    self?.attachmentCellsMap.removeObject(forKey: message.id as AnyObject?)
                    
                    guard error != nil else { return }
                    
                    // perform local attachment message deleting if error
                    ServicesManager.instance().chatService.deleteMessageLocally(message)
                    
                    self?.chatSectionManager.delete(message)
                    
                    })
            })
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: Date!) {
        
        let shouldJoin = self.dialog.type == .group ? !self.dialog.isJoined() : false
        
        if !QBChat.instance().isConnected || shouldJoin {
            
            if shouldJoin {
                
                QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR".localized, subtitle:"SA_STR_MESSAGE_FAILED_TO_SEND".localized, type: QMMessageNotificationType.error)
            }
            
            return
        }
        
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text
        message.senderID = self.senderID
        message.deliveredIDs = [(NSNumber(value: self.senderID))]
        message.readIDs = [(NSNumber(value: self.senderID))]
        message.markable = true
        message.dateSent = date
        
        self.sendMessage(message: message)
    }
    
    func sendMessage(message: QBChatMessage) {
        
        // Sending message.
        ServicesManager.instance().chatService.send(message, toDialogID: self.dialog.id!, saveToHistory: true, saveToStorage: true) { (error) ->
            Void in
            
            if error != nil {
                
                QMMessageNotificationManager.showNotification(withTitle: "SA_STR_ERROR".localized, subtitle: error?.localizedDescription, type: QMMessageNotificationType.warning)
            }
        }
        
        self.finishSendingMessage(animated: true)
    }
    
    // MARK: Helper
    func canMakeACall() -> Bool {
        
        var canMakeACall = false
        
        if (UIApplication.shared.canOpenURL(NSURL.init(string: "tel://")! as URL)) {
            
            // Check if iOS Device supports phone calls
            let networkInfo = CTTelephonyNetworkInfo()
            let carrier = networkInfo.subscriberCellularProvider
            if carrier == nil {
                return false
            }
            let mnc = carrier?.mobileNetworkCode
            if mnc?.length == 0 {
                // Device cannot place a call at this time.  SIM might be removed.
            }
            else {
                // iOS Device is capable for making calls
                canMakeACall = true
            }
        }
        else {
            // iOS Device is not capable for making calls
        }
        
        return canMakeACall
    }
    
    func showCharactersNumberError() {
        let title  = "SA_STR_ERROR".localized;
        let subtitle = String(format: "The character limit is %lu.", maxCharactersNumber)
        QMMessageNotificationManager.showNotification(withTitle: title, subtitle: subtitle, type: .error)
    }
    
    /**
     Builds a string
     Read: login1, login2, login3
     Delivered: login1, login3, @12345
     
     If user does not exist in usersMemoryStorage, then ID will be used instead of login
     
     - parameter message: QBChatMessage instance
     
     - returns: status string
     */
    func statusStringFromMessage(message: QBChatMessage) -> String {
        
        var statusString = ""
        
        let currentUserID = NSNumber(value:self.senderID)
        
        var readLogins: [String] = []
        
        if message.readIDs != nil {
            let messageReadIDs = message.readIDs!.filter { (element : NSNumber) -> Bool in
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageReadIDs.isEmpty {
                for readID in messageReadIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(readID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(readID)"
                        readLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    readLogins.append(unwrappedUser.login!)
                }
                
                statusString += message.isMediaMessage() ? "SA_STR_SEEN_STATUS".localized : "SA_STR_READ_STATUS".localized;
                statusString += ": " + readLogins.joined(separator: ", ")
            }
        }
        
        if message.deliveredIDs != nil {
            var deliveredLogins: [String] = []
            
            let messageDeliveredIDs = message.deliveredIDs!.filter { (element : NSNumber) -> Bool in
                return !element.isEqual(to: currentUserID)
            }
            
            if !messageDeliveredIDs.isEmpty {
                for deliveredID in messageDeliveredIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: UInt(deliveredID))
                    
                    guard let unwrappedUser = user else {
                        let unknownUserLogin = "@\(deliveredID)"
                        deliveredLogins.append(unknownUserLogin)
                        
                        continue
                    }
                    
                    if readLogins.contains(unwrappedUser.login!) {
                        continue
                    }
                    
                    deliveredLogins.append(unwrappedUser.login!)
                    
                }
                
                if readLogins.count > 0 && deliveredLogins.count > 0 {
                    statusString += "\n"
                }
                
                if deliveredLogins.count > 0 {
                    statusString += "SA_STR_DELIVERED_STATUS".localized + ": " + deliveredLogins.joined(separator: ", ")
                }
            }
        }
        
        if statusString.isEmpty {
            statusString = "SA_STR_SENT_STATUS".localized
        }
        
        return statusString
    }
    
    // MARK: Override
    
    override func viewClass(forItem item: QBChatMessage) -> AnyClass? {
        // TODO: check and add QMMessageType.AcceptContactRequest, QMMessageType.RejectContactRequest, QMMessageType.ContactRequest
        
        if item.isNotificatonMessage() {
            return QMChatNotificationCell.self
        }
        
        if (item.senderID != self.senderID) {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentIncomingCell.self
                
            }
            else {
                
                return QMChatIncomingCell.self
            }
            
        }
        else {
            
            if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.error) {
                
                return QMChatAttachmentOutgoingCell.self
                
            }
            else {
                
                return QMChatOutgoingCell.self
            }
        }
    }
    
    // MARK: Strings builder
    
    override func attributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {
        
        guard messageItem.text != nil else {
            return nil
        }
        
        var textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black
        if messageItem.isNotificatonMessage() {
            textColor = UIColor.black
        }
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 17)
        
        let attributedString = NSAttributedString(string: messageItem.text!, attributes: attributes)
        
        return attributedString
    }
    
    
    /**
     Creates top label attributed string from QBChatMessage
     
     - parameter messageItem: QBCHatMessage instance
     
     - returns: login string, example: @SwiftTestDevUser1
     */
    override func topLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString? {
        
        guard messageItem.senderID != self.senderID else {
            return nil
        }
        
        guard self.dialog.type != QBChatDialogType.private else {
            return nil
        }
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byTruncatingTail
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 17)
        attributes[NSParagraphStyleAttributeName] = paragrpahStyle
        
        var topLabelAttributedString : NSAttributedString?
        
        if let topLabelText = ServicesManager.instance().usersService.usersMemoryStorage.user(withID: messageItem.senderID)?.login {
            topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        } else { // no user in memory storage
            topLabelAttributedString = NSAttributedString(string: "@\(messageItem.senderID)", attributes: attributes)
        }
        
        return topLabelAttributedString
    }
    
    /**
     Creates bottom label attributed string from QBChatMessage using self.statusStringFromMessage
     
     - parameter messageItem: QBChatMessage instance
     
     - returns: bottom label status string
     */
    override func bottomLabelAttributedString(forItem messageItem: QBChatMessage!) -> NSAttributedString! {
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.white : UIColor.black
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 13)
        attributes[NSParagraphStyleAttributeName] = paragrpahStyle
        
        var text = messageItem.dateSent != nil ? messageTimeDateFormatter.string(from: messageItem.dateSent!) : ""
        
        if messageItem.senderID == self.senderID {
            text = text + "\n" + self.statusStringFromMessage(message: messageItem)
        }
        
        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(_ collectionView: QMChatCollectionView!, dynamicSizeAt indexPath: IndexPath!, maxWidth: CGFloat) -> CGSize {
        
        var size = CGSize.zero
        
        guard let message = self.chatSectionManager.message(for: indexPath) else {
            return size
        }
        
        let messageCellClass: AnyClass! = self.viewClass(forItem: message)
        
        
        if messageCellClass === QMChatAttachmentIncomingCell.self {
            size = CGSize(width: min(200, maxWidth), height: 200)
        }
        else if messageCellClass === QMChatAttachmentOutgoingCell.self {
            let attributedString = self.bottomLabelAttributedString(forItem: message)
            
            let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: min(200, maxWidth), height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
            size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
        }
        else if messageCellClass === QMChatNotificationCell.self {
            let attributedString = self.attributedString(forItem: message)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
            
        }
        else {
            
            let attributedString = self.attributedString(forItem: message)
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: 0)
        }
        
        return size
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, minWidthAt indexPath: IndexPath!) -> CGFloat {
        
        var size = CGSize.zero
        
        guard let item = self.chatSectionManager.message(for: indexPath) else {
            return 0
        }
        
        if self.detailedCells.contains(item.id!) {
            
            let str = self.bottomLabelAttributedString(forItem: item)
            let frameWidth = collectionView.frame.width
            let maxHeight = CGFloat.greatestFiniteMagnitude
            
            size = TTTAttributedLabel.sizeThatFitsAttributedString(str, withConstraints: CGSize(width:frameWidth - kMessageContainerWidthPadding, height: maxHeight), limitedToNumberOfLines:0)
        }
        
        if self.dialog.type != QBChatDialogType.private {
            
            let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(self.topLabelAttributedString(forItem: item), withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
            
            if topLabelSize.width > size.width {
                size = topLabelSize
            }
        }
        
        return size.width
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, layoutModelAt indexPath: IndexPath!) -> QMChatCellLayoutModel {
        
        var layoutModel: QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAt: indexPath)
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5
        layoutModel.maxWidthMarginSpace = 20.0
        
        guard let item = self.chatSectionManager.message(for: indexPath) else {
            return layoutModel
        }
        
        let viewClass: AnyClass = self.viewClass(forItem: item)! as AnyClass
        
        if viewClass === QMChatIncomingCell.self || viewClass === QMChatAttachmentIncomingCell.self {
            
            if self.dialog.type != QBChatDialogType.private {
                let topAttributedString = self.topLabelAttributedString(forItem: item)
                let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:1)
                layoutModel.topLabelHeight = size.height
            }
            
            layoutModel.spaceBetweenTopLabelAndTextView = 5
        }
        
        var size = CGSize.zero
        
        if self.detailedCells.contains(item.id!) {
            
            let bottomAttributedString = self.bottomLabelAttributedString(forItem: item)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: collectionView.frame.width - kMessageContainerWidthPadding, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines:0)
        }
        
        layoutModel.bottomLabelHeight = floor(size.height)
        
        
        return layoutModel
    }
    
    override func collectionView(_ collectionView: QMChatCollectionView!, configureCell cell: UICollectionViewCell!, for indexPath: IndexPath!) {
        
        super.collectionView(collectionView, configureCell: cell, for: indexPath)
        
        // subscribing to cell delegate
        let chatCell = cell as! QMChatCell
        
        chatCell.delegate = self
        
        if let attachmentCell = cell as? QMChatAttachmentCell {
            
            if attachmentCell is QMChatAttachmentIncomingCell {
                chatCell.containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
            } else if attachmentCell is QMChatAttachmentOutgoingCell {
                chatCell.containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
            
            let message = self.chatSectionManager.message(for: indexPath)
            
            if let attachment = message?.attachments?.first {
                
                var keysToRemove: [String] = []
                
                let enumerator = self.attachmentCellsMap.keyEnumerator()
                
                while let existingAttachmentID = enumerator.nextObject() as? String {
                    let cachedCell = self.attachmentCellsMap.object(forKey: existingAttachmentID as AnyObject?)
                    if cachedCell === cell {
                        keysToRemove.append(existingAttachmentID)
                    }
                }
                
                for key in keysToRemove {
                    self.attachmentCellsMap.removeObject(forKey: key as AnyObject?)
                }
                
                self.attachmentCellsMap.setObject(attachmentCell, forKey: attachment.id as AnyObject?)
                
                attachmentCell.attachmentID = attachment.id
                
                // Getting image from chat attachment cache.
                
                ServicesManager.instance().chatService.chatAttachmentService.getImageForAttachmentMessage(message!, completion: {
                    [weak self] (error, image) -> Void in
                    
                    guard attachmentCell.attachmentID == attachment.id else {
                        return
                    }
                    
                    self?.attachmentCellsMap.removeObject(forKey: attachment.id as AnyObject?)
                    
                    guard error == nil else {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        print("Error downloading image from server: \(error).localizedDescription")
                        return
                    }
                    
                    if image == nil {
                        print("Image is nil")
                    }
                    
                    attachmentCell.setAttachmentImage(image)
                    cell.updateConstraints()
                    
                    })
            }
            
        }
        else if cell is QMChatIncomingCell || cell is QMChatAttachmentIncomingCell {
            
            chatCell.containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        }
        else if cell is QMChatOutgoingCell || cell is QMChatAttachmentOutgoingCell {
            
            chatCell.containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
        else if cell is QMChatNotificationCell {
            
            cell.isUserInteractionEnabled = false
            chatCell.containerView?.bgColor = self.collectionView?.backgroundColor
        }
    }
    
    /**
     Allows to copy text from QMChatIncomingCell and QMChatOutgoingCell
     */
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        guard let item = self.chatSectionManager.message(for: indexPath) else {
            return false
        }
        
        let viewClass: AnyClass = self.viewClass(forItem: item)! as AnyClass
        
        if viewClass === QMChatAttachmentIncomingCell.self ||
            viewClass === QMChatAttachmentOutgoingCell.self ||
            viewClass === QMChatNotificationCell.self ||
            viewClass === QMChatContactRequestCell.self {
            return false
        }
        
        return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        guard action == #selector(AnyObject.copy(_:)) else {
            return
        }
        
        let item = self.chatSectionManager.message(for: indexPath)
        let viewClass : AnyClass = self.viewClass(forItem: item!)! as AnyClass
        
        if viewClass === QMChatAttachmentIncomingCell.self
            || viewClass === QMChatAttachmentOutgoingCell.self
            || viewClass === QMChatNotificationCell.self
            || viewClass === QMChatContactRequestCell.self {
            
            return
        }
        
        UIPasteboard.general.string = item?.text
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let lastSection = (self.collectionView?.numberOfSections)! - 1
        
        if (indexPath.section == lastSection && indexPath.item == (self.collectionView?.numberOfItems(inSection: lastSection))! - 1) {
            // the very first message
            // load more if exists
            // Getting earlier messages for chat dialog identifier.
            
            guard let dialogID = self.dialog.id else {
                print("DialogID is nil")
                return super.collectionView(collectionView, cellForItemAt: indexPath)
            }
            
            ServicesManager.instance().chatService.loadEarlierMessages(withChatDialogID: dialogID).continue({ [weak self] (task) -> Any? in
                
                guard let strongSelf = self else { return nil }
                
                if ((task.result?.count)! > 0) {
                    strongSelf.chatSectionManager.add(task.result as! [QBChatMessage]!)
                }
                
                return nil
            })
            
        }
        
        // marking message as read if needed
        if let message = self.chatSectionManager.message(for: indexPath) {
            self.sendReadStatusForMessage(message: message)
        }
        
        return super.collectionView(collectionView, cellForItemAt
            : indexPath)
    }
    
    // MARK: QMChatCellDelegate
    
    /**
     Removes size from cache for item to allow cell expand and show read/delivered IDS or unexpand cell
     */
    func chatCellDidTapContainer(_ cell: QMChatCell!) {
        let indexPath = self.collectionView?.indexPath(for: cell)
        
        guard let currentMessageID = self.chatSectionManager.message(for: indexPath).id else {
            return
        }
        
        if self.detailedCells.contains(currentMessageID) {
            self.detailedCells.remove(currentMessageID)
        } else {
            self.detailedCells.insert(currentMessageID)
        }
        
        self.collectionView?.collectionViewLayout.removeSizeFromCache(forItemID: currentMessageID)
        self.collectionView?.performBatchUpdates(nil, completion: nil)
        
    }
    
    func chatCell(_ cell: QMChatCell!, didTapAtPosition position: CGPoint) {}
    
    func chatCell(_ cell: QMChatCell!, didPerformAction action: Selector!, withSender sender: Any!) {}
    
    func chatCell(_ cell: QMChatCell!, didTapOn result: NSTextCheckingResult) {
        
        switch result.resultType {
            
        case NSTextCheckingResult.CheckingType.link:
            
            let strUrl : String = (result.url?.absoluteString)!
            
            let hasPrefix = strUrl.lowercased().hasPrefix("https://") || strUrl.lowercased().hasPrefix("http://")
            
            if #available(iOS 9.0, *) {
                if hasPrefix {
                    
                    let controller = SFSafariViewController(url: NSURL(string: strUrl)! as URL)
                    self.present(controller, animated: true, completion: nil)
                    
                    break
                }
                
            }
            // Fallback on earlier versions
            
            if UIApplication.shared.canOpenURL(NSURL(string: strUrl)! as URL) {
                
                UIApplication.shared.openURL(NSURL(string: strUrl)! as URL)
            }
            
            break
            
        case NSTextCheckingResult.CheckingType.phoneNumber:
            
            if !self.canMakeACall() {
                
                SVProgressHUD.showInfo(withStatus: "Your Device can't make a phone call".localized, maskType: .none)
                break
            }
            
            let urlString = String(format: "tel:%@",result.phoneNumber!)
            let url = NSURL(string: urlString)
            
            self.view.endEditing(true)
            
            if #available(iOS 8.0, *) {
                
                let alertController = UIAlertController(title: "",
                                                        message: result.phoneNumber,
                                                        preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "SA_STR_CANCEL".localized, style: .cancel) { (action) in
                    
                }
                alertController.addAction(cancelAction)
                
                let openAction = UIAlertAction(title: "SA_STR_CALL".localized, style: .destructive) { (action) in
                    UIApplication.shared.openURL(url! as URL)
                }
                alertController.addAction(openAction)
                
                self.present(alertController, animated: true) {
                    
                }
                
            }
            else {
                
                // Fallback on earlier versions
                
                _ = AlertView(title:"" , message:result.phoneNumber , cancelButtonTitle: "SA_STR_CANCEL".localized, otherButtonTitle: ["SA_STR_CALL".localized,], didClick:{ (buttonIndex) -> Void in
                    
                    guard buttonIndex == 1 else {
                        return
                    }
                    UIApplication.shared.openURL(url! as URL)
                })
            }
            
            break
            
        default:
            break
            
        }
    }
    
    func chatCellDidTapAvatar(_ cell: QMChatCell!) {
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(_ chatService: QMChatService, didLoadMessagesFromCache messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            
            self.chatSectionManager.add(messages)
        }
    }
    
    func chatService(_ chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            // Insert message received from XMPP or self sent
            self.chatSectionManager.add(message)
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if self.dialog.type != QBChatDialogType.private && self.dialog.id == chatDialog.id {
            self.dialog = chatDialog
            self.title = self.dialog.name
        }
    }
    
    func chatService(_ chatService: QMChatService, didUpdate message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatSectionManager.update(message)
        }
        
    }
    
    func chatService(_ chatService: QMChatService, didUpdate messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.id == dialogID {
            self.chatSectionManager.update(messages)
        }
        
    }
    
    // MARK: UITextViewDelegate
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
    }
    
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Prevent crashing undo bug
        let currentCharacterCount = textView.text?.length ?? 0
        
        if (range.length + range.location > currentCharacterCount) {
            return false
        }
        
        if !QBChat.instance().isConnected { return true }
        
        if let timer = self.typingTimer {
            timer.invalidate()
            self.typingTimer = nil
            
        } else {
            
            self.sendBeginTyping()
        }
        
        self.typingTimer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(ChatViewController.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)
        
        if maxCharactersNumber > 0 {
            
            if currentCharacterCount >= maxCharactersNumber && text.length > 0 {
                
                self.showCharactersNumberError()
                return false
            }
            
            let newLength = currentCharacterCount + text.length - range.length
            
            if  newLength <= maxCharactersNumber || text.length == 0 {
                return true
            }
            
            let oldString = textView.text ?? ""
            
            let numberOfSymbolsToCut = maxCharactersNumber - oldString.length
            
            var stringRange = NSMakeRange(0, min(text.length, numberOfSymbolsToCut))
            
            
            // adjust the range to include dependent chars
            stringRange = (text as NSString).rangeOfComposedCharacterSequences(for: stringRange)
            
            // Now you can create the short string
            let shortString = (text as NSString).substring(with: stringRange)
            
            let newText = NSMutableString()
            newText.append(oldString)
            newText.insert(shortString, at: range.location)
            textView.text = newText as String
            
            self.showCharactersNumberError()
            
            self.textViewDidChange(textView)
            
            return false
        }
        
        return true
    }
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        
        super.textViewDidEndEditing(textView)
        
        self.fireSendStopTypingIfNecessary()
    }
    
    func fireSendStopTypingIfNecessary() -> Void {
        
        if let timer = self.typingTimer {
            
            timer.invalidate()
        }
        
        self.typingTimer = nil
        self.sendStopTyping()
    }
    
    func sendBeginTyping() -> Void {
        self.dialog.sendUserIsTyping()
    }
    
    func sendStopTyping() -> Void {
        
        self.dialog.sendUserStoppedTyping()
    }
    
    // MARK: QMChatAttachmentServiceDelegate
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChange status: QMMessageAttachmentStatus, for message: QBChatMessage) {
        
        if status != QMMessageAttachmentStatus.notLoaded {
            
            if message.dialogID == self.dialog.id {
                self.chatSectionManager.update(message)
            }
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeLoadingProgress progress: CGFloat, for attachment: QBChatAttachment) {
        
        if let attachmentCell = self.attachmentCellsMap.object(forKey: attachment.id! as AnyObject?) {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    func chatAttachmentService(_ chatAttachmentService: QMChatAttachmentService, didChangeUploadingProgress progress: CGFloat, for message: QBChatMessage) {
        
        guard message.dialogID == self.dialog.id else {
            return
        }
        var cell = self.attachmentCellsMap.object(forKey: message.id as AnyObject?)
        
        if cell == nil && progress < 1.0 {
            
            let indexPath = self.chatSectionManager.indexPath(for: message)
            
            cell = self.collectionView?.cellForItem(at: indexPath!) as? QMChatAttachmentCell
            self.attachmentCellsMap.setObject(cell, forKey: message.id as AnyObject?)
        }
        
        cell?.updateLoadingProgress(progress)
        
    }
    
    // MARK : QMChatConnectionDelegate
    
    func refreshAndReadMessages() {
        
        SVProgressHUD.show(withStatus: "SA_STR_LOADING_MESSAGES".localized, maskType: SVProgressHUDMaskType.clear)
        self.loadMessages()
        
        if let messagesToRead = self.unreadMessages {
            self.readMessages(messages: messagesToRead)
        }
        
        self.unreadMessages = nil
    }
    
    func chatServiceChatDidConnect(_ chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
    
    func chatServiceChatDidReconnect(_ chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
}
