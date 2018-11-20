//
//  QBChatDialog.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QBChatMessage;

typedef NS_ENUM(NSUInteger, QBChatDialogType) {
    
    QBChatDialogTypePublicGroup = 1,
    QBChatDialogTypeGroup = 2,
    QBChatDialogTypePrivate = 3,
};

NS_ASSUME_NONNULL_BEGIN


typedef void(^QBChatCompletionBlock)(NSError * _Nullable error);
typedef void(^QBUserIDBlock)(NSUInteger userID);
typedef void(^QBOnlineUsersBlock)(NSMutableArray <NSNumber *> * _Nullable onlineUsers, NSError * _Nullable error);

/**
 The QBChatDialog class interface.
 This class represents chat dialog model from server.
 
 @see http://quickblox.com/developers/Chat#Dialog_model
 */
@interface QBChatDialog : NSObject <NSCoding, NSCopying>

/**
 The dialog ID.
 */
@property (nonatomic, copy, readonly, nullable) NSString *ID;

/**
 The date of the dialog creation.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/**
 The date of the dialog update.
 */
@property (nonatomic, strong, nullable) NSDate *updatedAt;

/**
 The Room JID.
 
 @note If chat dialog is private, room JID will be nil.
 */
@property (nonatomic, copy, readonly, nullable) NSString *roomJID;

/**
 The type of the dialog.
 
 @see QBChatDialogType
 */
@property (nonatomic, readonly) QBChatDialogType type;

/**
 The name of the Group dialog.
 
 @note If chat type is private, name will be nil.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 The phone of the Group dialog.
 
 @discussion Can contain a link to a file in Content module, Custom Objects module or just a web link.
 */
@property (nonatomic, copy, nullable) NSString *photo;

/**
 The Last message text of the dialog.
 */
@property (nonatomic, copy, nullable) NSString *lastMessageText;

/**
 The Date of the last message in the dialog.
 */
@property (nonatomic, strong, nullable) NSDate *lastMessageDate;

/**
 The Sender user ID of last message in current chat dialog.
 */
@property (nonatomic, assign) NSUInteger lastMessageUserID;

/**
 The last message ID
 */
@property (nonatomic, copy, nullable) NSString *lastMessageID;

/**
 The Number of unread messages in the dialog.
 */
@property (nonatomic, assign) NSUInteger unreadMessagesCount;

/**
 The Array of occupatns (users') ids in the dialog.
 
 @note For private chat dialog count is 2.
 */
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *occupantIDs;

/**
 The dictionary that represents the custom data.
 
 @see https://quickblox.com/developers/SimpleSample-chat_users-ios#Custom_parameters
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *data;

/**
 The user id of the dialog's owner.
 */
@property (nonatomic, assign) NSUInteger userID;

/**
 The Recipient (user) ID for the private dialog.
 
 @note ID of a recipient if type = QBChatDialogTypePrivate. -1 otherwise. Will always return -1 if QBSession currentUser is nil.
 
 @discussion Will be retrieved from 'QBSession.currentSession.currentUser' by subtracting currentUser.ID from occupantsIDs.
 */
@property (nonatomic, readonly) NSInteger recipientID;

/**
 The Occupants (users) ids to be pushed (added) to the dialog.
 */
@property (strong, nonatomic, nullable) NSArray<NSString *> *pushOccupantsIDs;

/**
 The Occupants (users) ids to be pulled (removed) from the dialog.
 */
@property (strong, nonatomic, nullable) NSArray<NSString *> *pullOccupantsIDs;

/**
 Called whenever sent message was blocked on server.
 */
@property (nonatomic, copy, nullable) QBChatCompletionBlock onBlockedMessage;

/**
 Called whenever user is typing in current dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onUserIsTyping;

/**
 Called whenever user has stopped typing in current dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onUserStoppedTyping;

/**
 Called whenever occupant has joined to the current Group or Public group dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onJoinOccupant;

/**
 Called whenever occupant has left the current Group or Public group dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onLeaveOccupant;

/**
 Called whenever occupant has updated his presence status in the current Group or Public group dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onUpdateOccupant;

// Unavailable initializers
- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;

/**
 Init with dialog ID and type.
 
 @param dialogID dialog ID string
 @param type dialog type
 
 @see QBChatDialogType
 
 @discussion Pass nil for dialogID if you are creating a new dialog.
 
 @return QBChatDialog instance.
 */
- (instancetype)initWithDialogID:(nullable NSString *)dialogID type:(QBChatDialogType)type;

//MARK: - Send message

/**
 Sends chat message with completion block.
 
 @param message    Chat message to send.
 @param completion Completion block with failure error.
 */
- (void)sendMessage:(QBChatMessage *)message completionBlock:(nullable QBChatCompletionBlock)completion;

/**
 Sends group chat message to room, without room join.
 
 @param message      Chat message to send
 @param completion   Completion block with failure error.
 
 @note Available only for 'Enterprise' clients.
 
 @see http://quickblox.com/enterprise/
 */
- (void)sendGroupChatMessageWithoutJoin:(QBChatMessage *)message completion:(nullable QBChatCompletionBlock)completion;

//MARK: - Join/leave

/**
 Join status of the room
 
 @return YES if user is joined to room, otherwise - no.
 */
- (BOOL)isJoined;

/**
 Join to room.
 
 @param completion  Completion block with failure error.
 */
- (void)joinWithCompletionBlock:(nullable QBChatCompletionBlock)completion;

/**
 Leave joined room.
 
 @param completion  Completion block with failure error.
 */
- (void)leaveWithCompletionBlock:(nullable QBChatCompletionBlock)completion;

/**
 Clears dialog occupants status blocks.
 
 @discussion Call this method if you don't want to recieve join/leave/update for this dialog.
 */
- (void)clearDialogOccupantsStatusBlock;

//MARK: - Users status

/**
 Requests users who are joined to room.
 
 @param completion Completion block with failure error and array of user ids.
 */
- (void)requestOnlineUsersWithCompletionBlock:(nullable QBOnlineUsersBlock)completion;

//MARK: - Now typing

/**
 Sends is typing message to occupants.
 
 @note Available only for 'Enterprise' clients.
 
 @see http://quickblox.com/enterprise/
 */
- (void)sendUserIsTypingWithoutJoin;

/**
 Sends is typing message to occupants.
 */
- (void)sendUserIsTyping;

/**
 Sends stopped typing message to occupants.
 */
- (void)sendUserStoppedTyping;

/**
 Sends stopped typing message to occupants.
 
 @note Available only for 'Enterprise' clients.
 
 @see http://quickblox.com/enterprise/
 */
- (void)sendUserStoppedTypingWithoutJoin;

/**
 Clears typing status blocks.
 
 @discussion Call this method if you don't want to recieve typing statuses for this dialog.
 */
- (void)clearTypingStatusBlocks;

@end

NS_ASSUME_NONNULL_END
