//
//  QBChatMessage.h
//  Сhat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

@class QBChatAttachment;

/**
 QBChatMessage structure. Represents message object for peer-to-peer chat.
 Please set only text, recipientID & senderID values since ID is setted automatically by QBChat
 */

@interface QBChatMessage : NSObject <NSCoding, NSCopying>

/**
 Unique identifier of message (sequential number)
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSString *ID;

/**
 Message text
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSString *text;

/**
 Message receiver ID
 */
@property (nonatomic, assign) NSUInteger recipientID;

/**
 Message sender ID, use only for 1-1 Chat
 */
@property (nonatomic, assign) NSUInteger senderID;

/**
 Message date sent
 */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *dateSent;

/**
 Message custom parameters. Don't use 'body' & 'delay' as keys for parameters.
 */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSMutableDictionary QB_GENERIC(NSString *, NSString *) *customParameters;

/**
 Array of attachments. Array of QBChatAttachment instances.
 */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(QBChatAttachment *) *attachments;

/**
 Message sender nick, use only for group Chat 
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSString *senderNick;

/**
 Is this message delayed
 */
@property (nonatomic, assign) BOOL delayed;

/**
 Mark message as markable
 */
@property (nonatomic, assign) BOOL markable;

/**
 Unique identifier of chat dialog
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSString *dialogID;

/** Created date */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *createdAt;

/** Updated date */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *updatedAt;

/** 'Read' status of a message */
@property (nonatomic, getter = isRead) BOOL read;

/** The array of user's ids who read this message. */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(NSNumber *) *readIDs;

/**
 *  The array of user's ids who received this message.
 */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(NSNumber *) *deliveredIDs;

/** Create new message
 @return New instance of QBChatMessage
 */
+ (QB_NONNULL instancetype)message;

/** Create new markabe message
 @return New instance of QBChatMessage
 */
+ (QB_NONNULL instancetype)markableMessage;

@end
