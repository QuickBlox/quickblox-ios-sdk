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
    
    var typingTimer : NSTimer?
    
    var shouldHoldScrolOnCollectionView = false
    var popoverController : UIPopoverController?
    
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
        
        self.collectionView?.typingIndicatorMessageBubbleColor = UIColor.redColor()
                
        self.senderID = ServicesManager.instance().currentUser().ID
        self.senderDisplayName = ServicesManager.instance().currentUser().login
        
        self.showLoadEarlierMessagesHeader = true
        
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
        
        weak var weakSelf = self
        
        self.didBecomeActiveHandler = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification) -> Void in
            
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
            if let recepeint = ServicesManager.instance().usersService.user(UInt(self.dialog!.recipientID)) {
                self.title = recepeint.login
            }
        }
    }
    
    func updateMessages() {
        var isProgressHUDShowed = false
        
        if self.items.count > 0 {
            if self.dialog?.type != QBChatDialogType.Private {
                isProgressHUDShowed = true
            }
            else {
                isProgressHUDShowed = false
            }
        }
        else {
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
                SVProgressHUD.showErrorWithStatus(response.error?.error?.localizedDescription)
            }
            
        })
    }
    
    func refreshCollectionView() {
        self.collectionView?.reloadData()
        self.scrollToBottomAnimated(false)
    }
    
    static func sendReadStatusForMessage(message: QBChatMessage, dialogID: String!) {
        if message.senderID != QBSession.currentSession().currentUser!.ID && (message.readIDs == nil || !(message.readIDs as! [Int]).contains(Int(QBSession.currentSession().currentUser!.ID))) {
            if !ServicesManager.instance().chatService.readMessage(message, forDialogID: dialogID) {
                NSLog("Problems while marking message as read!")
            }
            else {
                if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
                    UIApplication.sharedApplication().applicationIconBadgeNumber--
                }
            }
        }
    }
    
    func readMessages(messages: [QBChatMessage], dialogID: String) {
        
        if QBChat.instance().isConnected() {
            ServicesManager.instance().chatService.readMessages(messages, forDialogID: dialogID)
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
        
        weak var weakSelf = self
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            var newImage : UIImage! = image
            if weakSelf!.imagePickerViewController.sourceType == UIImagePickerControllerSourceType.Camera {
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
            
            let message = QBChatMessage()
            message.senderID = ServicesManager.instance().currentUser().ID
            message.dialogID = weakSelf?.dialog?.ID
            message.dateSent = NSDate()
            
            // Sending attachment.
            ServicesManager.instance().chatService.chatAttachmentService.sendMessage(message, toDialog: weakSelf?.dialog, withChatService: ServicesManager.instance().chatService, withAttachedImage: resizedImage, completion: { (error: NSError!) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if error != nil {
                        SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
                    } else {
                        SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                        // Custom push sending (uncomment sendPushWithAttachment method and line below)
//                        weakSelf?.sendPushWithAttachment()
                    }
                })
            })
        })

    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
        
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text;
        message.senderID = self.senderID
        message.markable = true
        message.dateSent = date
        
        self.sendMessage(message)
        
//        // Custom push sending (uncomment sendPushWithText method and line below)
//        self.sendPushWithText(text)
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
    
    /**
    *  If you want to send custom push notifications.
    *  uncomment methods bellow.
    *  By default push messages are disabled in admin panel.
    *  (you can change settings in admin panel -> Chat -> Alert)
    */
    
    // MARK: Custom push notifications
    
//    func sendPushWithText(text: String) {
//        var pushMessage: String! = self.senderDisplayName + "LOL: " + text
//        self.createEventWithMessage(pushMessage)
//    }
//    
//    func sendPushWithAttachment() {
//        var pushMessage: String! = self.senderDisplayName + " sent attachment."
//        self.createEventWithMessage(pushMessage)
//    }
//    
//    func createEventWithMessage(message: String!) {
//        var users =  self.dialog!.occupantIDs.filter( {$0 as! UInt != ServicesManager.instance().currentUser().ID} ) as! [Int]
//        var usersString = users.map(
//        {
//            (number: Int) -> String in
//            return String(number)
//        })
//        var occupantsWithoutCurrentUser: String! = ",".join(usersString)
//        
//        // Sending push with event
//        var event: QBMEvent! = QBMEvent()
//        event.notificationType = QBMNotificationTypePush
//        event.usersIDs = occupantsWithoutCurrentUser
//        event.type = QBMEventTypeOneShot
//        //
//        // custom params
//        var dictPush: NSMutableDictionary = NSMutableDictionary()
//        dictPush.setValue(message, forKey: "SA_STR_PUSH_NOTIFICATION_MESSAGE".localized)
//        dictPush.setValue(self.dialog?.ID, forKey: "SA_STR_PUSH_NOTIFICATION_DIALOG_ID".localized)
//        //
//        var error: NSError?
//        var sendData: NSData! = NSJSONSerialization.dataWithJSONObject(dictPush, options: NSJSONWritingOptions.PrettyPrinted, error: &error)
//        var jsonString: NSString! = NSString(data: sendData, encoding: NSUTF8StringEncoding)
//        //
//        event.message = jsonString
//        
//        QBRequest.createEvent(event, successBlock: { (response: QBResponse!, events: [AnyObject]!) -> Void in
//            //
//            NSLog("create event successful")
//            }) { (response: QBResponse!) -> Void in
//            //
//        }
//    }
    
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
                    let user = ServicesManager.instance().usersService.user(UInt(deliveredID))
                    
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
                    statusString += "Delivered:" + deliveredLogin.joinWithSeparator(" ,")
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
        
        if let topLabelText = ServicesManager.instance().usersService.user(messageItem.senderID)?.login {
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
        
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        var size = CGSizeZero
        
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
        
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: CGRectGetWidth(collectionView.frame) - kMessageContainerWidthPadding, height: CGFloat.max), limitedToNumberOfLines:0)
        
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
                SVProgressHUD.showErrorWithStatus(response.error?.error?.localizedDescription)
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
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5;
        
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass
        
        if viewClass === QMChatOutgoingCell.self || viewClass === QMChatAttachmentOutgoingCell.self {
            let bottomAttributedString = self.bottomLabelAttributedStringForItem(item)
            let size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: CGRectGetWidth(collectionView.frame) - kMessageContainerWidthPadding, height: CGFloat.max), limitedToNumberOfLines:0)
            layoutModel.bottomLabelHeight = ceil(size.height)
        } else {
            
            layoutModel.spaceBetweenTopLabelAndTextView = 5;
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
            
            let message: QBChatMessage = self.items[indexPath.row] as! QBChatMessage;
            
            if let attachments = message.attachments {
                
                let attachment: QBChatAttachment = attachments.first!
                var shouldLoadFile = true
                
                if self.attachmentCellsMap[attachment.ID!] != nil {
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
                
                self.attachmentCellsMap[attachment.ID!] = attachmentCell
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
                    
                    weakSelf?.attachmentCellsMap.removeValueForKey(attachment.ID!)
                    
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
        } else if cell.isKindOfClass(QMChatIncomingCell.self) || cell.isKindOfClass(QMChatAttachmentIncomingCell.self) {
            (cell as! QMChatCell).containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        } else if cell.isKindOfClass(QMChatOutgoingCell.self) || cell.isKindOfClass(QMChatAttachmentOutgoingCell.self) {
            (cell as! QMChatCell).containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) -> Bool {
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass
        
        if viewClass === QMChatAttachmentIncomingCell.self || viewClass === QMChatAttachmentOutgoingCell.self {
            return false
        }
        
        return super.collectionView(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
        if action == Selector("copy:") {
            let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
            let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass

            if viewClass === QMChatAttachmentIncomingCell.self || viewClass === QMChatAttachmentOutgoingCell.self {
                return
            }
            
            UIPasteboard.generalPasteboard().string = item.text
        }
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        
        if self.dialog?.ID == dialogID {
            self.items = NSMutableArray(array: chatService.messagesMemoryStorage.messagesWithDialogID(dialogID))
            self.refreshCollectionView()
            
            ChatViewController.sendReadStatusForMessage(message, dialogID:self.dialog?.ID)
        }
    }
    
    func chatService(chatService: QMChatService!, didAddMessagesToMemoryStorage messages: [AnyObject]!, forDialogID dialogID: String!) {
        
        if self.dialog?.ID == dialogID {
            self.readMessages(messages as! [QBChatMessage], dialogID: dialogID)
            self.items = NSMutableArray(array: chatService.messagesMemoryStorage.messagesWithDialogID(dialogID))
            
            if (self.shouldHoldScrolOnCollectionView) {
                
                let bottomOffset = self.collectionView!.contentSize.height - self.collectionView!.contentOffset.y
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                
                /* Way for call reloadData sync */
                self.collectionView?.reloadData()
                self.collectionView?.performBatchUpdates(nil, completion: nil)

                self.collectionView!.contentOffset = CGPoint(x: 0, y: self.collectionView!.contentSize.height - bottomOffset)
                
                CATransaction.commit()

            } else {
                
                self.refreshCollectionView()
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
                self.collectionView?.collectionViewLayout.invalidateLayoutWithContext(context)
                
                if (self.collectionView?.numberOfItemsInSection(0) == 0) {
                    self.collectionView?.reloadData()
                }
                
                self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forRow: updatedMessageIndex, inSection: 0)])
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
    
    // MARK: QMChatAttachmentServiceDelegate
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService!, didChangeAttachmentStatus status: QMMessageAttachmentStatus, forMessage message: QBChatMessage!) {
        
        if message.dialogID == self.dialog?.ID {
            // Messages from memory storage.
            self.items = NSMutableArray(array: ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(self.dialog?.ID))
            self.refreshCollectionView()
        }
    }
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService!, didChangeLoadingProgress progress: CGFloat, forChatAttachment attachment: QBChatAttachment!) {
        
        if let attachmentCell = self.attachmentCellsMap[attachment.ID!] {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    // MARK : QMChatConnectionDelegate
    
    func chatServiceChatDidLogin() {
        
        if self.dialog?.type != QBChatDialogType.Private {
            self.updateMessages()
        }
        
        if let unreadMessages = self.unreadMessages {
            
            for message in unreadMessages {
                ChatViewController.sendReadStatusForMessage(message, dialogID:self.dialog?.ID)
            }
            
            self.unreadMessages = nil
        }
    }
}
