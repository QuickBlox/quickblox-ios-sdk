//
//  QBChatDialog.h
//  Quickblox
//
//  Created by Igor Alefirenko on 23/04/2014.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatEnums.h"

extern NSString* const QBChatDialogJoinPrefix;
extern NSString* const QBChatDialogLeavePrefix;
extern NSString* const QBChatDialogOnlineUsersPrefix;
extern NSString* const QBChatDialogOnJoinFailedPrefix;
extern NSString* const QBChatDialogIsTypingPrefix;
extern NSString* const QBChatDialogStopTypingPrefix;

typedef void(^QBChatDialogStatusBlock)() ;
typedef void(^QBChatDialogRequestOnlineUsersBlock)(NSMutableArray* onlineUsers) ;
typedef void(^QBChatDialogJoinFailedBlock)(NSError* error);
typedef void(^QBChatDialogIsTypingBlock)(NSUInteger userID);
typedef void(^QBChatDialogStoppedTypingBlock)(NSUInteger userID);

@class QBChatRoom;
@class QBChatMessage;
@interface QBChatDialog : NSObject <NSCoding, NSCopying>

/** Object ID */
@property (nonatomic, retain, readonly) NSString *ID;

/** Created date */
@property (nonatomic, retain) NSDate *createdAt;

/** Room JID. If private chat, room JID will be nil */
@property (nonatomic, retain) NSString *roomJID;

/** Chat type: Private/Group/PublicGroup */
@property (nonatomic, readonly) QBChatDialogType type;

/** Group chat name. If chat type is private, name will be nil */
@property (nonatomic, retain) NSString *name;

/** Group chat photo. Can contain a link to a file in Content module, Custom Objects module or just a web link. */
@property (nonatomic, retain) NSString *photo;

/** Last message text in private or group chat */
@property (nonatomic, retain) NSString *lastMessageText;

/** Date of last message in private or group chat */
@property (nonatomic, retain) NSDate *lastMessageDate;

/** User ID of last opponent in private or group chat */
@property (nonatomic, assign) NSUInteger lastMessageUserID;

/** Number of unread messages in this dialog */
@property (nonatomic, assign) NSUInteger unreadMessagesCount;

/** Array of user ids in chat. For private chat count = 2 */
@property (nonatomic, retain) NSArray *occupantIDs;

/** The dictionary with data */
@property (nonatomic, retain) NSDictionary *data;

/** Dialog owner */
@property (nonatomic, assign) NSUInteger userID;

/** ID of a recipient if type = QBChatDialogTypePrivate. -1 otherwise.  */
@property (nonatomic, readonly) NSInteger recipientID;

/**
 *  Fired when user joined to room.
 */
@property (nonatomic, copy) QBChatDialogStatusBlock onJoin;
- (void)setOnJoin:(QBChatDialogStatusBlock)anOnJoin;

/**
 *  Fired when user left room.
 */
@property (nonatomic, copy) QBChatDialogStatusBlock onLeave;
- (void)setOnLeave:(QBChatDialogStatusBlock)anOnLeave;

/**
 *  Fired when list of online users received.
 */
@property (nonatomic, copy) QBChatDialogRequestOnlineUsersBlock onReceiveListOfOnlineUsers;
- (void)setOnReceiveListOfOnlineUsers:(QBChatDialogRequestOnlineUsersBlock)anOnReceiveListOfOnlineUsers;

/**
 *  Fired when join to room failed (in most cases if user is not added to the room)
 */
@property (nonatomic, copy) QBChatDialogJoinFailedBlock onJoinFailed;
- (void)setOnJoinFailed:(QBChatDialogJoinFailedBlock)anOnJoinFailed;

/**
 *  Fired when user is typing in dialog.
 */
@property (nonatomic, copy) QBChatDialogIsTypingBlock onUserIsTyping;
- (void)setOnUserIsTyping:(QBChatDialogIsTypingBlock)anOnUserIsTyping;

/**
 *  Fired when user stopped typing in dialog.
 */
@property (nonatomic, copy) QBChatDialogStoppedTypingBlock onUserStoppedTyping;
- (void)setOnUserStoppedTyping:(QBChatDialogStoppedTypingBlock)anOnUserStoppedTyping;

/** Constructor */
- (instancetype)initWithDialogID:(NSString *)dialogID type:(enum QBChatDialogType)type;

- (id)init __attribute__((unavailable("'init' is not a supported initializer for this class.")));
+ (id)new __attribute__((unavailable("'new' is not a supported initializer for this class.")));
/** Occupants ids to push. Use for update dialog */
- (void)setPushOccupantsIDs:(NSArray *)occupantsIDs;
- (NSArray *)pushOccupantsIDs;

/** Occupants ids to pull. Use for update dialog */
- (void)setPullOccupantsIDs:(NSArray *)occupantsIDs;
- (NSArray *)pullOccupantsIDs;

#pragma mark - Send message

/**
 *  Send chat message to dialog.
 *
 *  @param message Chat message to send.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message;

/**
 *  Send chat message with sent block
 *
 *  @param message   Chat message to send
 *  @param sentBlock The block which informs whether a message was delivered to server or not. nil if no errors.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message sentBlock:(void (^)(NSError *error))sentBlock;

/**
 *Available only for 'Enterprise' clients.* Send group chat message to room, without room join
 
 @param message Chat message to send
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendGroupChatMessageWithoutJoin:(QBChatMessage *)message;
#pragma mark - Join/leave

/**
 *  Join status of room
 *
 *  @return YES if user is joined to room, otherwise - no.
 */
- (BOOL)isJoined;

/**
 *  Join to room. 'onJoin' block will be called.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)join;

/**
 *  Leave joined room. 'onLeave' block will be called.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)leave;

#pragma mark - Users status

/**
 *  Requests users who are joined to room. 'onReceiveListOfOnlineUsers' block will be called.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestOnlineUsers;

#pragma mark - Now typing

/**
 *  Send is typing message to occupants.
 */
- (void)sendUserIsTyping;

/**
 *  Send stopped typing message to occupants.
 */
- (void)sendUserStoppedTyping;

/**
 *  Clears typing status blocks. Call this method if you don't want to recieve typing statuses for this dialog.
 */
- (void)clearTypingStatusBlocks;

@end

@interface QBChatDialog (Deprecated)

/** Returns an autoreleased instance of QBChatRoom to join if type = QBChatDialogTypeGroup or QBChatDialogTypePublicGroup. nil otherwise. */
@property (nonatomic, readonly) QBChatRoom *chatRoom;

@end
