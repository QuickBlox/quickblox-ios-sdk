//
//  ChatViewController.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/1/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

class ChatViewController: JSQMessagesViewController, QBChatDelegate {
    var dialog: QBChatDialog?
    var messages: [QBChatAbstractMessage] = []
    
    let outgoingBubbleImageView: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor()!)
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let chatRoom = dialog?.chatRoom {
            chatRoom.joinRoom() // sendChatMessageWithoutJoin temporary not working
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
        QBRequest.messagesWithDialogID(dialog?.ID, successBlock: { [weak self] (response: QBResponse!, downloadedMessages: [AnyObject]!) -> Void in
            SVProgressHUD.showSuccessWithStatus("Loaded!")
            if let strongSelf = self,  downloadedHistoryMessages =  downloadedMessages as? [QBChatHistoryMessage] {
                strongSelf.messages = downloadedHistoryMessages
                strongSelf.collectionView.reloadData()
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
            SVProgressHUD.showWithStatus("Sending")
            var occupantsIDs = dialog!.occupantIDs as! [UInt]
            message.recipientID = UInt(occupantsIDs.filter{$0 != ConnectionManager.instance.currentUser!.ID}[0])
            message.text = text
            QBChat.instance().sendMessage(message, sentBlock: { (error: NSError!) -> Void in
                if error != nil {
                    self.messages.append(message)
                    
                    self.finishSendingMessageAnimated(true)
                    SVProgressHUD.dismiss()
                }
                else {
                    SVProgressHUD.showErrorWithStatus("can't send")
                }
            })
        }
        else{
            message.text = text
            message.senderNick = ConnectionManager.instance.currentUser?.fullName
            
            QBChat.instance().sendChatMessageWithoutJoin(message, toRoom: dialog?.chatRoom)
            // will call self.finishSendingMessageAnimated for group chat message in chatRoomDidReceiveMessage
            
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        var image: JSQMessagesBubbleImage?
        
        let message = messages[indexPath.row]
        
        // check out who sent the message
        return message.senderID == ConnectionManager.instance.currentUser?.ID ? outgoingBubbleImageView : incomingBubbleImageView;
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
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
                sender = users.filter(){$0.ID == qbChatHistoryMessage.senderID}[0]
            }
            jsqMessage = JSQMessage(senderId: String(qbChatHistoryMessage.senderID), senderDisplayName: sender?.fullName ?? String(qbChatHistoryMessage.senderID), date: qbChatHistoryMessage.datetime, text: qbChatHistoryMessage.text)
        }
        
        return jsqMessage
    }
    
    /**
    *  QBChat delegate methods
    */
    
    func chatDidNotSendMessage(message: QBChatMessage!, error: NSError!) {
        
    }
    
    func chatDidReceiveMessage(message: QBChatMessage!) {
        // append my sent messages in self.didPressSendButton:
        if message.senderID != ConnectionManager.instance.currentUser?.ID {
            self.messages.append(message)
            self.finishReceivingMessageAnimated(true)
        }
    }
    
    func chatRoomDidReceiveMessage(message: QBChatMessage!, fromRoomJID roomJID: String!) {
        if roomJID == self.dialog?.roomJID {
            if message.senderID == ConnectionManager.instance.currentUser?.ID {
                self.messages.append(message)
                self.finishSendingMessageAnimated(true)
            }
            else {
                self.messages.append(message)
                self.finishReceivingMessageAnimated(true)
            }
        }
    }
    
}
