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

class ChatViewController: QMChatViewController, QMChatServiceDelegate, UITextViewDelegate {
    var dialog: QBChatDialog?
    var shouldFixViewControllersStack = false
    var didBecomeActiveHandler : AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weak var weakSelf = self
        
        self.dialog?.onUserIsTyping = { (UInt userID)-> Void in
            
            if ServicesManager.instance.currentUser().ID == userID {
                return
            }
            
            weakSelf?.title = "SA_STR_TYPING".localized
        }
        
        self.dialog?.onUserStoppedTyping = { (UInt userID)-> Void in
            
            if ServicesManager.instance.currentUser().ID == userID {
                return
            }
            
            weakSelf?.updateTitle()
        }
        
        self.collectionView.typingIndicatorMessageBubbleColor = UIColor.redColor()
        
        self.inputToolbar.contentView.leftBarButtonItem = self.accessoryButtonItem()
        self.inputToolbar.contentView.rightBarButtonItem = self.sendButtonItem()
        
        self.senderID = QBSession.currentSession().currentUser.ID
        self.senderDisplayName = QBSession.currentSession().currentUser.login
        
        self.items = NSMutableArray()
        
        self.updateTitle()
        self.updateMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ServicesManager.instance.chatService.addDelegate(self)
        
        weak var weakSelf = self
        
        self.didBecomeActiveHandler = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification: NSNotification!) -> Void in
            
            weakSelf?.updateMessages()
            
        }
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
            ServicesManager.instance.currentDialogID = dialog.ID
        }
    }
	
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        if let didBecomeActiveHandler: AnyObject = self.didBecomeActiveHandler {
            NSNotificationCenter.defaultCenter().removeObserver(didBecomeActiveHandler)
        }
        
        ServicesManager.instance.currentDialogID = ""
        
        ServicesManager.instance.chatService.removeDelegate(self);
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
            if let recepeint = ConnectionManager.instance.usersDataSource.userByID(UInt(self.dialog!.recipientID)) {
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
        
        ServicesManager.instance.chatService.messagesWithChatDialogID(self.dialog?.ID, completion: { (response: QBResponse!, messages: [AnyObject]!) -> Void in
            
            if response.error == nil {
                
                if isProgressHUDShowed {
                    SVProgressHUD.showSuccessWithStatus("SA_STR_COMPLETED".localized)
                }
                
                weakSelf?.items.removeAllObjects()
                weakSelf?.items.addObjectsFromArray(messages)
                
                weakSelf?.refreshCollectionView()
            } else {
                SVProgressHUD.showErrorWithStatus(response.error.error.localizedDescription)
            }
            
        })
    }
    
    func refreshCollectionView() {
        self.collectionView.reloadData()
        self.scrollToBottomAnimated(false)
    }
    
    // MARK: Action Buttons
    
    func accessoryButtonItem() -> UIButton {
        var accessoryImage = UIImage(named: "attachment_ic")
        var imageWidth = accessoryImage?.size.width
        var normalImage = accessoryImage?.imageMaskedWithColor(UIColor.lightGrayColor())
        var highlightedImage = accessoryImage?.imageMaskedWithColor(UIColor.darkGrayColor())
        
        var accessoryButton = UIButton(frame: CGRect(x: 0, y: 0, width: imageWidth!, height:  32))
        accessoryButton.setImage(normalImage, forState: UIControlState.Normal)
        accessoryButton.setImage(highlightedImage, forState: UIControlState.Highlighted)
        
        accessoryButton.contentMode = UIViewContentMode.ScaleAspectFill
        accessoryButton.backgroundColor = UIColor.clearColor()
        accessoryButton.tintColor = UIColor.lightGrayColor()
        
        return accessoryButton
    }
    
    func sendButtonItem() -> UIButton {
        
        var sendTitle : NSString = "SA_STR_CHAT_SEND".localized
        
        var sendButton = UIButton(frame: CGRectZero)
        sendButton.setTitle(sendTitle as String, forState: UIControlState.Normal)
        sendButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        sendButton.setTitleColor(UIColor.blueColor().colorByDarkeningColorWithValue(0.1), forState: UIControlState.Highlighted)
        sendButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Disabled)
        
        sendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        sendButton.titleLabel?.adjustsFontSizeToFitWidth = true
        sendButton.titleLabel?.minimumScaleFactor = 0.85
        sendButton.contentMode = UIViewContentMode.Center
        sendButton.backgroundColor = UIColor.clearColor()
        sendButton.tintColor = UIColor.blueColor()
        
        var maxHeight : CGFloat = 32.0
        var attributes = [String : AnyObject]()
        
        if let titleLabel = sendButton.titleLabel {
            attributes = [NSFontAttributeName : titleLabel.font!] as [String : AnyObject]
        }
        
        
        var sendTitleRect = sendTitle.boundingRectWithSize(CGSize(width: CGFloat.max, height: maxHeight), options: NSStringDrawingOptions.UsesLineFragmentOrigin|NSStringDrawingOptions.UsesFontLeading, attributes:attributes, context: nil)
        
        sendButton.frame = CGRect(x: 0,y: 0, width: CGRectGetWidth(CGRectIntegral(sendTitleRect)), height: maxHeight)
        
        return sendButton
    }
    
    // MARK: Actions
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
        
        var message = QBChatMessage()
        message.text = text;
        message.senderID = self.senderID
        message.senderNick = self.senderDisplayName
        
        button.enabled = false
        
        weak var weakSelf = self
        
        var didSent = ServicesManager.instance.chatService.sendMessage(message, toDialogId: self.dialog?.ID, save: true) { (error:NSError!) -> Void in
            button.enabled = true
            weakSelf?.finishSendingMessageAnimated(true)
        }
        
        if !didSent {
            button.enabled = true
            
            TWMessageBarManager.sharedInstance().showMessageWithTitle("SA_STR_ERROR".localized, description: "SA_STR_CANT_SEND_A_MESSAGE".localized, type: TWMessageBarMessageType.Info)
        }
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
                
                return QMChatIncomingCell.self
                
            } else {
                
                return QMChatOutgoingCell.self
            }
        }
        
        return nil
    }
    
    // MARK: Strings builder
    
    override func attributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        if messageItem.text == nil {
            return nil
        }
        
        var textColor = messageItem.senderID == self.senderID ? UIColor.whiteColor() : UIColor(white: 0.29, alpha: 1)
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 15)
        
        var attributedString = NSAttributedString(string: messageItem.text, attributes: attributes)
        
        return attributedString
    }
    
    
    override func topLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString? {

        if messageItem.senderID == self.senderID || self.dialog?.type == QBChatDialogType.Private {
            return nil
        }
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor(red: 0.184, green: 0.467, blue: 0.733, alpha: 1)
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 14)
        
        var topLabelText = messageItem.senderNick ?? String(messageItem.senderID)
        
        var topLabelAttributedString = NSAttributedString(string: topLabelText, attributes: attributes)
        
        return topLabelAttributedString
    }
    
    override func bottomLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        var textColor = messageItem.senderID == self.senderID ? UIColor(white: 1, alpha: 0.51) : UIColor(white: 0, alpha: 0.49)
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 12)
        
        let timestamp = messageTimeDateFormatter.stringFromDate(messageItem.dateSent)
        
        var bottomLabelAttributedString = NSAttributedString(string: timestamp, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(collectionView: QMChatCollectionView!, dynamicSizeAtIndexPath indexPath: NSIndexPath!, maxWidth: CGFloat) -> CGSize {
        
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        let attributedString = self.attributedStringForItem(item)
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.max), limitedToNumberOfLines: 0)
        
        return size
    }
    
     override func collectionView(collectionView: QMChatCollectionView!, minWidthAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let item : QBChatMessage = self.items[indexPath.row] as! QBChatMessage
        let attributedString = item.senderID == self.senderID ? self.bottomLabelAttributedStringForItem(item) : self.topLabelAttributedStringForItem(item)
        let size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: 1000, height: 1000), limitedToNumberOfLines:1)
        
        return size.width
    }
    
    override func collectionView(collectionView: QMChatCollectionView!, layoutModelAtIndexPath indexPath: NSIndexPath!) -> QMChatCellLayoutModel {
        var layoutModel : QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAtIndexPath: indexPath)
        
        if self.dialog?.type == QBChatDialogType.Private {
            layoutModel.topLabelHeight = 0.0
        }
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        
        return layoutModel
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(chatService: QMChatService!, didAddMessageToMemoryStorage message: QBChatMessage!, forDialogID dialogID: String!) {
        
        if self.dialog?.ID == dialogID {
            self.items.addObject(message)
            self.refreshCollectionView()
        }
    }
    
    func chatService(chatService: QMChatService!, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog!) {
        
        if self.dialog?.ID == chatDialog.ID {
            self.dialog = chatDialog
            self.updateTitle()
        }
    }
    
    // MARK: UITextViewDelegate
    
    override func textViewDidBeginEditing(textView: UITextView) {
        super.textViewDidBeginEditing(textView)
        
        if let dialog = self.dialog {
            dialog.sendUserIsTyping()
        }
        
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        super.textViewDidEndEditing(textView)
        
        if let dialog = self.dialog {
            dialog.sendUserStoppedTyping()
        }
    }
}
