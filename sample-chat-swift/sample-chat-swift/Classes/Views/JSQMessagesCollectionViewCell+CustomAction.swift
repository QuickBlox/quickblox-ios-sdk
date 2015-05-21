//
//  JSQMessagesCollectionViewCell+DeleteAction.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/23/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

// subclassing will result in many errors
extension JSQMessagesCollectionViewCell {
    private struct AssociatedKeys {
        static var messageID = "nsh_DescriptiveName"
    }
    
    var messageID: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.messageID) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.messageID,
                    newValue as NSString?,
                    UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                )
            }
        }
    }
    public override func delete(sender: AnyObject?) {
        if let messID = self.messageID {
            ConnectionManager.instance.messagesIDsToDelete.append(messID)
        }
    }
}