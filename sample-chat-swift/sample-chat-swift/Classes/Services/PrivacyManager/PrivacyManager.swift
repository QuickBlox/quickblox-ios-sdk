//
//  PrivacyManager.swift
//  sample-chat-swift
//
//  Created by Anton Sokolchenko on 4/7/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

class PrivacyManager : NSObject, QBChatDelegate {
    var privacyList : QBPrivacyList = QBPrivacyList(name: "default")
    
    // we need to receive privacy list only once per user
    private var receivedPrivacyList = false
    
    override init(){
        super.init()
        QBChat.instance().addDelegate(self)
    }
    
    func isUserInBlockListP2P(user: QBUUser) -> Bool {
        var privacyListItems = Array(self.privacyList.items) as! [QBPrivacyItem]
        return !privacyListItems.filter({ $0.valueForType == user.ID  && $0.type.value == USER_ID.value && $0.action.value == DENY.value}).isEmpty
    }
    
    func isUserInBlockListGroupChats(user: QBUUser) -> Bool {
        var privacyListItems = Array(self.privacyList.items) as! [QBPrivacyItem]
        return !privacyListItems.filter({ $0.valueForType == user.ID && $0.type.value == GROUP_USER_ID.value && $0.action.value == DENY.value}).isEmpty
    }
    
    func isUserInBlockList(user: QBUUser) -> Bool {
        let privacyListItems = Array(self.privacyList.items) as! [QBPrivacyItem]
        return !privacyListItems.filter({ $0.valueForType == user.ID && $0.action.value == DENY.value}).isEmpty
    }
    
    func retrieveDefaultPrivacyList() {
        assert(QBChat.instance().isLoggedIn());
        QBChat.instance().retrievePrivacyListWithName("default")
    }
    
    func blockUserInP2PChat(user :QBUUser!) {
        var privacyItem = QBPrivacyItem()
        privacyItem.valueForType = user.ID
        privacyItem.type = USER_ID
        privacyItem.action = DENY
        self.privacyList.addObject(privacyItem)
        self.applyListRules()
    }
    
    func blockUserInGroupChats(user :QBUUser!) {
        var privacyItem = QBPrivacyItem()
        privacyItem.valueForType = user.ID
        privacyItem.type = GROUP_USER_ID
        privacyItem.action = DENY
        
        self.privacyList.addObject(privacyItem)
        self.applyListRules()
    }
    
    func blockUserEverywhere(user :QBUUser!) {
        // p2p
        var privacyItem = QBPrivacyItem()
        privacyItem.valueForType = user.ID
        privacyItem.type = USER_ID
        privacyItem.action = DENY
        
        self.privacyList.addObject(privacyItem)
        
        // group chats
        var privacyItem2 = QBPrivacyItem()
        privacyItem2.valueForType = user.ID
        privacyItem2.type = GROUP_USER_ID
        privacyItem2.action = DENY
        
        self.privacyList.addObject(privacyItem2)
        self.applyListRules()
    }
    
    func unblockUserInGroupChats(user: QBUUser) {
        for (index, element) in enumerate(self.privacyList.items){
            if let privacyItem = element as? QBPrivacyItem{
                if privacyItem.type.value == GROUP_USER_ID.value && privacyItem.valueForType == user.ID {
                    self.privacyList.items.removeObject(element)
                }
            }
        }
        self.applyListRules()
    }
    
    func unblockUserInP2PChat(user: QBUUser) {
        if self.privacyList.items == nil {
            return
        }
        for (index, element) in enumerate(self.privacyList.items){
            if let privacyItem = element as? QBPrivacyItem{
                if privacyItem.type.value == USER_ID.value && privacyItem.valueForType == user.ID {
                    self.privacyList.items.removeObject(element)
                }
            }
        }
        self.applyListRules()
    }
    
    func unblockUserEverywhere(user: QBUUser) {
        for (index, element) in enumerate(self.privacyList.items){
            if element.valueForType == user.ID {
                self.privacyList.items.removeObject(element)
            }
        }
        self.applyListRules()
    }
    
    private func applyListRules() {
        QBChat.instance().setPrivacyList(self.privacyList)
        QBChat.instance().setDefaultPrivacyListWithName(self.privacyList.name)
        QBChat.instance().setActivePrivacyListWithName(self.privacyList.name)
    }
    
    func reset() {
        self.privacyList = QBPrivacyList(name: "default")
        self.receivedPrivacyList = false
    }
    
    /**
    *  QBChat delegate methods
    */
    
    func chatDidReceivePrivacyList(privacyList: QBPrivacyList!) {
        if receivedPrivacyList {
            return;
        }
        self.privacyList = privacyList
        receivedPrivacyList = true
    }
    
    deinit{
        QBChat.instance().removeDelegate(self)
    }
    
}