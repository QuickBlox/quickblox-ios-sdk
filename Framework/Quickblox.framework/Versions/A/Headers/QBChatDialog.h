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

typedef void(^QBChatDialogStatusBlock)() ;
typedef void(^QBChatDialogRequestOnlineUsersBlock)(NSMutableArray* onlineUsers) ;

@class QBChatRoom;
@class QBChatMessage;
@interface QBChatDialog : NSObject <NSCoding, NSCopying>

/** Object ID */
@property (nonatomic, retain) NSString *ID;

/** Created date */
@property (nonatomic, retain) NSDate *createdAt;

/** Room JID. If private chat, room JID will be nil */
@property (nonatomic, retain) NSString *roomJID;

/** Chat type: Private/Group/PublicGroup */
@property (nonatomic) enum QBChatDialogType type;

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

/** ID of a recipient if type = QBChatDialogTypePrivate. -1 otherwise or if you aren't logged in to Chat.  */
@property (nonatomic, readonly) NSInteger recipientID;

/** Returns an autoreleased instance of QBChatRoom to join if type = QBChatDialogTypeGroup or QBChatDialogTypePublicGroup. nil otherwise. */
@property (nonatomic, readonly) QBChatRoom *chatRoom;

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

/** Constructor */
- (instancetype)initWithDialogID:(NSString *)dialogID;

/** Occupants ids to push. Use for update dialog */
- (void)setPushOccupantsIDs:(NSArray *)occupantsIDs;
- (NSArray *)pushOccupantsIDs;

/** Occupants ids to pull. Use for update dialog */
- (void)setPullOccupantsIDs:(NSArray *)occupantsIDs;
- (NSArray *)pullOccupantsIDs;

#pragma mark - Send message

/**
 *  Send group chat message to room.
 *
 *  @param message Chat message to send
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendGroupChatMessage:(QBChatMessage *)message;

/**
 *  Send private chat message
 *
 *  @param message Chat message to send
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendPrivateChatMessage:(QBChatMessage *)message;

/**
 *  Send private chat message with sent block
 *
 *  @param message   Chat message to send
 *  @param sentBlock The block which informs whether a message was delivered to server or not. nil if no errors.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendPrivateChatMessage:(QBChatMessage *)message sentBlock:(void (^)(NSError *error))sentBlock;

/**
 Send group chat message to room, without room join
 
 @param message Chat message to send
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendGroupChatMessageWithoutJoin:(QBChatMessage *)message;

#pragma mark - Join/leave

/**
 *  Join to room. 'onJoin' block will be called.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)join;

/**
 *  Join to room. 'onJoin' block will be called.
 *
 *  @param historyAttributes Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)joinWithHistoryAttributes:(NSDictionary *)historyAttributes;

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

#pragma mark - Presences

/**
 *  Send presence with parameters to room.
 *
 *  @param parameters Presence parameters.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithParameters:(NSDictionary *)parameters;

/**
 *   Send presence with status, show, priority, custom parameters to room
 *
 *  @param status           Element contains character data specifying a natural-language description of availability status
 *  @param show             Element contains non-human-readable character data that specifies the particular availability status of an entity or specific resource.
 *  @param priority         Element contains non-human-readable character data that specifies the priority level of the resource. The value MUST be an integer between -128 and +127.
 *  @param customParameters Custom parameters
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithStatus:(NSString *)status
                          show:(enum QBPresenseShow)show
                      priority:(short)priority
              customParameters:(NSDictionary *)customParameters;
@end
