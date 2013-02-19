//
//  QBChat.h
//  Chat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBChatServiceError enum defines following connection error codes:
 QBChatServiceErrorConnectionRefused - Connection with server is not available
 QBChatServiceErrorConnectionClosed  - Chat service suddenly became unavailable
 QBChatServiceErrorConnectionTimeout - Connection with server timed out
 */
typedef enum QBChatServiceError {
    QBChatServiceErrorConnectionRefused,
    QBChatServiceErrorConnectionClosed,
    QBChatServiceErrorConnectionTimeout
} QBChatServiceError;

/** QBChat class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Chat API. */

@interface QBChat : NSObject{
@private
    id<QBChatDelegate> delegate;
    QBUUser *qbUser;
}


#pragma mark -
#pragma mark Base Messaging

/**
 Get QBChat singleton
 
 @return QBChat Chat service singleton
 */
+ (QBChat *)instance;

/**
 Authorize on QBChat
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password;
 @return NO if user was logged in before method call, YES if user was not logged in
 */
- (BOOL)loginWithUser:(QBUUser *)user;

/**
 Check if current user logged into Chat
 
 @return YES if user is logged in, NO otherwise
 */
- (BOOL)isLoggedIn;

/**
 Logout current user from Chat
 
 @return YES if user was logged in before method call, NO if user was not logged in
 */
- (BOOL)logout;

/**
 Send message
 
 @param message QBChatMessage structure which contains message text and recipient id
 @return YES if user was logged in before method call, NO if user was not logged in
 */
- (BOOL)sendMessage:(QBChatMessage *)message;

/**
 Send presence message to Chat server. Session will be closed in 90 seconds since last activity.
 */
- (BOOL)sendPresence;

/**
 Get current chat user
 
 @return An instance of QBUUser
 */
- (QBUUser *)currentUser;

/**
 QBChat delegate for callbacks
 */
@property (nonatomic, retain) id<QBChatDelegate> delegate;


#pragma mark -
#pragma mark Rooms

/**
 Create room or join if room with this name already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @param name Room name
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 */
- (void)createOrJoinRoomWithName:(NSString *)name membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent;

/**
 Join room. QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @param room Room to join
 */
- (void)joinRoom:(QBChatRoom *)room;

/**
 Leave joined room. QBChatDelegate's method 'chatRoomDidLeave:' will be called
 
 @param room Room to leave
 */
- (void)leaveRoom:(QBChatRoom *)room;

/**
 Send message to room
 
 @param message Message body
 @param room Room to send message
 */
- (void)sendMessage:(NSString *)message toRoom:(QBChatRoom *)room;

/**
 Send request for getting list of public groups. QBChatDelegate's method 'chatDidReceiveListOfRooms:' will be called
 */
- (void)requestAllRooms;

/**
 Send request to adding users to room.
 
 @param usersIDs Array of users' IDs 
 @param room Room in which users will be added
 */
- (void)addUsers:(NSArray *)usersIDs toRoom:(QBChatRoom *)room;

/**
 Request users who are able to join a room. QBChatDelegate's method 'chatRoomDidReceiveListOfUsers:room:' will be called
 */
- (void)requestRoomUsers:(QBChatRoom *)room;

/**
 Send request to remove users from room
 
 @param usersIDs Array of users' IDs
 @param room Room from which users will be removed
 */
- (void)deleteUsers:(NSArray *)usersIDs fromRoom:(QBChatRoom *)room;


#pragma mark -
#pragma mark VideoChat

/**
 Call user
 
 @param userID ID of opponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' value only available now
 */
-(void) callUser:(NSUInteger)userID conferenceType:(enum QBVideoChatConferenceType)conferenceType;

/**
 Accept call
 */
-(void) acceptCall;

/**
 Reject call
 */
-(void) rejectCall;

/**
 Finish call
 */
-(void) finishCall;


#pragma mark -
#pragma mark Deprecated


/**
 @warning *Deprecated in QB iOS SDK 1.5:* You have to use method '- (void)createOrJoinRoomWithName:(NSString *)name membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent' with isMembersOnly=NO and isPersistent=NO params instead
 
 Create public room. QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @param name Room name
 */
- (void)createRoomWithName:(NSString *)name __attribute__((deprecated()));

/**
 @warning *Deprecated in QB iOS SDK 1.5:* You have to use method '- (void)createOrJoinRoomWithName:(NSString *)name membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent' with isMembersOnly=YES and isPersistent=NO params instead
 
 Create private room (only members). QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @param name Room name
 */
- (void)createPrivateRoomWithName:(NSString *)name __attribute__((deprecated()));

@end
