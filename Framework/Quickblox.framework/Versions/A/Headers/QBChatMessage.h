//
//  QBChatMessage.h
//  Сhat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBChatMessage structure. Represents message object for peer-to-peer chat.
 Please set only text, recipientID & senderID values since ID is setted automatically by QBChat
 */

@interface QBChatMessage : NSObject <NSCoding, NSCopying>

/**
 Unique identifier of message (sequential number)
 */
@property (nonatomic, copy) NSString *ID;

/**
 Message text
 */
@property (nonatomic, copy) NSString *text;

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
@property (nonatomic, retain) NSDate *dateSent;

/**
 Message custom parameters. Don't use 'body' & 'delay' as keys for parameters.
 */
@property (nonatomic, retain) NSMutableDictionary *customParameters;

/**
 Array of attachments. Array of QBChatAttachment instances.
 */
@property (nonatomic, retain) NSArray *attachments;

/**
 Message sender nick, use only for group Chat 
 */
@property (nonatomic, copy) NSString *senderNick;

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
@property (nonatomic, copy) NSString *dialogID;

/** Created date */
@property (nonatomic, retain) NSDate *createdAt;

/** Updated date */
@property (nonatomic, retain) NSDate *updatedAt;

/** 'Read' status of a message */
@property (nonatomic, getter = isRead) BOOL read;

/** The array if users' ids who read this message. */
@property (nonatomic, retain) NSArray *readIDs;

/** Create new message
 @return New instance of QBChatMessage
 */
+ (instancetype)message;

/** Create new markabe message
 @return New instance of QBChatMessage
 */
+ (instancetype)markableMessage;

@end
