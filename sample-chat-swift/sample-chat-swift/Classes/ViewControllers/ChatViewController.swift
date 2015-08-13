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

class ChatViewController: QMChatViewController, QMChatServiceDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate {
    
    var dialog: QBChatDialog?
    var shouldFixViewControllersStack = false
    var didBecomeActiveHandler : AnyObject?
    var didEnterBackgroundHandler : AnyObject?
    var attachmentCellsMap : [String : QMChatAttachmentCell] = [String : QMChatAttachmentCell]()
    
    var typingTimer : NSTimer?
    
    var shouldHoldScrolOnCollectionView = false
    
    lazy var imagePickerViewController : UIImagePickerController = {
            let imagePickerViewController = UIImagePickerController()
            imagePickerViewController.delegate = self
            
            return imagePickerViewController
    }()
    
    var unreadMessages: [QBChatMessage]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakSelf = self
        
        self.dialog?.onUserIsTyping = { (UInt userID)-> Void in
            
            if ServicesManager.instance().currentUser().ID == userID {
                return
            }
            
            weakSelf?.title = "SA_STR_TYPING".localized
        }
        
        self.dialog?.onUserStoppedTyping = { (UInt userID)-> Void in
            
            if ServicesManager.instance().currentUser().ID == userID {
                return
            }
            
            weakSelf?.updateTitle()
        }
        
        self.items = NSMutableArray()
        
        self.collectionView.typingIndicatorMessageBubbleColor = UIColor.redColor()
                
        self.senderID = ServicesManager.instance().currentUser().ID
        self.senderDisplayName = ServicesManager.instance().currentUser().login
        
        self.showLoadEarlierMessagesHeader = true
        
        self.updateTitle()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().chatService.chatAttachmentService.delegate = self
        
        self.updateMessages()
        
        weak var weakSelf = self
        
        self.didBecomeActiveHandler = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillEnterForegroundNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
    
            weakSelf?.updateMessages()
            
        }
        
        self.didEnterBackgroundHandler = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification: NSNotification!) -> Void in
            
            weakSelf?.fireSendStopTypingIfNecessary()
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
            ServicesManager.instance().currentDialogID = dialog.ID
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
            if let recepeint = ServicesManager.instance().usersService.user(UInt(self.dialog!.recipientID)) {
                self.title = recepeint.login
            }
        }
    }
    
    func updateMessages() {
        
        var isProgressHUDShowed = false
        
        if self.items.count == 0 {
            isProgressHUDShowed = true
            SVProgressHUD.showWithStatus("SA_STR_LOADING_MESSAGES".localized, maskType: SVProgressHUDMaskType.Clear)
        }
        
        weak var weakSelf = self
        
        // Retrieving messages for chat dialog ID.
        ServicesManager.instance().chatService.messagesWithChatDialogID(self.dialog?.ID, completion: { (response: QBResponse!, messages: [AnyObject]!) -> Void in
            
            if response.error == nil {
                
                weakSelf?.scrollToBottomAnimated(false)
                
                if isProgressHUDShowed {
                    SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                }
                
            } else {
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
            }
            
        })
    }
    
    func refreshCollectionView() {
        self.collectionView.reloadData()
        self.scrollToBottomAnimated(false)
    }
    
    static func sendReadStatusForMessage(message: QBChatMessage) {
        if message.senderID != QBSession.currentSession().currentUser.ID && (message.readIDs == nil || !contains(message.readIDs as! [Int], Int(QBSession.currentSession().currentUser.ID))) {
            
            message.markable = true
            // Sending read status for message.
            if !QBChat.instance().readMessage(message) {
                NSLog("Problems while marking message as read!")
            }
        }
    }
    
    func readMessages(messages: [QBChatMessage], dialogID: String) {
        
        if QBChat.instance().isLoggedIn() {
            for message in messages {
                ChatViewController.sendReadStatusForMessage(message)
            }
        } else {
            self.unreadMessages = messages
        }
        
        var messageIDs = [String]()
        
        for message in messages {
            messageIDs.append(message.ID)
        }
        
        // Marking message as read for REST API history.
        QBRequest.markMessagesAsRead(Set(messageIDs), dialogID: dialogID, successBlock: { (response: QBResponse!) -> Void in
            
            }) { (response: QBResponse!) -> Void in
            
        }
        
    }

    // MARK: Actions
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
        
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text;
        message.senderID = self.senderID

        self.sendMessage(message)
    }
    
    func sendMessage(message: QBChatMessage) {
        
        // Sending message.
        let didSent = ServicesManager.instance().chatService.sendMessage(message, toDialogId: self.dialog?.ID, save: true) { (error:NSError!) -> Void in
        }
        
        if !didSent {
            TWMessageBarManager.sharedInstance().showMessageWithTitle("SA_STR_ERROR".localized, description: "SA_STR_CANT_SEND_A_MESSAGE".localized, type: TWMessageBarMessageType.Info)
        }
        
        self.finishSendingMessageAnimated(true)
        
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        let actionSheet = UIActionSheet(title: "Image source type", delegate: self, cancelButtonTitle:nil, destructiveButtonTitle: nil, otherButtonTitles: "Camera", "Camera Roll", "Cancel")
    
        actionSheet.showFromToolbar(self.inputToolbar)
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
                    let user = ServicesManager.instance().usersService.user(UInt(readID))
                    
                    if user != nil {
                        readersLogin.append(user!.login)
                    } else {
                        readersLogin.append("Unknown")
                    }
                }
                statusString += "Read:" + ", ".join(readersLogin)
            }
        }
        
        if message.deliveredIDs != nil {
            var deliveredLogin = [String]()

            let messageDeliveredIDs = (message.deliveredIDs as! [Int]).filter { (element : Int) -> Bool in
                return element != currentUserID
            }
            
            if !messageDeliveredIDs.isEmpty {
                for deliveredID : Int in messageDeliveredIDs {
                    let user = ServicesManager.instance().usersService.user(UInt(deliveredID))
                    
                    if contains(readersLogin, user!.login) {
                        continue
                    }
                    
                    if user != nil {
                        deliveredLogin.append(user!.login)
                    } else {
                        deliveredLogin.append("Unknown");
                    }
                }
                
                if readersLogin.count > 0 && deliveredLogin.count > 0 {
                    statusString += "\n"
                }
                
                if deliveredLogin.count > 0 {
                    statusString += "Delivered:" + " ,".join(deliveredLogin)
                }
            }
        }
        
        if statusString.isEmpty {
            statusString = "Sent"
        }
        
        return statusString
    }
    
    // MARK: Override
    
    override func viewClassForItem(item: QBChatMessage!) -> AnyClass! {
        
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
                
                if (item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatus.NotLoaded {
                    
                    return QMChatAttachmentIncomingCell.self
                    
                } else {
                    
                    return QMChatIncomingCell.self
                }
                
            } else {
                
                if (item.attachments != nil && item.attachments.count > 0) || item.attachmentStatus != QMMessageAttachmentStatus.NotLoaded {
                    
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
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.whiteColor() : UIColor(white: 0.29, alpha: 1)
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 15)
        
        let attributedString = NSAttributedString(string: messageItem.text, attributes: attributes)
        
        return attributedString
    }
    
    
    override func topLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString? {

        if messageItem.senderID == self.senderID || self.dialog?.type == QBChatDialogType.Private {
            return nil
        }
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor(red: 0.184, green: 0.467, blue: 0.733, alpha: 1)
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 14)
        
        var topLabelAttributedString : NSAttributedString?
        
        if let topLabelText = ServicesManager.instance().usersService.user(messageItem.senderID)?.login {
            topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        }
        
        return topLabelAttributedString
    }
    
    override func bottomLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        let textColor = messageItem.senderID == self.senderID ? UIColor(white: 1, alpha: 0.51) : UIColor(white: 0, alpha: 0.49)
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 12)
        
        var text = messageTimeDateFormatter.stringFromDate(messageItem.dateSent)
        
        if messageItem.senderID == self.senderID {
            text = text + " " + ChatViewController.statusStringFromMessage(messageItem)
        }
        
        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(collectionView: QMChatCollectionView!, dynamicSizeAtIndexPath indexPath: NSIndexPath!, maxWidth: CGFloat) -> CGSize {
        
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        var size = CGSizeZero
        
        if self.viewClassForItem(item) === QMChatAttachmentOutgoingCell.self || self.viewClassForItem(item) === QMChatAttachmentIncomingCell.self {
            
            size = CGSize(width: min(200, maxWidth), height: 200)
            
        } else {
            
            let attributedString = self.attributedStringForItem(item)
            size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.max), limitedToNumberOfLines: 0)
        }
        
        return size
    }
    
     override func collectionView(collectionView: QMChatCollectionView!, minWidthAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        
        var attributedString : NSAttributedString
        
        if item.senderID == self.senderID {
            attributedString = self.bottomLabelAttributedStringForItem(item) ?? self.topLabelAttributedStringForItem(item)
        } else {
            attributedString = self.topLabelAttributedStringForItem(item) ?? self.bottomLabelAttributedStringForItem(item)
        }
        
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: 1000, height: 1000), limitedToNumberOfLines:1)
        
        return size.width
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, header headerView: QMLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton) {
    
        weak var weakSelf = self
        self.shouldHoldScrolOnCollectionView = true
        
        SVProgressHUD.showWithStatus("SA_STR_LOADING_MESSAGES".localized, maskType: SVProgressHUDMaskType.Clear)
        
        // Retrieving earlier messages from Quickblox.
        ServicesManager.instance().chatService.earlierMessagesWithChatDialogID(self.dialog?.ID, completion: { (response: QBResponse!, messages:[AnyObject]!) -> Void in
            
            weakSelf?.shouldHoldScrolOnCollectionView = false
            
            if messages != nil {
                weakSelf?.showLoadEarlierMessagesHeader = messages.count == Int(kQMChatMessagesPerPage)
            }
            
            if response?.error != nil {
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
            } else {
                SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
            }
            
        })
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, layoutModelAtIndexPath indexPath: NSIndexPath!) -> QMChatCellLayoutModel {
        var layoutModel : QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAtIndexPath: indexPath)
        
        if self.dialog?.type == QBChatDialogType.Private {
            layoutModel.topLabelHeight = 0.0
        }
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass
        
        if QMChatOutgoingCell.isKindOfClass(viewClass) {
            let bottomAttributedString = self.bottomLabelAttributedStringForItem(item)
            let rect = bottomAttributedString.boundingRectWithSize(CGSize(width: CGRectGetWidth(collectionView.frame), height: CGFloat.max),
                options: NSStringDrawingOptions.UsesLineFragmentOrigin | NSStringDrawingOptions.UsesFontLeading,
                context: nil)
            layoutModel.bottomLabelHeight = ceil(CGRectGetHeight(rect))
        }
        
        return layoutModel
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, configureCell cell: UICollectionViewCell!, forIndexPath indexPath: NSIndexPath!) {
        
        super.collectionView(collectionView, configureCell: cell, forIndexPath: indexPath)
        
        if let attachmentCell = cell as? QMChatAttachmentCell {
            
            let message: QBChatMessage = self.items[indexPath.row] as! QBChatMessage;
            
            if let attachments = message.attachments {
                
                let attachment: QBChatAttachment = attachments.first as! QBChatAttachment
                var shouldLoadFile = true
                
                if self.attachmentCellsMap[attachment.ID] != nil {
                    shouldLoadFile = false
                }

                for (existingAttachmentID, existingAttachmentCell) in self.attachmentCellsMap {
                    
                    if existingAttachmentCell === attachmentCell  {
                        
                        if existingAttachmentID == attachment.ID {
                            continue
                        } else {
                            self.attachmentCellsMap.removeValueForKey(existingAttachmentID)
                        }
                    }
                    
                }
                
                self.attachmentCellsMap[attachment.ID] = attachmentCell
                attachmentCell.attachmentID = attachment.ID
                
                if !shouldLoadFile {
                    return
                }
                
                weak var weakSelf = self
                
                // Getting image from chat attachment cache.
                ServicesManager.instance().chatService.chatAttachmentService.getImageForChatAttachment(attachment, completion: { (error, image) -> Void in
                    
                    if attachmentCell.attachmentID != attachment.ID {
                        return
                    }
                    
                    weakSelf?.attachmentCellsMap.removeValueForKey(attachment.ID)
                    
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
        
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        
        if self.dialog?.ID == dialogID {
            self.items = NSMutableArray(array: chatService.messagesMemoryStorage.messagesWithDialogID(dialogID))
            self.refreshCollectionView()
            
            ChatViewController.sendReadStatusForMessage(message)
            // Marking message as read in REST history
            QBRequest.markMessagesAsRead(Set([message.ID]), dialogID: dialogID, successBlock: { (response: QBResponse!) -> Void in
                
                }, errorBlock: { (response: QBResponse!) -> Void in
                
            })
        }
    }
    
    func chatService(chatService: QMChatService!, didAddMessagesToMemoryStorage messages: [AnyObject]!, forDialogID dialogID: String!) {
        
        if self.dialog?.ID == dialogID {
            self.readMessages(messages as! [QBChatMessage], dialogID: dialogID)
            self.items = NSMutableArray(array: chatService.messagesMemoryStorage.messagesWithDialogID(dialogID))
            
            if (self.shouldHoldScrolOnCollectionView) {
                
                let bottomOffset = self.collectionView.contentSize.height - self.collectionView.contentOffset.y
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                /* Way for call reloadData sync */
                self.collectionView.reloadData()
                self.collectionView.performBatchUpdates(nil, completion: nil)

                self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentSize.height - bottomOffset)
                
                CATransaction.commit()

            } else {
                
                self.collectionView.reloadData()
            }
            
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
            
            self.items = NSMutableArray(array: chatService.messagesMemoryStorage.messagesWithDialogID(dialogID))
            
            let updatedMessageIndex = self.items.indexOfObject(message)
            
            if updatedMessageIndex != NSNotFound {
                let context = QMCollectionViewFlowLayoutInvalidationContext()
                context.invalidateFlowLayoutMessagesCache = true
                self.collectionView.collectionViewLayout.invalidateLayoutWithContext(context)
                self.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: updatedMessageIndex, inSection: 0)])
            }
            
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
    
    // MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 2 {
            return
        }
        
        if buttonIndex == 0 {
            self.imagePickerViewController.sourceType = UIImagePickerControllerSourceType.Camera
        } else if buttonIndex == 1 {
            self.imagePickerViewController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        weak var weakSelf = self
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            weakSelf?.presentViewController(self.imagePickerViewController, animated: true, completion: nil)
        })
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        SVProgressHUD.showWithStatus("SA_STR_UPLOADING_ATTACHMENT".localized, maskType: SVProgressHUDMaskType.Clear)
        
        weak var weakSelf = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            var image : UIImage = info[UIImagePickerControllerOriginalImage as NSObject] as! UIImage
            
            if picker.sourceType == UIImagePickerControllerSourceType.Camera {
                image = image.fixOrientation()
            }
            
            let largestSide = image.size.width > image.size.height ? image.size.width : image.size.height
            let scaleCoeficient = largestSide/560.0
            let newSize = CGSize(width: image.size.width/scaleCoeficient, height: image.size.height/scaleCoeficient)
            
            // create smaller image
            
            UIGraphicsBeginImageContext(newSize)
            
            image.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            let message = QBChatMessage()
            message.senderID = ServicesManager.instance().currentUser().ID
            message.dialogID = weakSelf?.dialog?.ID
            
            // Sending attachment.
            ServicesManager.instance().chatService.chatAttachmentService.sendMessage(message, toDialog: weakSelf?.dialog, withChatService: ServicesManager.instance().chatService, withAttachedImage: resizedImage, completion: { (error: NSError!) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error != nil {
                        SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
                    } else {
                        SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                    }
                })
            })
            
        })
    }
    
    // MARK: QMChatAttachmentServiceDelegate
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService!, didChangeAttachmentStatus status: QMMessageAttachmentStatus, forMessage message: QBChatMessage!) {
        
        if message.dialogID == self.dialog?.ID {
            // Messages from memory storage.
            self.items = NSMutableArray(array: ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(self.dialog?.ID))
            self.refreshCollectionView()
        }
    }
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService!, didChangeLoadingProgress progress: CGFloat, forChatAttachment attachment: QBChatAttachment!) {
        
        if let attachmentCell = self.attachmentCellsMap[attachment.ID] {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    // MARK : QMChatConnectionDelegate
    
    func chatServiceChatDidLogin() {
        
        if let unreadMessages = self.unreadMessages {
            
            for message in unreadMessages {
                ChatViewController.sendReadStatusForMessage(message)
            }
            
            self.unreadMessages = nil
        }
        
    }
}
