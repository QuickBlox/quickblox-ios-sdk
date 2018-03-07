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
 *  QBChatDialog class interface.
 *  This class represents chat dialog model from server.
 *
 *  @see http://quickblox.com/developers/Chat#Dialog_model
 */
@interface QBChatDialog : NSObject <NSCoding, NSCopying>

/**
 *  Chat dialog ID.
 */
@property (nonatomic, copy, readonly, nullable) NSString *ID;

/**
 *  Chat dialog creation date.
 */
@property (nonatomic, strong, nullable) NSDate *createdAt;

/**
 *  Chat dialog update date.
 */
@property (nonatomic, strong, nullable) NSDate *updatedAt;

/**
 *  Room JID. 
 *
 *  @note If chat dialog is private, room JID will be nil.
 */
@property (nonatomic, copy, readonly, nullable) NSString *roomJID;

/**
 *  Chat dialog type.
 *
 *  @see QBChatDialogType
 */
@property (nonatomic, readonly) QBChatDialogType type;

/**
 *  Group chat dialog name.
 *
 *  @note If chat type is private, name will be nil.
 */
@property (nonatomic, copy, nullable) NSString *name;

/**
 *  Group chat photo.
 *
 *  @discussion Can contain a link to a file in Content module, Custom Objects module or just a web link.
 */
@property (nonatomic, copy, nullable) NSString *photo;

/**
 *  Last message text for current chat dialog.
 */
@property (nonatomic, copy, nullable) NSString *lastMessageText;

/**
 *  Date of last message in current chat dialog.
 */
@property (nonatomic, strong, nullable) NSDate *lastMessageDate;

/**
 *  Sender user ID of last message in current chat dialog.
 */
@property (nonatomic, assign) NSUInteger lastMessageUserID;

/**
 *  Number of unread messages in current chat dialog.
 */
@property (nonatomic, assign) NSUInteger unreadMessagesCount;

/**
 *  Array of user ids in chat.
 *
 *  @note For private chat dialog count is 2.
 */
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *occupantIDs;

/**
 *  The dictionary with custom data.
 *
 *  @see https://quickblox.com/developers/SimpleSample-chat_users-ios#Custom_parameters
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *data;

/**
 *  Chat dialog owner user ID.
 */
@property (nonatomic, assign) NSUInteger userID;

/**
 *  Recipient ID for private chat dialog.
 *
 *  @note ID of a recipient if type = QBChatDialogTypePrivate. -1 otherwise.
 *  Will always return -1 if QBSession currentUser is nil.
 *
 *  @discussion Will be retrieved from 'QBSession.currentSession.currentUser'
 *  by subtracting currentUser.ID from occupantsIDs.
 */
@property (nonatomic, readonly) NSInteger recipientID;

/**
 *  Occupants ids to push.
 *
 *  @discussion Use this method to add occupants to the dialog.
 */
@property (strong, nonatomic, nullable) NSArray<NSString *> *pushOccupantsIDs;

/**
 *  Occupants ids to pull.
 *
 *  @discussion Use this method to delete occupants from the chat dialog.
 */
@property (strong, nonatomic, nullable) NSArray<NSString *> *pullOccupantsIDs;

/**
 *  Called whenever sent message was blocked on server.
 */
@property (nonatomic, copy, nullable) QBChatCompletionBlock onBlockedMessage;

/**
 *  Called whenever user is typing in current chat dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onUserIsTyping;

/**
 *  Called whenever user has stopped typing in current chat dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onUserStoppedTyping;

/**
 *  Called whenever occupant has joined to the current Group or Public group chat dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onJoinOccupant;

/**
 *  Called whenever occupant has left the current Group or Public group chat dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onLeaveOccupant;

/**
 *  Called whenever occupant has updated his presence status in the current Group or Public group chat dialog.
 */
@property (nonatomic, copy, nullable) QBUserIDBlock onUpdateOccupant;

// Unavailable initializers
- (id)init NS_UNAVAILABLE;
+ (id)new NS_UNAVAILABLE;

/**
 *  Init with dialog ID and type.
 *
 *  @param dialogID dialog ID string
 *  @param type     dialog type
 *
 *  @see QBChatDialogType
 *
 *  @discussion Pass nil for dialogID if you are creating a new dialog.
 *
 *  @return QBChatDialog instance.
 */
- (instancetype)initWithDialogID:(nullable NSString *)dialogID type:(QBChatDialogType)type;

//MARK: - Send message

/**
 *  Send chat message with completion block.
 *
 *  @param message    Chat message to send.
 *  @param completion Completion block with failure error.
 */
- (void)sendMessage:(QBChatMessage *)message completionBlock:(nullable QBChatCompletionBlock)completion;

/**
 *  Send group chat message to room, without room join.
 *
 *  @param message      Chat message to send
 *  @param completion   Completion block with failure error.
 *
 *  @note Available only for 'Enterprise' clients.
 *
 *  @see http://quickblox.com/enterprise/
 */
- (void)sendGroupChatMessageWithoutJoin:(QBChatMessage *)message completion:(nullable QBChatCompletionBlock)completion;

//MARK: - Join/leave

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
- (void)joinWithCompletionBlock:(nullable QBChatCompletionBlock)completion;

/**
 *  Leave joined room.
 *
 *  @param completion  Completion block with failure error.
 */
- (void)leaveWithCompletionBlock:(nullable QBChatCompletionBlock)completion;

/**
 *  Clears dialog occupants status blocks.
 *
 *  @discussion Call this method if you don't want to recieve join/leave/update for this dialog.
 */
- (void)clearDialogOccupantsStatusBlock;

//MARK: - Users status

/**
 *  Requests users who are joined to room.
 *
 *  @param completion  Completion block with failure error and array of user ids.
 */
- (void)requestOnlineUsersWithCompletionBlock:(nullable QBOnlineUsersBlock)completion;

//MARK: - Now typing

/**
 *  Send is typing message to occupants.
 *
 *  @note Available only for 'Enterprise' clients.
 *
 *  @see http://quickblox.com/enterprise/
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
 *  Send stopped typing message to occupants.
 *
 *  @note Available only for 'Enterprise' clients.
 *
 *  @see http://quickblox.com/enterprise/
 */
- (void)sendUserStoppedTypingWithoutJoin;

/**
 *  Clears typing status blocks.
 *
 *  @discussion Call this method if you don't want to recieve typing statuses for this dialog.
 */
- (void)clearTypingStatusBlocks;

@end

NS_ASSUME_NONNULL_END
