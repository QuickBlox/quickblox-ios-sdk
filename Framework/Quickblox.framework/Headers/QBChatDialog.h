//
//  QBChatDialog.h
//  Quickblox
//
//  Created by Igor Alefirenko on 23/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import "ChatEnums.h"

typedef void(^QBChatDialogStatusBlock)() DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatCompletionBlock instead.");
typedef void(^QBChatDialogRequestOnlineUsersBlock)(NSMutableArray QB_GENERIC(NSNumber *) * QB_NULLABLE_S onlineUsers) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatDialogRequestOnlineUsersCompletionBlock instead.");
typedef void(^QBChatDialogJoinFailedBlock)(NSError * QB_NULLABLE_S error) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatCompletionBlock instead.");
typedef void(^QBChatDialogIsTypingBlock)(NSUInteger userID) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatDialogUserBlock instead.");
typedef void(^QBChatDialogStoppedTypingBlock)(NSUInteger userID) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatDialogUserBlock instead.");
typedef void(^QBChatDialogOccupantJoinBlock)(NSUInteger userID) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatDialogUserBlock instead.");
typedef void(^QBChatDialogOccupantLeaveBlock)(NSUInteger userID) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatDialogUserBlock instead.");
typedef void(^QBChatDialogOccupantUpdateBlock)(NSUInteger userID) DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use QBChatDialogUserBlock instead.");

@class QBChatMessage;

@interface QBChatDialog : NSObject <NSCoding, NSCopying>

/** Object ID */
@property (nonatomic, retain, readonly, QB_NULLABLE_PROPERTY) NSString *ID;

/** Created date */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *createdAt;

/** Updated date */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *updatedAt;

/** Room JID. If private chat, room JID will be nil */
@property (nonatomic, retain, readonly, QB_NULLABLE_PROPERTY) NSString *roomJID;

/** Chat type: Private/Group/PublicGroup */
@property (nonatomic, readonly) QBChatDialogType type;

/** Group chat name. If chat type is private, name will be nil */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *name;

/** Group chat photo. Can contain a link to a file in Content module, Custom Objects module or just a web link. */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *photo;

/** Last message text in private or group chat */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSString *lastMessageText;

/** Date of last message in private or group chat */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDate *lastMessageDate;

/** User ID of last opponent in private or group chat */
@property (nonatomic, assign) NSUInteger lastMessageUserID;

/** Number of unread messages in this dialog */
@property (nonatomic, assign) NSUInteger unreadMessagesCount;

/** Array of user ids in chat. For private chat count = 2 */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(NSNumber *) *occupantIDs;

/** The dictionary with data */
@property (nonatomic, retain, QB_NULLABLE_PROPERTY) NSDictionary QB_GENERIC(NSString *, id) *data;

/** 
 * Dialog owner
 */
@property (nonatomic, assign) NSUInteger userID;

/** 
 * ID of a recipient if type = QBChatDialogTypePrivate. -1 otherwise. Will always return -1 if QBSession currentUser is nil.  
 * Will be retrieved from [[QBSession currentSession] currentUser] by subtracting currentUser.ID from occupantsIDs.
 */
@property (nonatomic, readonly) NSInteger recipientID;

/**
 * Occupants ids to push. Use this method to add occupants to the dialog
 */
@property (strong, nonatomic, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(NSString *) *pushOccupantsIDs;

/**
 * Occupants ids to pull. Use this method to delete occupants from the dialog
 */
@property (strong, nonatomic, QB_NULLABLE_PROPERTY) NSArray QB_GENERIC(NSString *) *pullOccupantsIDs;

/**
 *  Fired when sent message was blocked on server.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatCompletionBlock onBlockedMessage;

/**
 *  Fired when user is typing in dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogUserBlock onUserIsTyping;

/**
 *  Fired when user has stopped typing in dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogUserBlock onUserStoppedTyping;

/**
 *  Fired when occupant has joined to Group or Public group dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogUserBlock onJoinOccupant;

/**
 *  Fired when occupant has left the Group or Public group dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogUserBlock onLeaveOccupant;

/**
 *  Fired when occupant has updated his presence status in the Group or Public group dialog.
 */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) QBChatDialogUserBlock onUpdateOccupant;

/**  Constructor */
- (QB_NONNULL instancetype)initWithDialogID:(QB_NULLABLE NSString *)dialogID type:(enum QBChatDialogType)type;

/**
 *  'init' is not a supported initializer for this class.
 */
- (QB_NONNULL id)init NS_UNAVAILABLE;

/**
 *  'new' is not a supported initializer for this class.
 */
+ (QB_NONNULL id)new NS_UNAVAILABLE;

#pragma mark - Send message

/**
 *  Send chat message with completion block.
 *
 *  @param message    Chat message to send.
 *  @param completion Completion block with failure error.
 */
- (void)sendMessage:(QB_NONNULL QBChatMessage *)message completionBlock:(QB_NULLABLE_S QBChatCompletionBlock)completion;

/**
 *  Available only for 'Enterprise' clients.* Send group chat message to room, without room join
 *
 *  @param message      Chat message to send
 *  @param completion   Completion block with failure error.
 */
- (void)sendGroupChatMessageWithoutJoin:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark - Join/leave

/**
 *  Join status of the room
 *
 *  @return YES if user is joined to room, otherwise - no.
 */
- (BOOL)isJoined;

/**
 *  Join to room.
 *
 *  @param completion  Completion block with failure error.
 */
- (void)joinWithCompletionBlock:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Leave joined room.
 *
 *  @param completion  Completion block with failure error.
 */
- (void)leaveWithCompletionBlock:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Clears dialog occupants status blocks. Call this method if you don't want to recieve join/leave/update for this dialog.
 */
- (void)clearDialogOccupantsStatusBlock;

#pragma mark - Users status

/**
 *  Requests users who are joined to room. 'onReceiveListOfOnlineUsers' block will be called.
 *
 *  @param completion  Completion block with failure error and array of user ids.
 */
- (void)requestOnlineUsersWithCompletionBlock:(QB_NULLABLE QBChatDialogRequestOnlineUsersCompletionBlock)completion;

#pragma mark - Now typing

/**
 *  Available only for 'Enterprise' clients.*
 *  
 *  Send is typing message to occupants.
 */
- (void)sendUserIsTypingWithoutJoin;

/**
 *  Send is typing message to occupants.
 */
- (void)sendUserIsTyping;

/**
 *  Send stopped typing message to occupants.
 */
- (void)sendUserStoppedTyping;

/**
 *  Available only for 'Enterprise' clients.*
 *
 *  Send stopped typing message to occupants.
 */
- (void)sendUserStoppedTypingWithoutJoin;

/**
 *  Clears typing status blocks. Call this method if you don't want to recieve typing statuses for this dialog.
 */
- (void)clearTypingStatusBlocks;

@end
