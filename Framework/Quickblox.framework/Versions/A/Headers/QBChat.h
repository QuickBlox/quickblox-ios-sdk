//
//  QBChat.h
//  Chat
//
//  Copyright 2013 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatEnums.h"

@protocol QBChatDelegate;
@class QBUUser;
@class QBContactList;
@class QBChatMessage;
@class QBChatRoom;
@class QBChatDialog;
@class QBPrivacyList;

/**
 QBChatServiceError enum defines following connection error codes:
 QBChatServiceErrorConnectionRefused - Connection with server is not available
 QBChatServiceErrorConnectionClosed  - Chat service suddenly became unavailable
 QBChatServiceErrorConnectionTimeout - Connection with server timed out
 */
typedef enum QBChatServiceError {
    QBChatServiceErrorConnectionClosed = 1,
    QBChatServiceErrorConnectionTimeout
} QBChatServiceError;

/** QBChat class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Chat API. */

@interface QBChat : NSObject 

/** Contact list */
@property (nonatomic, readonly) QBContactList *contactList;

/** Enable or disable message carbons */
@property (nonatomic, assign, getter = isCarbonsEnabled) BOOL carbonsEnabled;

/** Enable or disable Stream Management (XEP-0198) */
@property (nonatomic, assign, getter = isStreamManagementEnabled) BOOL streamManagementEnabled;

/** Enable or disable Stream Resumption (XEP-0198). Works only if streamManagementEnabled=YES. */
@property (nonatomic, assign, getter = isStreamResumptionEnabled) BOOL streamResumptionEnabled;

/** The timeout value for Stream Management send a message operation */
@property (nonatomic, assign) int streamManagementSendMessageTimeout;

/** Enable or disable auto reconnect */
@property (nonatomic, assign, getter = isAutoReconnectEnabled) BOOL autoReconnectEnabled;

/** A reconnect timer may optionally be used to attempt a reconnect periodically.
  The default value is 5 seconds */
@property (nonatomic, assign) NSTimeInterval reconnectTimerInterval;

/** Background mode for stream. By default is NO. Should be set before login to chat. Does not work on simulator. */
@property (nonatomic, assign, getter = isBackgroundingEnabled) BOOL backgroundingEnabled;

- (id)init __attribute__((unavailable("'init' is not a supported initializer for this class.")));

#pragma mark -
#pragma mark Multicaste Delegate

/** 
 Adds the given delegate implementation to the list of observers
 
 @param delegate The delegate to add
 */
- (void)addDelegate:(id<QBChatDelegate>)delegate;

/** 
 Removes the given delegate implementation from the list of observers
 
 @param delegate The delegate to remove
 */
- (void)removeDelegate:(id<QBChatDelegate>)delegate;

/** Removes all delegates */
- (void)removeAllDelegates;

/** Array of all delegates*/
- (NSArray *)delegates;


#pragma mark -
#pragma mark Reconnection

/**
 Run force reconnect. This method disconnects from chat and runs reconnection logic. Works only if autoReconnectEnabled=YES. Otherwise it does nothing.
 */
- (void)forceReconnect;


#pragma mark -
#pragma mark Base Messaging

/**
 Get QBChat singleton
 
 @return QBChat Chat service singleton
 */
+ (instancetype)instance;

/**
 Authorize on QuickBlox Chat
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password;
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)loginWithUser:(QBUUser *)user;

/**
 Authorize on QuickBlox Chat
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password.
 @param resource The resource identifier of user.
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)loginWithUser:(QBUUser *)user resource:(NSString *)resource;

/**
 Check if current user logged into Chat
 
 @return YES if user is logged in, NO otherwise
 */
- (BOOL)isLoggedIn;

/**
 Logout current user from Chat
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)logout;

/**
 Send "Read message" status back to sender
 
 @param message original message received from user
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)readMessage:(QBChatMessage *)message;

/**
 Send presence message. Session will be closed in 90 seconds since last activity.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresence;

/**
 Send presence message with status. Session will be closed in 90 seconds since last activity.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithStatus:(NSString *)status;

/**
 Send direct presence message with status to user. User must be in your contact list.
 
 @warning *Deprecated in QB iOS SDK 2.3:* Will be removed in future.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendDirectPresenceWithStatus:(NSString *)status toUser:(NSUInteger)userID __attribute__((deprecated("Will be removed in future")));;

/**
 Get current chat user
 
 @return An instance of QBUUser
 */
- (QBUUser *)currentUser;


#pragma mark -
#pragma mark Contact list

/**
 Add user to contact list request
 
 @param userID ID of user which you would like to add to contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)addUserToContactListRequest:(NSUInteger)userID;

/**
 Add user to contact list request
 
 @param userID ID of user which you would like to add to contact list
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)addUserToContactListRequest:(NSUInteger)userID sentBlock:(void (^)(NSError *error))sentBlock;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)removeUserFromContactList:(NSUInteger)userID;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)removeUserFromContactList:(NSUInteger)userID sentBlock:(void (^)(NSError *error))sentBlock;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID sentBlock:(void (^)(NSError *error))sentBlock;

/**
 Reject add to contact list request or cancel previously-granted subscription request 
 
 @param userID ID of user from which you would like to reject add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID;

/**
 Reject add to contact list request or cancel previously-granted subscription request
 
 @param userID ID of user from which you would like to reject add to contact request
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID sentBlock:(void (^)(NSError *error))sentBlock;

#pragma mark -
#pragma mark Privacy

/**
 Retrieve a privacy list by name. QBChatDelegate's method 'didReceivePrivacyList:' will be called if success or 'didNotReceivePrivacyListWithName:error:' if there is an error
 @param privacyListName name of privacy list
 */
- (void)retrievePrivacyListWithName:(NSString *)privacyListName;

/**
 Retrieve privacy list names. QBChatDelegate's method 'didReceivePrivacyListNames:' will be called if success or 'didNotReceivePrivacyListNamesDueToError:' if there is an error
 */
- (void)retrievePrivacyListNames;

/**
 Create/edit a privacy list. QBChatDelegate's method 'didReceivePrivacyList:' will be called
 
 @param privacyList instance of QBPrivacyList
 */
- (void)setPrivacyList:(QBPrivacyList *)privacyList;

/**
 Set an active privacy list. QBChatDelegate's method 'didSetActivePrivacyListWithName:' will be called if success or 'didNotSetActivePrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)setActivePrivacyListWithName:(NSString *)privacyListName;

/**
 Set a default privacy list. QBChatDelegate's method 'didSetDefaultPrivacyListWithName:' will be called if success or 'didNotSetDefaultPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)setDefaultPrivacyListWithName:(NSString *)privacyListName;

/**
 Remove a privacy list. QBChatDelegate's method 'didRemovedPrivacyListWithName:' will be called if success or 'didNotSetPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)removePrivacyListWithName:(NSString *)privacyListName;


#pragma mark -
#pragma mark Typing Status

/**
 Send a chat status "user is typing" to user with given ID
 
 @param userID user ID
 */
- (void)sendUserIsTypingToUserWithID:(NSUInteger)userID;

/**
 Send a chat status "user stop typing" to user with given ID
 
 @param userID user ID
 */
- (void)sendUserStopTypingToUserWithID:(NSUInteger)userID;

#pragma mark -
#pragma mark System Messages

/**
 *  Send system message to dialog.
 *
 *  @param message Chat message to send.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendSystemMessage:(QBChatMessage *)message;

@end


#pragma mark -
#pragma mark Deprecated

@interface QBChat (Deprecated)

/** QBChat delegate for callbacks
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use addDelegate: instead
 */
@property (weak, nonatomic) id <QBChatDelegate> delegate __attribute__((deprecated("Use addDelegate: instead")));


/**
 Send chat message to room
 
 @warning Deprecated in 2.3. Use 'sendMessage:' in QBChatDialog class.
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendChatMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)room __attribute__((deprecated("Use 'sendMessage:' in QBChatDialog class.")));

/**
 Send message

 @warning Deprecated in 2.3. Use 'sendMessage:' in QBChatDialog class.
 
 @param message QBChatMessage instance
 @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message __attribute__((deprecated("Use 'sendMessage:' in QBChatDialog class.")));

/**
 Send message with 'sent' block
 
 @warning Deprecated in 2.3. Use 'sendMessage:sentBlock:' in QBChatDialog class.
 
 @param message QBChatMessage instance
 @param sentBlock The block which informs whether a message was delivered to server or not. nil if no errors.
 @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message sentBlock:(void (^)(NSError *error))sentBlock __attribute__((deprecated("Use 'sendMessage:sentBlock:' in QBChatDialog class.")));

/**
 *Available only for 'Enterprise' clients.* Send chat message to room, without room join
 
 @warning Deprecated in 2.3. Use 'sendGroupChatMessageWithoutJoin:' in QBChatDialog class.
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendChatMessageWithoutJoin:(QBChatMessage *)message toRoom:(QBChatRoom *)room __attribute__((deprecated("Use 'sendGroupChatMessageWithoutJoin:' in QBChatDialog class.")));

/**
 Join room. QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @warning Deprecated in 2.3. Use 'join' in QBChatDialog class.
 
 @param room Room to join
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)joinRoom:(QBChatRoom *)room __attribute__((deprecated("Use 'join' in QBChatDialog class.")));

/**
 Join room. QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @warning Deprecated in 2.3. Use 'join' in QBChatDialog class..
 
 @param room Room to join
 @param historyAttribute Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)joinRoom:(QBChatRoom *)room historyAttribute:(NSDictionary *)historyAttribute __attribute__((deprecated("Use 'join' in QBChatDialog class.")));

/**
 Leave joined room. QBChatDelegate's method 'chatRoomDidLeave:' will be called
 
 @warning Deprecated in 2.3. Use 'leave' in QBChatDialog class.
 
 @param room Room to leave
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)leaveRoom:(QBChatRoom *)room __attribute__((deprecated("Use 'leave' in QBChatDialog class.")));

/**
 Request users who are joined a room. QBChatDelegate's method 'chatRoomDidReceiveListOfOnlineUsers:room:' will be called
 
 @warning Deprecated in 2.3. Use 'requestOnlineUsers' in QBChatDialog class.
 
 @param room Room
 @return YES if the request was sent successfully. If not - see log.
 */

- (BOOL)requestRoomOnlineUsers:(QBChatRoom *)room __attribute__((deprecated("Use 'requestOnlineUsers' in QBChatDialog class.")));

/**
 Send presence with parameters to room
 
 @warning Deprecated in 2.3. Will be removed in future.
 
 @param parameters Presence parameters
 @param room Room to send presence
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithParameters:(NSDictionary *)parameters toRoom:(QBChatRoom *)room __attribute__((deprecated("Will be removed in future")));

/**
 Send presence with status, show, priority, custom parameters to room
 
 @warning Deprecated in 2.3. Will be removed in future.
 
 @param status Element contains character data specifying a natural-language description of availability status
 @param show Element contains non-human-readable character data that specifies the particular availability status of an entity or specific resource.
 @param priority Element contains non-human-readable character data that specifies the priority level of the resource. The value MUST be an integer between -128 and +127.
 @param customParameters Custom parameters
 @param room Room to send presence
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithStatus:(NSString *)status
                          show:(QBPresenseShow)show
                      priority:(short)priority 
              customParameters:(NSDictionary *)customParameters
                        toRoom:(QBChatRoom *)room __attribute__((deprecated("Will be removed in future")));

@end
