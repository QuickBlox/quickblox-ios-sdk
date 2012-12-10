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

/** QBAuth class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Auth module. */

@interface QBChat : NSObject{
@private
    id<QBChatDelegate> delegate;
    QBUUser *qbUser;
}


#pragma mark -
#pragma mark Base IM

/**
 Get QBChatService singleton
 
 @return QBChatService Chat service singleton
 */
+ (QBChat *)instance;

/**
 Authorize on QBChatService
 
 @param user QBUUser structure represents users login. Required user's fields: ID, login, password;
 @return NO if user was logged in before method call, YES if user was not logged in
 */
- (BOOL)loginWithUser:(QBUUser *)user;

/**
 Check if current user logged into QBChatService
 
 @return YES if user is logged in, NO otherwise
 */
- (BOOL)isLoggedIn;

/**
 Logout current user from QBChatService
 
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
 QBChatService delegate for callbacks
 */
@property (nonatomic, assign) id<QBChatDelegate> delegate;


#pragma mark -
#pragma mark Rooms

/**
 Create public room
 */
- (void)createRoomWithName:(NSString *)name;

/**
 Create private room (only members)
 */
- (void)createPrivateRoomWithName:(NSString *)name;

/**
 Join room.
 */
- (void)joinRoom:(QBChatRoom *)room;

/**
 Leave joined room.
 */
- (void)leaveRoom:(QBChatRoom *)room;

/**
 Send message to room.
 */
- (void)sendMessage:(NSString *)msg toRoom:(QBChatRoom *)room;

/**
 Send request for getting list of public groups.
 */
- (void)requestAllRooms;

/**
 Send request to adding users array to room.
 */
- (void)addUsers:(NSArray *)usersIDs toRoom:(QBChatRoom *)room;

/**
 Send request to remove users array from room.
 */
- (void)deleteUsers:(NSArray *)usersIDs fromRoom:(QBChatRoom *)room;

@end
