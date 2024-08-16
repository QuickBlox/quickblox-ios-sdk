//
//  QBAIAnswerAssistHistoryMessageProtocol.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <QuickBlox/QBAIRoleType.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBAIAnswerAssistHistoryMessageProtocol <NSObject>

@required
/**
 The role of the message sender. Can be a user or assistant.
 */
@property (readonly) QBAIRoleType role;

/**
 Message text in conversation history.
 */
@property (readonly) NSString *message;

@end

NS_ASSUME_NONNULL_END
