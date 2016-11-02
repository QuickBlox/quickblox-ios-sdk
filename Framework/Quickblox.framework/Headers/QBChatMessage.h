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

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBChatMessage structure. Represents message object for peer-to-peer chat.
 *  Please set only text, recipientID & senderID values since ID is setted automatically by QBChat
 */
@interface QBChatMessage : NSObject <NSCoding, NSCopying>

/**
 *  Unique identifier of message (sequential number).
 */
@property (nonatomic, copy, nullable) NSString *ID;

/**
 *  Message text.
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 *  Message receiver ID
 */
@property (nonatomic, assign) NSUInteger recipientID;

/**
 *  Message sender ID.
 *  
 *  @discussion Use only for 1-1 Chat.
 */
@property (nonatomic, assign) NSUInteger senderID;

/**
 *  Message date sent.
 */
@property (nonatomic, strong, nullable) NSDate *dateSent;

/**
 *  Message custom parameters. Don't use 'body' & 'delay' as keys for parameters.
 */
@property (nonatomic, strong, null_resettable) NSMutableDictionary QB_GENERIC(NSString *, NSString *) *customParameters;

/**
 *  Array of attachments. Array of QBChatAttachment instances.
 */
@property (nonatomic, strong, nullable) NSArray QB_GENERIC(QBChatAttachment *) *attachments;

/**
 *  Determines whether message was delayed.
 */
@property (nonatomic, assign) BOOL delayed;

/**
 *  Determines whether message is markable.
 */
@property (nonatomic, assign) BOOL markable;

/**
 *  Unique identifier of chat dialog.
 */
@property (nonatomic, copy, nullable) NSString *dialogID;

/**
 *  Created date.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/**
 *  Updated date.
 */
@property (nonatomic, strong, nullable) NSDate *updatedAt;

/**
 *  The array of user's ids who read this message.
 */
@property (nonatomic, copy, nullable) NSArray QB_GENERIC(NSNumber *) *readIDs;

/**
 *  The array of user's ids who received this message.
 */
@property (nonatomic, copy, nullable) NSArray QB_GENERIC(NSNumber *) *deliveredIDs;

/**
 *  Create new message.
 *
 *  @return new QBChatMessage instance
 */
+ (instancetype)message;

/**
 *  Create new markable message.
 *
 *  @return new markable QBChatMessage instance
 */
+ (instancetype)markableMessage;

//MARK: DEPRECATED

/**
 *  'Read' status of a message.
 */
@property (nonatomic, getter = isRead) BOOL read DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.8.0.1 Use 'readIDs' instead.");

@end

NS_ASSUME_NONNULL_END
