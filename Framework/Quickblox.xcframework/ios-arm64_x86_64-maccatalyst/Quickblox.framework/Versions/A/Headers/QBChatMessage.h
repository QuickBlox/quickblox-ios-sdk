//
//  QBChatMessage.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBChatAttachment;

NS_ASSUME_NONNULL_BEGIN

/**
 QBChatMessage structure. Represents message object for peer-to-peer chat.
 Please set only text, recipientID & senderID values since ID is setted 
 automatically by QBChat
 */
@interface QBChatMessage : NSObject <NSCoding, NSCopying>

/**
 Unique identifier of message (sequential number).
 */
@property (nonatomic, copy, nullable) NSString *ID;

/**
 Message text.
 */
@property (nonatomic, copy, nullable) NSString *text;

/**
 Message receiver ID
 */
@property (nonatomic, assign) NSUInteger recipientID;

/**
 Message sender ID.
 
 @discussion Use only for 1-1 Chat.
 */
@property (nonatomic, assign) NSUInteger senderID;

/**
 Sender resource
 */
@property (nonatomic, copy, nullable) NSString *senderResource;

/**
 Is message carbon
 */
@property (nonatomic, assign, readonly) BOOL carbon;

/// The date when the message was sent.
///
/// This property is automatically populated when calling the `dialog.send(message)` method.
/// To use a custom value for this property, the `setDateSentEnforced:` method should be used.
@property (nonatomic, strong, nullable) NSDate *dateSent;

/// Sets a custom sent date for the message.
///
/// @param dateSent A non-null date to set as the sent time for the message.
///
/// This method allows specifying a custom value for the sent date instead of the
/// automatically populated date from the `dialog.send(message)` method.
- (void)setDateSentEnforced:(NSDate *)dateSent;

/**
 Message custom parameters. Don't use 'body' & 'delay' as keys for parameters.
 */
@property (nonatomic, strong, null_resettable) NSMutableDictionary<NSString *, NSString *> *customParameters;

/**
 Array of attachments. Array of QBChatAttachment instances.
 */
@property (nonatomic, strong, nullable) NSArray <QBChatAttachment *> *attachments;

/**
 Determines whether message was delayed.
 */
@property (nonatomic, assign) BOOL delayed;

/**
 Determines whether message is markable.
 */
@property (nonatomic, assign) BOOL markable;

/**
 Unique identifier of chat dialog.
 */
@property (nonatomic, copy, nullable) NSString *dialogID;

/**
 Created date.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/**
 Updated date.
 */
@property (nonatomic, strong, nullable) NSDate *updatedAt;

/**
 The array of user's ids who read this message.
 */
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *readIDs;

/**
 The array of user's ids who received this message.
 */
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *deliveredIDs;

/**
 Create new message.
 
 @return new QBChatMessage instance
 */
+ (instancetype)message;

/**
 Create new markable message.
 @return new markable QBChatMessage instance
 */
+ (instancetype)markableMessage;

@end

NS_ASSUME_NONNULL_END
