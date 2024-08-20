//
//  QBAIAnswerAssistMessageProtocol.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBAIAnswerAssistHistoryMessageProtocol;

@protocol QBAIAnswerAssistMessageProtocol <NSObject>

@required
/**
 ID of Smart Chat Assistan of Your Application in QuickBlox Dashboard.
 */
@property (readonly) NSString *smartChatAssistantId;

/**
 Message you want to get answer for.
 */
@property (readonly) NSString *message;

/**
 Conversation history. Used to add context.
 */
@property (readonly) NSArray<id<QBAIAnswerAssistHistoryMessageProtocol>> *history;

@end

NS_ASSUME_NONNULL_END
