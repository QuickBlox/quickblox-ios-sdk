//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

class ChatViewController: JSQMessagesViewController, QBChatDelegate {
    var dialog: QBChatDialog?
    var messagesDownloadRequest : QBRequest? // ability to cancel downloading messages
    var messages: [QBChatAbstractMessage] = []
    
    let outgoingBubbleImageView: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor()!)
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let chatRoom = dialog?.chatRoom {
            chatRoom.joinRoomWithHistoryAttribute(["maxstanzas":0]) // sendChatMessageWithoutJoin temporary not working
        }
        else {
            self.navigationItem.rightBarButtonItem = nil // remove "info" button
        }
        
        QBChat.instance().addDelegate(self)
        
        // needed by block in method QBChat.instance().sendMessage(message, sentBlock
        QBChat.instance().streamManagementEnabled = true
        
        inputToolbar.contentView.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        // remove avatars
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        // set owner of dialog ( currentUser )
        self.senderId = ConnectionManager.instance.currentUser?.ID.description
        self.senderDisplayName = ConnectionManager.instance.currentUser?.fullName
        
        self.loadMessages()
    }
    
    func loadMessages() {
        SVProgressHUD.showWithStatus("Loading messages...")
        messagesDownloadRequest = QBRequest.messagesWithDialogID(dialog?.ID, successBlock: { [weak self] (response: QBResponse!, downloadedMessages: [AnyObject]!) -> Void in
            SVProgressHUD.showSuccessWithStatus("Loaded!")
            
            if let strongSelf = self,  downloadedHistoryMessages =  downloadedMessages as? [QBChatHistoryMessage] {
                strongSelf.messagesDownloadRequest = nil
                strongSelf.messages = downloadedHistoryMessages
                strongSelf.collectionView.reloadData()
                strongSelf.scrollToBottomAnimated(true)
            }
            }) { (response: QBResponse!) -> Void in
                println(response.error.error.localizedDescription)
                SVProgressHUD.showErrorWithStatus("Error loading messages")
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.collectionViewLayout.springinessEnabled = true
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
        message.senderID = ConnectionManager.instance.currentUser!.ID
        message.customParameters = ["save_to_history": 1]
        if( dialog?.type.value == QBChatDialogTypePrivate.value ) {
            SVProgressHUD.showWithStatus("Sending", maskType: SVProgressHUDMaskType.Clear)
            var occupantsIDs = dialog!.occupantIDs as! [UInt]
            message.recipientID = UInt(occupantsIDs.filter{$0 != ConnectionManager.instance.currentUser!.ID}[0])
            message.text = text
            QBChat.instance().sendMessage(message)
            
            self.messages.append(message)
            
            self.finishSendingMessageAnimated(true)
            SVProgressHUD.dismiss()
        }
        else{
            message.text = text
            message.senderNick = ConnectionManager.instance.currentUser?.fullName
            
            QBChat.instance().sendChatMessageWithoutJoin(message, toRoom: dialog?.chatRoom)
            // will call self.finishSendingMessageAnimated for group chat message in chatRoomDidReceiveMessage
        }
        self.inputToolbar.contentView.textView.text = ""
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var image: JSQMessagesBubbleImage?
        
        let message = messages[indexPath.row]
        
        // check out who sent the message
        return message.senderID == ConnectionManager.instance.currentUser?.ID ? outgoingBubbleImageView : incomingBubbleImageView;
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell: JSQMessagesCollectionViewCell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView.textColor = UIColor.blackColor()
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        var qbMessage = messages[indexPath.row]
        var jsqMessage: JSQMessage?
        if let qbChatMessage = qbMessage as? QBChatMessage {
            jsqMessage = JSQMessage(senderId: String(qbChatMessage.senderID), senderDisplayName: qbChatMessage.senderNick ?? qbChatMessage.senderID.description, date: qbChatMessage.datetime, text: qbChatMessage.text)
        }
        else if let qbChatHistoryMessage = qbMessage as? QBChatHistoryMessage {
            var sender: QBUUser?
            if let users = ConnectionManager.instance.dialogsUsers {
                let filteredUsers = users.filter({$0.ID == qbChatHistoryMessage.senderID})
                if filteredUsers.count > 0 {
                    sender = filteredUsers[0]
                }
            }
            jsqMessage = JSQMessage(senderId: String(qbChatHistoryMessage.senderID), senderDisplayName: sender?.fullName ?? String(qbChatHistoryMessage.senderID), date: qbChatHistoryMessage.datetime, text: qbChatHistoryMessage.text)
        }
        
        return jsqMessage
    }
    
    /**
    *  QBChat delegate methods
    */
    
    func chatDidNotSendMessage(message: QBChatMessage!, error: NSError!) {
        if error.code == 503 {
            UIAlertView(title: "Can't send a message", message: "You are in the blacklist", delegate: nil, cancelButtonTitle: "Okaaay").show()
        }
        else if error.code == 403 {
            UIAlertView(title: "Can't send a message", message: "forbidden", delegate: nil, cancelButtonTitle: "Okaaay").show()
        }
        
        // remove my last message and restore text input
        let excludedLastMessage = messages.filter({$0.senderID == ConnectionManager.instance.currentUser!.ID}).last
        messages = messages.filter({$0 != excludedLastMessage})
        self.inputToolbar.contentView.textView.text = excludedLastMessage!.text
        self.collectionView.reloadData()
        
        SVProgressHUD.dismiss()
    }
    
    
    func chatDidReceiveMessage(message: QBChatMessage!) {
        if self.dialog!.chatRoom == nil {
            self.messages.append(message)
            if message.senderID != ConnectionManager.instance.currentUser?.ID {
                self.finishReceivingMessageAnimated(true)
            }
        }
    }
    
    func chatRoomDidReceiveMessage(message: QBChatMessage!, fromRoomJID roomJID: String!) {
        if roomJID == self.dialog?.roomJID {
            // filter duplicates
            if !self.messages.filter({$0.ID == message.ID}).isEmpty {
                return
            }
            
            self.messages.append(message)
            if message.senderID == ConnectionManager.instance.currentUser?.ID {
                self.finishSendingMessageAnimated(true)
            }
            else {
                self.finishReceivingMessageAnimated(true)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let groupChatInfoVC = segue.destinationViewController as? GroupChatUsersInfoTableViewController {
            groupChatInfoVC.chatDialog = self.dialog
        }
    }
    
    deinit{
        if let downloadingRequest = messagesDownloadRequest {
            downloadingRequest.cancel()
            SVProgressHUD.dismiss()
        }
        if let chatRoom = dialog?.chatRoom {
            chatRoom.leaveRoom()
        }
        
        QBChat.instance().removeDelegate(self)
    }
}
