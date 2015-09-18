//
//  NotificationService.swift
//  sample-chat-swift
//
//  Created by Vitaliy Gorbachov on 9/18/15.
//  Copyright (c) 2015 quickblox. All rights reserved.
//

import Foundation

protocol NotificationServiceDelegate {
    /**
    *  Is called when dialog fetching is complete and ready to return requested dialog
    *
    *  @param chatDialog QBChatDialog instance. Successfully fetched dialog
    */
    func notificationServiceDidSucceedFetchingDialog(chatDialog: QBChatDialog!)
    
    /**
    *  Is called when dialog was not found nor in memory storage nor in cache
    *  and NotificationService started requesting dialog from server
    */
    func notificationServiceDidStartLoadingDialogFromServer()
    
    /**
    *  Is called when dialog request from server was completed
    */
    func notificationServiceDidFinishLoadingDialogFromServer()
    
    /**
    *  Is called when dialog was not found in both memory storage and cache
    *  and server request return nil
    */
    func notificationServiceDidFailFetchingDialog()
}

/**
 *  Service responsible for working with push notifications
 */
class NotificationService {
    
    var delegate: NotificationServiceDelegate?
    var pushDialogID: String?
    
    func handlePushNotificationWithDelegate(delegate: NotificationServiceDelegate!) {
        if self.pushDialogID!.isEmpty {
            return
        }
        
        self.delegate = delegate;
        
        ServicesManager.instance().chatService.fetchDialogWithID(self.pushDialogID, completion: {
            [weak self] (chatDialog: QBChatDialog!) -> Void in
            if let strongSelf = self {
                //
                if (chatDialog != nil) {
                    strongSelf.pushDialogID = nil;
                    strongSelf.delegate?.notificationServiceDidSucceedFetchingDialog(chatDialog);
                }
                else {
                    //
                    strongSelf.delegate?.notificationServiceDidStartLoadingDialogFromServer()
                    ServicesManager.instance().chatService.loadDialogWithID(strongSelf.pushDialogID, completion: { (loadedDialog: QBChatDialog!) -> Void in
                        //
                        strongSelf.delegate?.notificationServiceDidFinishLoadingDialogFromServer()
                        if (loadedDialog != nil) {
                            //
                            strongSelf.delegate?.notificationServiceDidSucceedFetchingDialog(loadedDialog)
                        }
                        else {
                            strongSelf.delegate?.notificationServiceDidFailFetchingDialog()
                        }
                    })
                }
            }
        })
    }
}