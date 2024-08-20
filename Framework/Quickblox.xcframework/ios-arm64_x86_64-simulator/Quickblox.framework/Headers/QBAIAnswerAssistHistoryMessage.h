//
//  QBAIAnswerAssistHistoryMessage.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <QuickBlox/QBAIAnswerAssistHistoryMessageProtocol.h>
#import <QuickBlox/QBCEntity.h>
#import <QuickBlox/QBAIRoleType.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBAIAnswerAssistHistoryMessageProtocol;

/**
 QBAIAnswerAssistHistoryMessage class interface.
 This class represents QuickBlox Answer Assist History.
 */
@interface QBAIAnswerAssistHistoryMessage : QBCEntity <QBAIAnswerAssistHistoryMessageProtocol, NSCoding, NSCopying>

/**
 The role of the message sender. Can be a user or assistant.
 */
@property (readonly) QBAIRoleType role;

/**
 Message text in conversation history.
 */
@property (readonly) NSString *message;

// Unavailable initializers
- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;

- (instancetype)initWithRole:(QBAIRoleType)role
                     message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
