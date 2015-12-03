//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

var messageTimeDateFormatter: NSDateFormatter {
    struct Static {
        static let instance : NSDateFormatter = {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter
            }()
    }
    
    return Static.instance
}

class ChatViewController: QMChatViewController, QMChatServiceDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate {
    
    var dialog: QBChatDialog?
    var shouldFixViewControllersStack = false
    var didBecomeActiveHandler : AnyObject?
    var didEnterBackgroundHandler : AnyObject?
    var attachmentCellsMap : [String : QMChatAttachmentCell] = [String : QMChatAttachmentCell]()
    var isSendingAttachment: Bool = false
    
    var typingTimer : NSTimer?
    
    var popoverController : UIPopoverController?
    
    lazy var imagePickerViewController : UIImagePickerController = {
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            
            return imagePickerViewController
    }()
    
    var unreadMessages: [QBChatMessage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dialog?.onUserIsTyping = {
            [weak self] (UInt userID)-> Void in
            
            if ServicesManager.instance().currentUser().ID == userID {
                return
            }
            
            self!.title = "SA_STR_TYPING".localized
        }
        
        self.dialog?.onUserStoppedTyping = {
            [weak self] (UInt userID)-> Void in
            
            if ServicesManager.instance().currentUser().ID == userID {
                return
            }
            
            self!.updateTitle()
        }
                
        self.senderID = ServicesManager.instance().currentUser().ID
        self.senderDisplayName = ServicesManager.instance().currentUser().login
        self.timeIntervalBetweenSections = 300.0
        self.heightForSectionHeader = 40.0
        
        self.updateTitle()
        
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.inputToolbar?.contentView?.backgroundColor = UIColor.whiteColor()
        self.inputToolbar?.contentView?.textView?.placeHolder = "Message"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().chatService.chatAttachmentService.delegate = self
        
        self.updateMessages()
        
        self.didBecomeActiveHandler = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            
        }
        
        self.didEnterBackgroundHandler = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [weak self] (notification: NSNotification!) -> Void in
            
            self!.fireSendStopTypingIfNecessary()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.shouldFixViewControllersStack {
            
            var viewControllers: [UIViewController] = []
            
            if let loginViewControllers = self.navigationController?.viewControllers[0] as? LoginTableViewController {
                viewControllers.append(loginViewControllers)
            }
            
            if let dialogsViewControllers = self.navigationController?.viewControllers[1] as? DialogsViewController {
                viewControllers.append(dialogsViewControllers)
            }
            
            if let chatViewControllers = self.navigationController?.viewControllers.last as? ChatViewController {
                viewControllers.append(chatViewControllers)
            }
            
            self.navigationController?.viewControllers = viewControllers
            
            self.shouldFixViewControllersStack = false
        }
        
        if let dialog = self.dialog {
            // Saving current dialog ID.
            ServicesManager.instance().currentDialogID = dialog.ID!
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let didBecomeActiveHandler: AnyObject = self.didBecomeActiveHandler {
            NSNotificationCenter.defaultCenter().removeObserver(didBecomeActiveHandler)
        }
        
        if let didEnterBackgroundHandler: AnyObject = self.didEnterBackgroundHandler {
            NSNotificationCenter.defaultCenter().removeObserver(didEnterBackgroundHandler)
        }
        
        // Resetting current dialog ID.
        ServicesManager.instance().currentDialogID = ""
        
        ServicesManager.instance().chatService.removeDelegate(self);
        self.dialog?.clearTypingStatusBlocks()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatInfoViewController = segue.destinationViewController as? ChatUsersInfoTableViewController {
            chatInfoViewController.dialog = self.dialog
        }
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Update
    
    func updateTitle() {
        if self.dialog?.type != QBChatDialogType.Private {
            self.title = self.dialog?.name
        } else {
            if let recepeint = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(self.dialog!.recipientID)) {
                self.title = recepeint.login
            }
        }
    }
    
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(self.dialog?.ID) as! [QBChatMessage]?
    }
    
    func loadMessages() {
        // Retrieving messages for chat dialog ID.
        ServicesManager.instance().chatService.messagesWithChatDialogID(self.dialog?.ID, completion: {
            [unowned self] (response: QBResponse!, messages: [AnyObject]!) -> Void in
            
            if response.error == nil {
                if (messages.count > 0) {
                    self.insertMessagesToTheBottomAnimated(messages as! [QBChatMessage]!)
                }
                if (!self.isSendingAttachment) {
                    SVProgressHUD.dismiss()
                }
                
            } else {
                SVProgressHUD.showErrorWithStatus(response.error?.error?.localizedDescription)
            }
            
        })
    }
    
    func updateMessages() {
        
        // Retrieving messages
        if (self.storedMessages()?.count > 0) {
            self.insertMessagesToTheBottomAnimated(self.storedMessages()!)
            self.loadMessages()
        } else {
            SVProgressHUD.showWithStatus("SA_STR_LOADING_MESSAGES".localized, maskType: SVProgressHUDMaskType.Clear)
            
            ServicesManager.instance().cachedMessagesWithDialogID(self.dialog?.ID, block: {
                [unowned self] (collection: [AnyObject]!) -> Void in
                if (collection.count > 0) {
                    self.insertMessagesToTheBottomAnimated(collection as! [QBChatMessage])
                }
                self.loadMessages()
            })
        }
    }
    
    func sendReadStatusForMessage(message: QBChatMessage) {
        if message.senderID != QBSession.currentSession().currentUser!.ID && (message.readIDs == nil || !(message.readIDs as! [Int]).contains(Int(QBSession.currentSession().currentUser!.ID))) {
            ServicesManager.instance().chatService.readMessage(message, completion: { (error: NSError?) -> Void in
                //
                if (error != nil) {
                    NSLog("Problems while marking message as read! Error: %@", error!)
                }
                else {
                    if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
                        UIApplication.sharedApplication().applicationIconBadgeNumber--
                    }
                }
            })
        }
    }
    
    func readMessages(messages: [QBChatMessage]) {
        
        if QBChat.instance().isConnected() {
            ServicesManager.instance().chatService.readMessages(messages, forDialogID: self.dialog?.ID, completion: nil)
        } else {
            self.unreadMessages = messages
        }
        
        var messageIDs = [String]()
        
        for message in messages {
            messageIDs.append(message.ID!)
        }
    }

    // MARK: Actions
    
    override func didPickAttachmentImage(image: UIImage!) {
        SVProgressHUD.showWithStatus("SA_STR_UPLOADING_ATTACHMENT".localized, maskType: SVProgressHUDMaskType.Clear)
        self.isSendingAttachment = true
        
        let message = QBChatMessage()
        message.senderID = ServicesManager.instance().currentUser().ID
        message.dialogID = self.dialog?.ID
        message.dateSent = NSDate()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            [unowned self] () -> Void in
            var newImage : UIImage! = image
            if self.imagePickerViewController.sourceType == UIImagePickerControllerSourceType.Camera {
                newImage = newImage.fixOrientation()
            }
            
            let largestSide = newImage.size.width > newImage.size.height ? newImage.size.width : newImage.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: newImage.size.width/scaleCoeficient, height: newImage.size.height/scaleCoeficient)
            
            // create smaller image
            
            UIGraphicsBeginImageContext(newSize)
            
            newImage.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // Sending attachment.
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                ServicesManager.instance().chatService.sendAttachmentMessage(message, toDialog: self.dialog, withAttachmentImage: resizedImage, completion: {
                    [weak self] (error: NSError?) -> Void in
                    if error != nil {
                        SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
                    } else {
                        SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                    }
                    self?.isSendingAttachment = false
                })
            })
        })

    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
        
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text;
        message.senderID = self.senderID
        message.deliveredIDs = [(self.senderID)];
        message.readIDs = [(self.senderID)];
        message.markable = true
        message.dateSent = date
        
        self.sendMessage(message)
    }
    
    func sendMessage(message: QBChatMessage) {
        
        // Sending message.
        ServicesManager.instance().chatService.sendMessage(message, toDialogID: self.dialog?.ID, saveToHistory: true, saveToStorage: true) { (error: NSError?) -> Void in
            //
            if (error != nil) {
                TWMessageBarManager.sharedInstance().showMessageWithTitle("SA_STR_ERROR".localized, description: error?.localizedRecoverySuggestion, type: TWMessageBarMessageType.Info)
            } else {
                self.insertMessageToTheBottomAnimated(message)
            }
        }
        
        self.finishSendingMessageAnimated(true)
    }
    
    // MARK: Helper
    
    static func statusStringFromMessage(message: QBChatMessage) -> String {
        var statusString : String = ""
        
        let currentUserID = Int(ServicesManager.instance().currentUser().ID)
        
        var readersLogin = [String]()
        
        if message.readIDs != nil {
            let messageReadIDs = (message.readIDs as! [Int]).filter { (element : Int) -> Bool in
                return element != currentUserID
            }
            
            if !messageReadIDs.isEmpty {
                for readID : Int in messageReadIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(readID))
                    
                    if user != nil {
                        readersLogin.append(user!.login!)
                    } else {
                        readersLogin.append("Unknown")
                    }
                }
                if message.attachments?.count > 0 {
                    statusString += "Seen:" + readersLogin.joinWithSeparator(", ")
                } else {
                    statusString += "Read:" + readersLogin.joinWithSeparator(", ")
                }

            }
        }
        
        if message.deliveredIDs != nil {
            var deliveredLogin = [String]()

            let messageDeliveredIDs = (message.deliveredIDs as! [Int]).filter { (element : Int) -> Bool in
                return element != currentUserID
            }
            
            if !messageDeliveredIDs.isEmpty {
                for deliveredID : Int in messageDeliveredIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(deliveredID))
                    
                    if readersLogin.contains(user!.login!) {
                        continue
                    }
                    
                    if user != nil {
                        deliveredLogin.append(user!.login!)
                    } else {
                        deliveredLogin.append("Unknown");
                    }
                }
                
                if readersLogin.count > 0 && deliveredLogin.count > 0 {
                    statusString += "\n"
                }
                
                if deliveredLogin.count > 0 {
                    statusString += "Delivered:" + deliveredLogin.joinWithSeparator(", ")
                }
            }
        }
        
        if statusString.isEmpty {
            statusString = "Sent"
        }
        
        return statusString
    }
    
    // MARK: Override
    
    override func viewClassForItem(item: QBChatMessage) -> AnyClass! {
        
        if item.senderID == QMMessageType.ContactRequest.rawValue {
            
            if item.senderID != self.senderID {
                
                return QMChatContactRequestCell.self
            }
            
        } else if item.senderID == QMMessageType.RejectContactRequest.rawValue {
            
            return QMChatNotificationCell.self
            
        } else if item.senderID == QMMessageType.AcceptContactRequest.rawValue {
            
            return QMChatNotificationCell.self
            
        } else {
            
            if (item.senderID != self.senderID) {
                
                if (item.attachments != nil && item.attachments!.count > 0) || item.attachmentStatus != QMMessageAttachmentStatus.NotLoaded {
                    
                    return QMChatAttachmentIncomingCell.self
                    
                } else {
                    
                    return QMChatIncomingCell.self
                }
                
            } else {
                
                if (item.attachments != nil && item.attachments!.count > 0) || item.attachmentStatus != QMMessageAttachmentStatus.NotLoaded {
                    
                    return QMChatAttachmentOutgoingCell.self
                    
                } else {
                    
                    return QMChatOutgoingCell.self
                }
                
            }
        }
        
        return nil
    }
    
    // MARK: Strings builder
    
    override func attributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        if messageItem.text == nil {
            return nil
        }
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.whiteColor() : UIColor.blackColor()
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 17)
        
        let attributedString = NSAttributedString(string: messageItem.text!, attributes: attributes)
        
        return attributedString
    }
    
    
    override func topLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString? {

        if messageItem.senderID == self.senderID || self.dialog?.type == QBChatDialogType.Private {
            return nil
        }
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 17)
        
        var topLabelAttributedString : NSAttributedString?
        
        if let topLabelText = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(messageItem.senderID)?.login {
            topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        }
        
        return topLabelAttributedString
    }
    
    override func bottomLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.whiteColor() : UIColor.blackColor()
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 13)
        
        var text = messageItem.dateSent != nil ? messageTimeDateFormatter.stringFromDate(messageItem.dateSent!) : ""
        
        if messageItem.senderID == self.senderID {
            text = text + "\n" + ChatViewController.statusStringFromMessage(messageItem)
        }
        
        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(collectionView: QMChatCollectionView!, dynamicSizeAtIndexPath indexPath: NSIndexPath!, maxWidth: CGFloat) -> CGSize {
        
        var size = CGSizeZero
        
        if let item : QBChatMessage = self.messageForIndexPath(indexPath) {
            if self.viewClassForItem(item) === QMChatAttachmentIncomingCell.self {
                size = CGSize(width: min(200, maxWidth), height: 200)
            } else if self.viewClassForItem(item) === QMChatAttachmentOutgoingCell.self {
                let attributedString = self.bottomLabelAttributedStringForItem(item)
                
                let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: min(200, maxWidth), height: CGFloat.max), limitedToNumberOfLines: 0)
                size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
            } else {
                let attributedString = self.attributedStringForItem(item)
                
                size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.max), limitedToNumberOfLines: 0)
            }
        }
        
        return size
    }
    
     override func collectionView(collectionView: QMChatCollectionView!, minWidthAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        
        var attributedString : NSAttributedString = NSAttributedString()
        
        if let item : QBChatMessage = self.messageForIndexPath(indexPath) {
            if item.senderID == self.senderID {
                attributedString = self.bottomLabelAttributedStringForItem(item) ?? self.topLabelAttributedStringForItem(item)
            } else {
                attributedString = self.topLabelAttributedStringForItem(item) ?? self.bottomLabelAttributedStringForItem(item)
            }
        }

        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: CGRectGetWidth(collectionView.frame) - kMessageContainerWidthPadding, height: CGFloat.max), limitedToNumberOfLines:0)
        
        return size.width
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, layoutModelAtIndexPath indexPath: NSIndexPath!) -> QMChatCellLayoutModel {
        var layoutModel : QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAtIndexPath: indexPath)
        
        if self.dialog?.type == QBChatDialogType.Private {
            layoutModel.topLabelHeight = 0.0
        }
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5;
        
        if let item : QBChatMessage = self.messageForIndexPath(indexPath) {
            let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass
            
            if viewClass === QMChatOutgoingCell.self || viewClass === QMChatAttachmentOutgoingCell.self {
                let bottomAttributedString = self.bottomLabelAttributedStringForItem(item)
                let size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: CGRectGetWidth(collectionView.frame) - kMessageContainerWidthPadding, height: CGFloat.max), limitedToNumberOfLines:0)
                layoutModel.bottomLabelHeight = ceil(size.height)
            } else {
                
                layoutModel.spaceBetweenTopLabelAndTextView = 5;
            }
        }

        return layoutModel
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, configureCell cell: UICollectionViewCell!, forIndexPath indexPath: NSIndexPath!) {
        
        super.collectionView(collectionView, configureCell: cell, forIndexPath: indexPath)
        
        if let attachmentCell = cell as? QMChatAttachmentCell {
            
            if attachmentCell.isKindOfClass(QMChatAttachmentIncomingCell.self) {
                (cell as! QMChatCell).containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
            } else if attachmentCell.isKindOfClass(QMChatAttachmentOutgoingCell.self) {
                (cell as! QMChatCell).containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
            
            let message: QBChatMessage = self.messageForIndexPath(indexPath)
            
            if let attachments = message.attachments {
                
                if let attachment: QBChatAttachment = attachments.first {
                    for (existingAttachmentID, existingAttachmentCell) in self.attachmentCellsMap {
                        
                        if existingAttachmentCell === attachmentCell  {
                            
                            if existingAttachmentID == attachment.ID {
                                continue
                            } else {
                                self.attachmentCellsMap.removeValueForKey(existingAttachmentID)
                            }
                        }
                        
                    }
                    
                    self.attachmentCellsMap[attachment.ID!] = attachmentCell
                    attachmentCell.attachmentID = attachment.ID
                    
                    // Getting image from chat attachment cache.
                    ServicesManager.instance().chatService.chatAttachmentService.getImageForAttachmentMessage(message, completion: {
                        [weak self] (error: NSError!, image: UIImage!) -> Void in
                        //
                        if attachmentCell.attachmentID != attachment.ID {
                            return
                        }
                        
                        self!.attachmentCellsMap.removeValueForKey(attachment.ID!)
                        
                        if error != nil {
                            SVProgressHUD.showErrorWithStatus(error.localizedDescription)
                        } else {
                            
                            if image != nil {
                                
                                attachmentCell.setAttachmentImage(image)
                                cell.updateConstraints()
                            }
                            
                        }
                    })
                }
            }
        } else if cell.isKindOfClass(QMChatIncomingCell.self) || cell.isKindOfClass(QMChatAttachmentIncomingCell.self) {
            (cell as! QMChatCell).containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        } else if cell.isKindOfClass(QMChatOutgoingCell.self) || cell.isKindOfClass(QMChatAttachmentOutgoingCell.self) {
            (cell as! QMChatCell).containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) -> Bool {
        let item : QBChatMessage = self.messageForIndexPath(indexPath)
        let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass
        
        if viewClass === QMChatAttachmentIncomingCell.self || viewClass === QMChatAttachmentOutgoingCell.self {
            return false
        }
        
        return super.collectionView(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if action == Selector("copy:") {
            let item : QBChatMessage = self.messageForIndexPath(indexPath)
            let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass

            if viewClass === QMChatAttachmentIncomingCell.self || viewClass === QMChatAttachmentOutgoingCell.self {
                return
            }
            
            UIPasteboard.generalPasteboard().string = item.text
        }
    }
    
    override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //
        let lastSection = (self.collectionView?.numberOfSections())! - 1
        if (indexPath.section == lastSection && indexPath.item == (self.collectionView?.numberOfItemsInSection(lastSection))! - 1) {
            // the very first message
            // load more if exists
            // Getting earlier messages for chat dialog identifier.
            ServicesManager.instance().chatService?.loadEarlierMessagesWithChatDialogID(self.dialog?.ID).continueWithBlock({
                [weak self] (task: BFTask!) -> AnyObject! in
                
                if (task.result.count > 0) {
                    self!.insertMessagesToTheTopAnimated(task.result as! [QBChatMessage]!)
                }
                
                return nil
            })
        }
        
        // marking message as read if needed
        if let message = self.messageForIndexPath(indexPath) {
            self.sendReadStatusForMessage(message)
        }
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        
        if self.dialog?.ID == dialogID {
            self.insertMessageToTheBottomAnimated(message)
        }
    }
    
    func chatService(chatService: QMChatService!, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog!) {
        
        if self.dialog?.ID == chatDialog.ID {
            self.dialog = chatDialog
            self.updateTitle()
        }
    }
    
    func chatService(chatService: QMChatService!, didUpdateMessage message: QBChatMessage!, forDialogID dialogID: String!) {
        
        if self.dialog?.ID == dialogID {
            self.updateMessage(message)
        }
        
    }
    
    // MARK: UITextViewDelegate
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if let timer = self.typingTimer {
            timer.invalidate()
            self.typingTimer = nil
            
        } else {
            
            self.sendBeginTyping()
        }
        
        self.typingTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: Selector("fireSendStopTypingIfNecessary"), userInfo: nil, repeats: false)
        
        return true
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        
        super.textViewDidEndEditing(textView)
        
        self.fireSendStopTypingIfNecessary()
    }
    
    func fireSendStopTypingIfNecessary() -> Void {
        
        if let timer = self.typingTimer {
            timer.invalidate()
            self.typingTimer = nil
            self.sendStopTyping()
        }
        
    }
    
    func sendBeginTyping() -> Void {
        
        if let dialog = self.dialog {
            dialog.sendUserIsTyping()
        }
        
    }
    
    func sendStopTyping() -> Void {
        
        if let dialog = self.dialog {
            dialog.sendUserStoppedTyping()
        }
        
    }
    
    // MARK: QMChatAttachmentServiceDelegate
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService!, didChangeAttachmentStatus status: QMMessageAttachmentStatus, forMessage message: QBChatMessage!) {
        
        if message.dialogID == self.dialog?.ID {
            
            self.updateMessage(message)
        }
    }
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService!, didChangeLoadingProgress progress: CGFloat, forChatAttachment attachment: QBChatAttachment!) {
        
        if let attachmentCell = self.attachmentCellsMap[attachment.ID!] {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    // MARK : QMChatConnectionDelegate
    
    func refreshAndReadMessages() {
        SVProgressHUD.showWithStatus("SA_STR_LOADING_MESSAGES".localized, maskType: SVProgressHUDMaskType.Clear)
        self.loadMessages()
        
        self.readMessages(self.unreadMessages!)
        self.unreadMessages = nil
    }
    
    func chatServiceChatDidConnect(chatService: QMChatService!) {
        //
        self.refreshAndReadMessages()
    }
    
    func chatServiceChatDidReconnect(chatService: QMChatService!) {
        //
        self.refreshAndReadMessages()
    }
}
