//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

class ChatViewController: JSQMessagesViewController, QBChatDelegate {
    let messagesBond: ArrayBond<QBChatMessage> = ArrayBond<QBChatMessage>()
    var showLoadingIndicator: Bond<Bool>!
    var dialog: QBChatDialog?
    var shouldFixViewControllersStack = false
    
    var chatViewModel: ChatViewModel!
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assert(dialog != nil)
		
		
        self.chatViewModel = ChatViewModel(currentUserID: ServicesManager.instance.currentUser()!.ID, dialog: dialog!)
		
        self.startMessagesObserver()
        
        if dialog?.chatRoom != nil {
			dialog?.chatRoom.joinRoom()
			ConnectionManager.instance.currentChatViewModel = self.chatViewModel
		}
        
        QBChat.instance().addDelegate(self)
        
        // needed by block in method QBChat.instance().sendMessage(message, sentBlock
        QBChat.instance().streamManagementEnabled = true
        
        self.collectionView.collectionViewLayout.springinessEnabled = false
        self.inputToolbar.contentView.leftBarButtonItem = nil
        self.automaticallyScrollsToMostRecentMessage = true
        // remove avatars
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
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
        }
        
        // set dialog owner ( currentUser )
        self.senderId = ServicesManager.instance.currentUser()?.ID.description
        self.senderDisplayName = ServicesManager.instance.currentUser()?.fullName ?? ServicesManager.instance.currentUser()?.login
        self.chatViewModel.loadMoreMessages()
        
        self.addRefreshControl()
    }
    
    func addRefreshControl() {
        refreshControl.addTarget(self.chatViewModel, action: "loadMoreMessages", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
    }
	
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    /**
    JSQM delegate methods
    */
    
    // send message
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if( text.isEmpty ) {
            return;
        }
        
        var message = QBChatMessage()
        message.senderID = ServicesManager.instance.currentUser()!.ID
        message.customParameters = ["save_to_history": 1]
		message.customParameters["date_sent"] =  NSDate().timeIntervalSince1970
        if( dialog?.type == .Private ) {
            SVProgressHUD.showWithStatus("SA_STR_SENDING".localized, maskType: SVProgressHUDMaskType.Clear)
            message.recipientID = self.chatViewModel.recipientID
            message.text = text
            dialog?.sendMessage(message)
            
            self.chatViewModel.messages.append(message)
            
            self.finishSendingMessageAnimated(true)
            SVProgressHUD.dismiss()
        }
        else{
            message.text = text
            message.senderNick = ServicesManager.instance.currentUser()?.fullName
            dialog?.sendMessage(message)
			
            // will call self.finishSendingMessageAnimated for group chat message in chatRoomDidReceiveMessage
        }
        self.inputToolbar.contentView.textView.text = ""
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        return self.chatViewModel.bubbleImageViewForMessageAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.chatViewModel.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        cell.textView.textColor = UIColor.blackColor()
        cell.messageID = self.chatViewModel.messages[indexPath.row].ID
        cell.textView.selectable = false
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        var qbMessage = chatViewModel.messages[indexPath.row]
        var jsqMessage: JSQMessage?
        if let qbChatMessage = qbMessage as? QBChatMessage {
            jsqMessage = JSQMessage(senderId: String(qbChatMessage.senderID), senderDisplayName: qbChatMessage.senderNick ?? qbChatMessage.senderID.description, date: qbChatMessage.dateSent, text: qbChatMessage.text)
        }
        else if let qbChatHistoryMessage = qbMessage as? QBChatMessage {
            var sender: QBUUser?
            let users = StorageManager.instance.dialogsUsers
            
            if users.count > 0 {
                let filteredUsers = users.filter({$0.ID == qbChatHistoryMessage.senderID})
                
                if filteredUsers.count > 0 {
                    sender = filteredUsers[0]
                }
            }
            
            jsqMessage = JSQMessage(senderId: String(qbChatHistoryMessage.senderID), senderDisplayName: sender?.fullName ?? String(qbChatHistoryMessage.senderID), date: qbChatHistoryMessage.dateSent, text: qbChatHistoryMessage.text)
        }
        
        return jsqMessage
    }

    // disable text selection
    override func jsq_didReceiveMenuWillHideNotification(notification: NSNotification!) {
        if let indexPath = self.selectedIndexPathForMenu {
            var cell = self.collectionView.cellForItemAtIndexPath(indexPath) as? JSQMessagesCollectionViewCell
            
            if cell != nil {
                cell?.textView.selectable = false
            }
        }
        super.jsq_didReceiveMenuWillHideNotification(notification)
    }
    
    
    /**
    *  QBChat delegate methods
    */
    
    func chatDidNotSendMessage(message: QBChatMessage!, error: NSError!) {
        if error.code == 503 {
            UIAlertView(title: "Can't send a message", message: "You are in the blacklist", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        else if error.code == 403 {
            UIAlertView(title: "Can't send a message", message: "forbidden", delegate: nil, cancelButtonTitle: "Ok").show()
        }
        
        // remove my last message and restore text input
        if let lastMessage = self.chatViewModel.myLastMessage {
            self.inputToolbar.contentView.textView.text = lastMessage.text
            self.chatViewModel.messages.removeLast()
        }
        self.collectionView.reloadData()
        
        SVProgressHUD.dismiss()
    }
    
    
    func chatDidReceiveMessage(message: QBChatMessage!) {
        if self.dialog!.chatRoom == nil {
            self.chatViewModel.messages.append(message)
            if message.senderID != ServicesManager.instance.currentUser()?.ID {
                self.finishReceivingMessageAnimated(true)
            }
        }
    }
    
    func chatRoomDidReceiveMessage(message: QBChatMessage!, fromRoomJID roomJID: String!) {
        if roomJID == self.dialog?.roomJID {
            // filter duplicates
            if !self.chatViewModel.messages.filter({$0.ID == message.ID}).isEmpty {
                return
            }
            
            self.chatViewModel.messages.append(message)
            if message.senderID == ServicesManager.instance.currentUser()?.ID {
                self.finishSendingMessageAnimated(true)
            }
            else {
                self.finishReceivingMessageAnimated(true)
            }
        }
    }
    
    /**
    UIMenu delegate method
    */
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) -> Bool {
        
        if action == Selector("delete:"){
            return true
        }
        
        return super.collectionView(collectionView, canPerformAction: action, forItemAtIndexPath: indexPath, withSender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let groupChatInfoVC = segue.destinationViewController as? ChatUsersInfoTableViewController {
            groupChatInfoVC.dialog = self.dialog
        }
    }
    
    /**
    Observers
    */
    
    func startMessagesObserver() {
        // start observing messages array of chatViewModel
        self.chatViewModel.messages ->> messagesBond
        
        messagesBond.didInsertListener = { [weak self] (array, indices) in
            SVProgressHUD.dismiss()
            if let strongSelf = self {
                let firstRun = strongSelf.collectionView.numberOfItemsInSection(0) == 0
                
                if firstRun {
                    strongSelf.finishReceivingMessage()
                    strongSelf.scrollToBottomAnimated(true)
                }
                else {
                    var indexPaths = indices.map({NSIndexPath(forItem: $0, inSection: 0)})
                    strongSelf.collectionView.insertItemsAtIndexPaths(indexPaths)
                }
            }
        }
        messagesBond.didRemoveListener = { [weak self] (array, indices) in
            SVProgressHUD.dismiss()
            if let strongSelf = self {
                var indexPaths = indices.map({NSIndexPath(forItem: $0, inSection: 0)})
                strongSelf.collectionView.deleteItemsAtIndexPaths(indexPaths)
            }
        }
        
        self.showLoadingIndicator = Bond() { [unowned self] (showLoadingIndicator: Bool) in
            if showLoadingIndicator {
                self.refreshControl.beginRefreshing()
                SVProgressHUD.showWithStatus("SA_STR_LOADING_MESSAGES".localized)
            }
            else {
                self.refreshControl.endRefreshing()
                SVProgressHUD.dismiss()
            }
        }
        self.chatViewModel.showLoadingIndicator ->> self.showLoadingIndicator
    }
    
    deinit{
		ConnectionManager.instance.currentChatViewModel = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
        QBChat.instance().removeDelegate(self)
    }
}
