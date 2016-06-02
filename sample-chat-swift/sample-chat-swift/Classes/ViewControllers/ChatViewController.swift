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

extension String {
    var length: Int {
        return (self as NSString).length
    }

    var composedCount : Int {
            var count = 0
            enumerateSubstringsInRange(startIndex..<endIndex, options: .ByComposedCharacterSequences) {_ in count++}
            return count
    }
}
class ChatViewController: QMChatViewController, QMChatServiceDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, QMChatAttachmentServiceDelegate, QMChatConnectionDelegate, QMChatCellDelegate {
   
    let maxCharactersNumber = 1024 // 0 - unlimited

    
    var dialog: QBChatDialog!
    var willResignActiveBlock: AnyObject?
    var attachmentCellsMap: NSMapTable!
    var detailedCells: Set<String> = []
    
    var typingTimer: NSTimer?
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
        self.topContentAdditionalInset = self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height;
        
        self.senderID = (ServicesManager.instance().currentUser()?.ID)!
        self.senderDisplayName = ServicesManager.instance().currentUser()?.login
        self.heightForSectionHeader = 40.0
        
        self.updateTitle()

        self.collectionView?.backgroundColor = UIColor.whiteColor()
        self.inputToolbar?.contentView?.backgroundColor = UIColor.whiteColor()
        self.inputToolbar?.contentView?.textView?.placeHolder = "SA_STR_MESSAGE_PLACEHOLDER".localized
		
		self.attachmentCellsMap = NSMapTable(keyOptions: NSPointerFunctionsOptions.StrongMemory, valueOptions: NSPointerFunctionsOptions.WeakMemory)
		
        if self.dialog.type == QBChatDialogType.Private {
            
            self.dialog.onUserIsTyping = {
                [weak self] (userID)-> Void in
				
                if ServicesManager.instance().currentUser()?.ID == userID {
                    return
                }
                
                self?.title = "SA_STR_TYPING".localized
            }
            
            self.dialog.onUserStoppedTyping = {
                [weak self] (userID)-> Void in
                
                if ServicesManager.instance().currentUser()?.ID == userID {
                    return
                }
                
                self?.updateTitle()
            }
        }
        
        ServicesManager.instance().chatService.addDelegate(self)
        ServicesManager.instance().chatService.chatAttachmentService.delegate = self
        
        // Retrieving messages
        if (self.storedMessages()?.count > 0 && self.chatSectionManager.totalMessagesCount == 0) {
            
            self.chatSectionManager.addMessages(self.storedMessages()!)
        }
        
        self.loadMessages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.willResignActiveBlock = NSNotificationCenter.defaultCenter().addObserverForName(
            UIApplicationWillResignActiveNotification,
            object: nil,
            queue: nil,
            usingBlock: {
                [weak self] (notification: NSNotification!) -> Void in
                
                self?.fireSendStopTypingIfNecessary()
            })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
		
		// Saving current dialog ID.
		ServicesManager.instance().currentDialogID = self.dialog.ID!
		
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let willResignActive = self.willResignActiveBlock {
            NSNotificationCenter.defaultCenter().removeObserver(willResignActive)
        }
        
        // Resetting current dialog ID.
        ServicesManager.instance().currentDialogID = ""
        
        // clearing typing status blocks
        self.dialog.clearTypingStatusBlocks()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let chatInfoViewController = segue.destinationViewController as? ChatUsersInfoTableViewController {
            chatInfoViewController.dialog = self.dialog
        }
    }
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Update
    
    func updateTitle() {
        
        if self.dialog.type != QBChatDialogType.Private {
            
            self.title = self.dialog.name
        }
        else {
            
            if let recipient = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(self.dialog!.recipientID)) {
                
                self.title = recipient.login
            }
        }
    }
    
    func storedMessages() -> [QBChatMessage]? {
        return ServicesManager.instance().chatService.messagesMemoryStorage.messagesWithDialogID(self.dialog.ID!)
    }
    
    func loadMessages() {
        // Retrieving messages for chat dialog ID.
		guard let currentDialogID = self.dialog.ID else {
			print ("Current chat dialog is nil")
			return
		}
		
        ServicesManager.instance().chatService.messagesWithChatDialogID(currentDialogID, completion: {
            [weak self] (response: QBResponse, messages: [QBChatMessage]?) -> Void in
            
            guard let strongSelf = self else { return }
			
			guard response.error == nil else {
				SVProgressHUD.showErrorWithStatus(response.error?.error?.localizedDescription)
				return
			}

			if messages?.count > 0 {
				strongSelf.chatSectionManager.addMessages(messages)
			}
			SVProgressHUD.dismiss()
			
			})
    }
	
    func sendReadStatusForMessage(message: QBChatMessage) {
		
		guard message.senderID != QBSession.currentSession().currentUser!.ID else {
			return
		}
		
		let currentUserID = NSNumber(unsignedInteger: QBSession.currentSession().currentUser!.ID)
		
        if (message.readIDs == nil || !message.readIDs!.contains(currentUserID)) {
            ServicesManager.instance().chatService.readMessage(message, completion: { (error: NSError?) -> Void in
                
                guard error == nil else {
                    NSLog("Problems while marking message as read! Error: %@", error!)
					return
                }
				
				if UIApplication.sharedApplication().applicationIconBadgeNumber > 0 {
					let badgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber
					UIApplication.sharedApplication().applicationIconBadgeNumber = badgeNumber - 1
				}
            })
        }
    }
	
    func readMessages(messages: [QBChatMessage]) {
        
        if QBChat.instance().isConnected {
			
			ServicesManager.instance().chatService.readMessages(messages, forDialogID: self.dialog.ID!, completion: nil)
        }
        else {
            
            self.unreadMessages = messages
        }
        
        var messageIDs = [String]()
        
        for message in messages {
            messageIDs.append(message.ID!)
        }
    }
    
    // MARK: Actions
    
    override func didPickAttachmentImage(image: UIImage!) {
        
        let message = QBChatMessage()
        message.senderID = self.senderID
        message.dialogID = self.dialog.ID
        message.dateSent = NSDate()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            [weak self] () -> Void in
            
            guard let strongSelf = self else { return }
            
            var newImage : UIImage! = image
            if strongSelf.imagePickerViewController.sourceType == UIImagePickerControllerSourceType.Camera {
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
            dispatch_async(dispatch_get_main_queue(), {
				// sendAttachmentMessage method always firstly adds message to memory storage
                ServicesManager.instance().chatService.sendAttachmentMessage(message, toDialog: self!.dialog, withAttachmentImage: resizedImage, completion: {
                    [weak self] (error: NSError?) -> Void in
					
					self?.attachmentCellsMap.removeObjectForKey(message.ID)
					
					guard error != nil else { return }
					
					// perform local attachment message deleting if error
					ServicesManager.instance().chatService.deleteMessageLocally(message)
					
					self?.chatSectionManager.deleteMessage(message)
					
					})
			})
			})
		
    }
	
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: UInt, senderDisplayName: String!, date: NSDate!) {
    
        let shouldJoin = self.dialog.type == .Group ? !self.dialog.isJoined() : false
        
        if !QBChat.instance().isConnected || shouldJoin {
            return
        }
        
        self.fireSendStopTypingIfNecessary()
        
        let message = QBChatMessage()
        message.text = text
        message.senderID = self.senderID
        message.deliveredIDs = [(self.senderID)]
        message.readIDs = [(self.senderID)]
        message.markable = true
        message.dateSent = date
        
        self.sendMessage(message)
    }
    
    func sendMessage(message: QBChatMessage) {
		
        // Sending message.
        ServicesManager.instance().chatService.sendMessage(message, toDialogID: self.dialog.ID!, saveToHistory: true, saveToStorage: true) { (error: NSError?) -> Void in
            
            if error != nil {
        
                QMMessageNotificationManager.showNotificationWithTitle("SA_STR_ERROR".localized, subtitle: error?.localizedDescription, type: QMMessageNotificationType.Warning)
            }
        }
        
        self.finishSendingMessageAnimated(true)
    }
    
    // MARK: Helper
	
    func showCharactersNumberError() {
        let title  = "SA_STR_ERROR".localized;
        let subtitle = String(format: "The character limit is %lu.", maxCharactersNumber)
        QMMessageNotificationManager.showNotificationWithTitle(title, subtitle: subtitle, type: .Error)
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
        
        let currentUserID = NSNumber(unsignedInteger:self.senderID)
        
		var readLogins: [String] = []
        
        if message.readIDs != nil {
            let messageReadIDs = message.readIDs!.filter { (element : NSNumber) -> Bool in
                return !element.isEqualToNumber(currentUserID)
            }
			
            if !messageReadIDs.isEmpty {
                for readID in messageReadIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(readID))
					
					guard let unwrappedUser = user else {
						let unknownUserLogin = "@\(readID)"
						readLogins.append(unknownUserLogin)
						
						continue
					}
					
					readLogins.append(unwrappedUser.login!)
                }
				
                statusString += message.isMediaMessage() ? "SA_STR_SEEN_STATUS".localized : "SA_STR_READ_STATUS".localized;
                statusString += ": " + readLogins.joinWithSeparator(", ")
            }
        }
        
        if message.deliveredIDs != nil {
			var deliveredLogins: [String] = []
            
            let messageDeliveredIDs = message.deliveredIDs!.filter { (element : NSNumber) -> Bool in
                return !element.isEqualToNumber(currentUserID)
            }
            
            if !messageDeliveredIDs.isEmpty {
                for deliveredID in messageDeliveredIDs {
                    let user = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(UInt(deliveredID))
					
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
                    statusString += "SA_STR_DELIVERED_STATUS".localized + ": " + deliveredLogins.joinWithSeparator(", ")
                }
            }
        }
        
        if statusString.isEmpty {
            statusString = "SA_STR_SENT_STATUS".localized
        }
        
        return statusString
    }
    
    // MARK: Override
    
    override func viewClassForItem(item: QBChatMessage) -> AnyClass! {
        // TODO: check and add QMMessageType.AcceptContactRequest, QMMessageType.RejectContactRequest, QMMessageType.ContactRequest
		
		if item.isNotificatonMessage() {
            return QMChatNotificationCell.self
		}
		
		if (item.senderID != self.senderID) {
			
			if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.Error) {
				
				return QMChatAttachmentIncomingCell.self
				
			}
			else {
				
				return QMChatIncomingCell.self
			}
			
		}
		else {
			
			if (item.isMediaMessage() && item.attachmentStatus != QMMessageAttachmentStatus.Error) {
				
				return QMChatAttachmentOutgoingCell.self
				
			}
			else {
				
				return QMChatOutgoingCell.self
			}
		}
    }
	
    // MARK: Strings builder
	
    override func attributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString? {
		
        guard messageItem.text != nil else {
            return nil
        }
		
        var textColor = messageItem.senderID == self.senderID ? UIColor.whiteColor() : UIColor.blackColor()
        if messageItem.isNotificatonMessage() {
            textColor = UIColor.blackColor()
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
    override func topLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString? {
        
		guard messageItem.senderID != self.senderID else {
            return nil
        }
		
		guard self.dialog.type != QBChatDialogType.Private else {
			return nil
		}
		
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor(red: 11.0/255.0, green: 96.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 17)
        attributes[NSParagraphStyleAttributeName] = paragrpahStyle
        
        var topLabelAttributedString : NSAttributedString?
        
        if let topLabelText = ServicesManager.instance().usersService.usersMemoryStorage.userWithID(messageItem.senderID)?.login {
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
    override func bottomLabelAttributedStringForItem(messageItem: QBChatMessage!) -> NSAttributedString! {
        
        let textColor = messageItem.senderID == self.senderID ? UIColor.whiteColor() : UIColor.blackColor()
        
        let paragrpahStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        paragrpahStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = textColor
        attributes[NSFontAttributeName] = UIFont(name: "Helvetica", size: 13)
        attributes[NSParagraphStyleAttributeName] = paragrpahStyle
        
        var text = messageItem.dateSent != nil ? messageTimeDateFormatter.stringFromDate(messageItem.dateSent!) : ""
        
        if messageItem.senderID == self.senderID {
            text = text + "\n" + self.statusStringFromMessage(messageItem)
        }
        
        let bottomLabelAttributedString = NSAttributedString(string: text, attributes: attributes)
        
        return bottomLabelAttributedString
    }
    
    // MARK: Collection View Datasource
    
    override func collectionView(collectionView: QMChatCollectionView!, dynamicSizeAtIndexPath indexPath: NSIndexPath!, maxWidth: CGFloat) -> CGSize {
        
        var size = CGSizeZero
		
		guard let message = self.chatSectionManager.messageForIndexPath(indexPath) else {
			return size
		}
		
		let messageCellClass: AnyClass! = self.viewClassForItem(message)
		
		
		if messageCellClass === QMChatAttachmentIncomingCell.self {
			size = CGSize(width: min(200, maxWidth), height: 200)
		}
		else if messageCellClass === QMChatAttachmentOutgoingCell.self {
			let attributedString = self.bottomLabelAttributedStringForItem(message)
			
			let bottomLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: min(200, maxWidth), height: CGFloat.max), limitedToNumberOfLines: 0)
			size = CGSize(width: min(200, maxWidth), height: 200 + ceil(bottomLabelSize.height))
		}
		else if messageCellClass === QMChatNotificationCell.self {
			let attributedString = self.attributedStringForItem(message)
			size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.max), limitedToNumberOfLines: 0)
			
		}
		else {
			
			let attributedString = self.attributedStringForItem(message)
			
			size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSize(width: maxWidth, height: CGFloat.max), limitedToNumberOfLines: 0)
		}
		
        return size
    }
	
    override func collectionView(collectionView: QMChatCollectionView!, minWidthAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
		
        var size = CGSizeZero
		
		guard let item = self.chatSectionManager.messageForIndexPath(indexPath) else {
			return 0
		}
		
		if self.detailedCells.contains(item.ID!) {
			
			let str = self.bottomLabelAttributedStringForItem(item)
			let frameWidth = CGRectGetWidth(collectionView.frame)
			let maxHeight = CGFloat.max
			
			size = TTTAttributedLabel.sizeThatFitsAttributedString(str, withConstraints: CGSize(width:frameWidth - kMessageContainerWidthPadding, height: maxHeight), limitedToNumberOfLines:0)
		}
		
		if self.dialog.type != QBChatDialogType.Private {
			
			let topLabelSize = TTTAttributedLabel.sizeThatFitsAttributedString(self.topLabelAttributedStringForItem(item), withConstraints: CGSize(width: CGRectGetWidth(collectionView.frame) - kMessageContainerWidthPadding, height: CGFloat.max), limitedToNumberOfLines:0)
			
			if topLabelSize.width > size.width {
				size = topLabelSize
			}
		}
		
        return size.width
    }
	
    override func collectionView(collectionView: QMChatCollectionView!, layoutModelAtIndexPath indexPath: NSIndexPath!) -> QMChatCellLayoutModel {
        var layoutModel: QMChatCellLayoutModel = super.collectionView(collectionView, layoutModelAtIndexPath: indexPath)
        
        layoutModel.avatarSize = CGSize(width: 0, height: 0)
        layoutModel.topLabelHeight = 0.0
        layoutModel.spaceBetweenTextViewAndBottomLabel = 5
        layoutModel.maxWidthMarginSpace = 20.0
		
		guard let item = self.chatSectionManager.messageForIndexPath(indexPath) else {
			return layoutModel
		}
		
		let viewClass: AnyClass = self.viewClassForItem(item) as AnyClass
		
		if viewClass === QMChatIncomingCell.self || viewClass === QMChatAttachmentIncomingCell.self {
			
			if self.dialog.type != QBChatDialogType.Private {
				let topAttributedString = self.topLabelAttributedStringForItem(item)
				let size = TTTAttributedLabel.sizeThatFitsAttributedString(topAttributedString, withConstraints: CGSize(width: CGRectGetWidth(collectionView.frame) - kMessageContainerWidthPadding, height: CGFloat.max), limitedToNumberOfLines:1)
				layoutModel.topLabelHeight = size.height
			}
			
			layoutModel.spaceBetweenTopLabelAndTextView = 5
		}
		
		var size = CGSizeZero
		
		if self.detailedCells.contains(item.ID!) {
			
			let bottomAttributedString = self.bottomLabelAttributedStringForItem(item)
			size = TTTAttributedLabel.sizeThatFitsAttributedString(bottomAttributedString, withConstraints: CGSize(width: CGRectGetWidth(collectionView.frame) - kMessageContainerWidthPadding, height: CGFloat.max), limitedToNumberOfLines:0)
		}
		
		layoutModel.bottomLabelHeight = floor(size.height)
		
		
        return layoutModel
    }
	
    override func collectionView(collectionView: QMChatCollectionView!, configureCell cell: UICollectionViewCell!, forIndexPath indexPath: NSIndexPath!) {
		
        super.collectionView(collectionView, configureCell: cell, forIndexPath: indexPath)
        
        // subscribing to cell delegate
		let chatCell = cell as! QMChatCell
		
        chatCell.delegate = self
        
        if let attachmentCell = cell as? QMChatAttachmentCell {
            
            if attachmentCell is QMChatAttachmentIncomingCell {
                chatCell.containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
            } else if attachmentCell is QMChatAttachmentOutgoingCell {
                chatCell.containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            }
            
            let message = self.chatSectionManager.messageForIndexPath(indexPath)
			
			if let attachment = message.attachments?.first {
				
				var keysToRemove: [String] = []
				
				let enumerator = self.attachmentCellsMap.keyEnumerator()
				
				while let existingAttachmentID = enumerator.nextObject() as? String {
					let cachedCell = self.attachmentCellsMap.objectForKey(existingAttachmentID)
					if cachedCell === cell {
						keysToRemove.append(existingAttachmentID)
					}
				}
				
				for key in keysToRemove {
					self.attachmentCellsMap.removeObjectForKey(key)
				}
				
				self.attachmentCellsMap.setObject(attachmentCell, forKey: attachment.ID)
				
				attachmentCell.attachmentID = attachment.ID
				
				// Getting image from chat attachment cache.
				
				ServicesManager.instance().chatService.chatAttachmentService.getImageForAttachmentMessage(message, completion: {
					[weak self] (error: NSError?, image: UIImage?) -> Void in
					
					guard attachmentCell.attachmentID == attachment.ID else {
						return
					}
					
					self?.attachmentCellsMap.removeObjectForKey(attachment.ID)
					
					guard error == nil else {
						SVProgressHUD.showErrorWithStatus(error!.localizedDescription)
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
			
        } else if cell is QMChatIncomingCell || cell is QMChatAttachmentIncomingCell {
            chatCell.containerView?.bgColor = UIColor(red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        } else if cell is QMChatOutgoingCell || cell is QMChatAttachmentOutgoingCell {
            chatCell.containerView?.bgColor = UIColor(red: 10.0/255.0, green: 95.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        } else if cell is QMChatNotificationCell {
            cell.userInteractionEnabled = false
            chatCell.containerView?.bgColor = self.collectionView?.backgroundColor
        }
    }
	
	/**
	Allows to copy text from QMChatIncomingCell and QMChatOutgoingCell
	*/
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) -> Bool {
		
		guard let item = self.chatSectionManager.messageForIndexPath(indexPath) else {
			return false
		}
		
        let viewClass: AnyClass = self.viewClassForItem(item) as AnyClass
        
        if viewClass === QMChatAttachmentIncomingCell.self ||
			viewClass === QMChatAttachmentOutgoingCell.self ||
			viewClass === QMChatNotificationCell.self ||
			viewClass === QMChatContactRequestCell.self {
				return false
        }
		
        return super.collectionView(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
		
		guard action == #selector(NSObject.copy(_:)) else {
			return
		}
		
		let item = self.chatSectionManager.messageForIndexPath(indexPath)
		let viewClass : AnyClass = self.viewClassForItem(item) as AnyClass
		
		if viewClass === QMChatAttachmentIncomingCell.self
			|| viewClass === QMChatAttachmentOutgoingCell.self
			|| viewClass === QMChatNotificationCell.self
			|| viewClass === QMChatContactRequestCell.self {
				
				return
		}
		
		UIPasteboard.generalPasteboard().string = item.text
		
    }
	
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let lastSection = (self.collectionView?.numberOfSections())! - 1
		
        if (indexPath.section == lastSection && indexPath.item == (self.collectionView?.numberOfItemsInSection(lastSection))! - 1) {
            // the very first message
            // load more if exists
            // Getting earlier messages for chat dialog identifier.
			
			guard let dialogID = self.dialog.ID else {
				print("DialogID is nil")
				return super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
			}
			
            ServicesManager.instance().chatService.loadEarlierMessagesWithChatDialogID(dialogID).continueWithBlock({
                [weak self] (task: BFTask!) -> AnyObject! in
                
                guard let strongSelf = self else { return nil }
                
                if (task.result?.count > 0) {
                    strongSelf.chatSectionManager.addMessages(task.result as! [QBChatMessage]!)
                }
                
                return nil
                })
        }
        
        // marking message as read if needed
        if let message = self.chatSectionManager.messageForIndexPath(indexPath) {
            self.sendReadStatusForMessage(message)
        }
        
        return super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    // MARK: QMChatCellDelegate
	
	/**
	Removes size from cache for item to allow cell expand and show read/delivered IDS or unexpand cell
	*/
    func chatCellDidTapContainer(cell: QMChatCell!) {
        let indexPath = self.collectionView?.indexPathForCell(cell)
        
        guard let currentMessageID = self.chatSectionManager.messageForIndexPath(indexPath).ID else {
			return
		}
		
		if self.detailedCells.contains(currentMessageID) {
			self.detailedCells.remove(currentMessageID)
		} else {
			self.detailedCells.insert(currentMessageID)
		}
		
		self.collectionView?.collectionViewLayout.removeSizeFromCacheForItemID(currentMessageID)
		self.collectionView?.performBatchUpdates(nil, completion: nil)
		
    }

    func chatCell(cell: QMChatCell!, didPerformAction action: Selector, withSender sender: AnyObject!) {
    }
    
    func chatCell(cell: QMChatCell!, didTapAtPosition position: CGPoint) {
    }
    
    func chatCellDidTapAvatar(cell: QMChatCell!) {
    }
    
    // MARK: QMChatServiceDelegate
    
    func chatService(chatService: QMChatService, didLoadMessagesFromCache messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.ID == dialogID {
            
            self.chatSectionManager.addMessages(messages)
        }
    }
    
    func chatService(chatService: QMChatService, didAddMessageToMemoryStorage message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.ID == dialogID {
            // Insert message received from XMPP or self sent
            self.chatSectionManager.addMessage(message)
        }
    }
    
    func chatService(chatService: QMChatService, didUpdateChatDialogInMemoryStorage chatDialog: QBChatDialog) {
        
        if self.dialog.type != QBChatDialogType.Private && self.dialog.ID == chatDialog.ID {
            self.dialog = chatDialog
            self.title = self.dialog.name
        }
    }
    
    func chatService(chatService: QMChatService, didUpdateMessage message: QBChatMessage, forDialogID dialogID: String) {
        
        if self.dialog.ID == dialogID {
            self.chatSectionManager.updateMessage(message)
        }
        
    }
    
    func chatService(chatService: QMChatService, didUpdateMessages messages: [QBChatMessage], forDialogID dialogID: String) {
        
        if self.dialog.ID == dialogID {
            self.chatSectionManager.updateMessages(messages)
        }
        
    }
    
    // MARK: UITextViewDelegate
    
    override func textViewDidChange(textView: UITextView) {
        super.textViewDidChange(textView)
    }
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        
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
		
        self.typingTimer = NSTimer.scheduledTimerWithTimeInterval(4.0, target: self, selector: #selector(ChatViewController.fireSendStopTypingIfNecessary), userInfo: nil, repeats: false)
        
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
            stringRange = (text as NSString).rangeOfComposedCharacterSequencesForRange(stringRange)
            
            // Now you can create the short string
            let shortString = (text as NSString).substringWithRange(stringRange)
            
            let newText = NSMutableString()
            newText.appendString(oldString)
            newText.insertString(shortString, atIndex: range.location)
            textView.text = newText as String

            self.showCharactersNumberError()
            
            self.textViewDidChange(textView)
            
            return false
        }
    
        return true
    }
    
    override func textViewDidEndEditing(textView: UITextView) {
        
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
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService, didChangeAttachmentStatus status: QMMessageAttachmentStatus, forMessage message: QBChatMessage) {
        
        if status != QMMessageAttachmentStatus.NotLoaded {
            
            if message.dialogID == self.dialog.ID {
                self.chatSectionManager.updateMessage(message)
            }
        }
    }
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService, didChangeLoadingProgress progress: CGFloat, forChatAttachment attachment: QBChatAttachment) {
        
        if let attachmentCell = self.attachmentCellsMap.objectForKey(attachment.ID!) {
            attachmentCell.updateLoadingProgress(progress)
        }
    }
    
    func chatAttachmentService(chatAttachmentService: QMChatAttachmentService, didChangeUploadingProgress progress: CGFloat, forMessage message: QBChatMessage) {
        var cell = self.attachmentCellsMap.objectForKey(message.ID)
        
        if cell == nil && progress < 1.0 {
            let indexPath = self.chatSectionManager.indexPathForMessage(message)
            cell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? QMChatAttachmentCell
            self.attachmentCellsMap.setObject(cell, forKey: message.ID)
        }
		
		cell?.updateLoadingProgress(progress)
		
    }
    
    // MARK : QMChatConnectionDelegate
    
    func refreshAndReadMessages() {
        
        SVProgressHUD.showWithStatus("SA_STR_LOADING_MESSAGES".localized, maskType: SVProgressHUDMaskType.Clear)
        self.loadMessages()
        
        if let messagesToRead = self.unreadMessages {
            self.readMessages(messagesToRead)
        }
        
        self.unreadMessages = nil
    }
    
    func chatServiceChatDidConnect(chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
    
    func chatServiceChatDidReconnect(chatService: QMChatService) {
        
        self.refreshAndReadMessages()
    }
}
