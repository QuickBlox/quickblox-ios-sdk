//
//  ChatViewModel.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/20/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//


class ChatViewModel: NSObject {
    
    private var deletedMessagesBond = ArrayBond<String>()
    private var currentUserID: UInt!
    private var requestDownloadMessages: QBRequest?
    var showLoadingIndicator = Dynamic<Bool>(false)
    
    
    private(set) var messages: DynamicArray<QBChatAbstractMessage> = DynamicArray(Array())
    private(set) var dialog: QBChatDialog!
    
    let outgoingBubbleImageView: JSQMessagesBubbleImage = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor()!)
    let incomingBubbleImageView = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
    
    /// return: recipient( opponent ) ID for 1-1 chat if success,  0 if error
    var recipientID: UInt { get {
        let occupantsIDs = dialog.occupantIDs as! [UInt]
        let filteredOccupants = occupantsIDs.filter{$0 != self.currentUserID}
        return filteredOccupants.first ?? 0
        }
    }
    
    func bubbleImageViewForMessageAtIndex(index: Int) -> JSQMessagesBubbleImage {
        assert(messages.count > index)
        return messages[index].senderID == self.currentUserID ? outgoingBubbleImageView : incomingBubbleImageView
    }
    
    func loadMoreMessages() {
        if requestDownloadMessages != nil { return }
        showLoadingIndicator.value = true
        var page = QBResponsePage(limit: 10, skip: messages.count)
        
        var params = ["sort_desc": "date_sent"]
        
        requestDownloadMessages = QBRequest.messagesWithDialogID(dialog.ID, extendedRequest: params, forPage: page, successBlock: { [weak self] (response: QBResponse!, downloadedMessages: [AnyObject]!, page: QBResponsePage!) in
            
            if let strongSelf = self, downloadedHistoryMessages =
                downloadedMessages as? [QBChatAbstractMessage]{
                    strongSelf.requestDownloadMessages = nil
                    strongSelf.showLoadingIndicator.value = false
                    // insert in reversed order. Most recent messagess will be at the end
                    strongSelf.messages.splice(reverse(downloadedHistoryMessages), atIndex: 0)
            }
            
            }) { [weak self] (response: QBResponse!) in
                if let strongSelf = self {
                    strongSelf.requestDownloadMessages = nil
                    strongSelf.showLoadingIndicator.value = false
                }
                println(response.error.error.localizedDescription)
        }
    }
    
    /**
    Observers
    */
    
    func startObservingForDeletedMessages() {
        deletedMessagesBond.willRemoveListener = { [unowned self] (array, indices) in
            if array.count == 0 {
                return
            }
            for index in indices {
                if array.count <= index {
                    return
                }
                var messageID = array[index] as String
                
                // remove message
                for (index, object) in enumerate(self.messages) {
                    if self.messages[index].ID == messageID {
                        self.messages.removeAtIndex(index)
                    }
                }
            }
        }
        ConnectionManager.instance.messagesIDsToDelete ->> deletedMessagesBond
    }
    
    /// return: current user lastMessage
    var myLastMessage: QBChatAbstractMessage? { get {
        let myMessages = messages.filter({$0.senderID == self.currentUserID})
        return myMessages.last
        }
    }
    
    init(currentUserID: UInt, dialog: QBChatDialog) {
        super.init()
        self.currentUserID = currentUserID
        self.dialog = dialog
        
        self.startObservingForDeletedMessages()
    }
    
    
}
