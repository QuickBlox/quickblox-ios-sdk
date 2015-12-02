//
//  QMChatService+AttachmentService.h
//  QMServices
//
//  Created by QuickBlox on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatService.h"

@interface QMChatService (AttachmentService)

/**
 *  Send message to dialog with identifier
 *
 *  @param message          QBChatMessage instance
 *  @param type             QMMessageType message type (Default: QMMessageTypeText)
 *  @param dialogID         dialog identifier
 *  @param saveToHistory    if YES - saves message to chat history
 *  @param saveToStorage    if YES - saves to local storage
 *  @param completion       completion block with failure error
 */
- (void)sendMessage:(QBChatMessage *)message
               type:(QMMessageType)type
           toDialog:(QBChatDialog *)dialog
      saveToHistory:(BOOL)saveToHistory
      saveToStorage:(BOOL)saveToStorage
         completion:(QBChatCompletionBlock)completion;

@end
