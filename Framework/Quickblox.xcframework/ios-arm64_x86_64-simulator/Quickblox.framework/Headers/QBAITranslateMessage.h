//
//  QBAITranslateMessage.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <QuickBlox/QBCEntity.h>
#import <QuickBlox/QBAITranslateMessageProtocol.h>

NS_ASSUME_NONNULL_BEGIN

/**
 QBAnswerAssist class interface.
 This class represents QuickBlox Answer Assist Message.
 */
@interface QBAITranslateMessage : QBCEntity <QBAITranslateMessageProtocol, NSCoding, NSCopying>

/**
 ID of Smart Chat Assistan of Your Application in QuickBlox Dashboard.
 */
@property (readonly) NSString *smartChatAssistantId;

/**
 Text to translate.
 */
@property (readonly) NSString *message;

/**
 Translation language code..
 */
@property (readonly) NSString *languageCode;

// Unavailable initializers
- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;

- (instancetype)initWithMessage:(NSString *)message
           smartChatAssistantId:(NSString *)smartChatAssistantId
                   languageCode:(NSString *)languageCode;

@end

NS_ASSUME_NONNULL_END
