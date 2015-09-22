//
//  QMChatService+AttachmentService.h
//  QMServices
//
//  Created by QuickBlox on 7/1/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMChatService.h"

@interface QMChatService (AttachmentService)

- (BOOL)sendMessage:(QBChatMessage *)message type:(QMMessageType)type toDialog:(QBChatDialog *)dialog save:(BOOL)save saveToStorage:(BOOL)saveToStorage completion:(void(^)(NSError *error))completion;

@end
