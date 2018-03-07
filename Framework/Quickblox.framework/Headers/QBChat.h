//
//  QBChat.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBChatTypes.h>

@protocol QBChatDelegate;

@class QBUUser;
@class QBContactList;
@class QBChatMessage;
@class QBPrivacyList;

NS_ASSUME_NONNULL_BEGIN

/**
 QBChat class interface.
 This class is the main entry point to work with Quickblox Chat API.
 */
@interface QBChat : NSObject

/**
 Get QBChat singleton.
 
 @return QBChat Chat service singleton.
 */
@property (nonatomic, readonly, class) QBChat *instance;

/**
 Determines whether chat is connected. Returns YES if the connection is open, and the stream has
 been properly established.
 
 @discussion If the stream is neither disconnected, nor connected, then a connection is currently
 being established. If this method returns YES, then it is ready for you to start sending and
 receiving elements.
 */
@property (assign, nonatomic, readonly) BOOL isConnected;

/** Returns YES is the connection is currently connecting. */
@property (assign, nonatomic, readonly) BOOL isConnecting;

/** Returns contact list. */
@property (nonatomic, readonly, nullable) QBContactList *contactList;

/** Returns current chat user. */
@property (nonatomic, readonly, copy, nullable) QBUUser *currentUser;

/** Return current resource. */
@property (nonatomic, readonly, copy, nullable) NSString *currentResource;

- (id)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

//MARK: - Multicast Delegate

/**
 Adds the given delegate implementation to the list of observers.
 
 @param delegate The delegate to add.
 */
- (void)addDelegate:(id<QBChatDelegate>)delegate;

/**
 Removes the given delegate implementation from the list of observers.
 
 @param delegate The delegate to remove.
 */
- (void)removeDelegate:(id<QBChatDelegate>)delegate;

/** Removes all delegates. */
- (void)removeAllDelegates;

/** Returns array of all delegates. */
- (NSArray<id <QBChatDelegate>> *)delegates;

@end

//MARK: - Connection

@interface QBChat(Connection)

/**
 Connect to QuickBlox Chat with completion.
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password.
 @param completion Completion block with failure error.
 */
- (void)connectWithUser:(QBUUser *)user
             completion:(nullable QBChatCompletionBlock)completion;

/**
 Connect to QuickBlox Chat.
 
 @param user QBUUser structure represents user's login. Required user's fields: ID, password.
 @param resource The resource identifier of user.
 @param completion Completion block with failure error.
 */
- (void)connectWithUser:(QBUUser *)user
               resource:(nullable NSString *)resource
             completion:(nullable QBChatCompletionBlock)completion;

/**
 Disconnect current user from Chat and leave all rooms.
 
 @param completion  Completion block with failure error.
 */
- (void)disconnectWithCompletionBlock:(nullable QBChatCompletionBlock)completion;

/**
 Run force reconnect. This method disconnects from chat and runs reconnection logic. Works only if
 autoReconnectEnabled=YES. Otherwise it does nothing.
 */
- (void)forceReconnect;

@end

//MARK: User status

@interface QBChat(UserStatus)

/**
 Send presence message with status.
 
 @param status Presence status.
 
 @return YES if the request was sent successfully. Otherwise - see log.
 */
- (BOOL)sendPresenceWithStatus:(NSString *)status;

@end

@interface QBChat(MessagesStatus)

/**
 Send "read" status for message and update "read" status on a server.
 
 @param message QBChatMessage message to mark as read.
 @param completion Completion block with failure error.
 */
- (void)readMessage:(QBChatMessage *)message completion:(nullable QBChatCompletionBlock)completion;

/**
 Send "delivered" status for message.
 
 @param message QBChatMessage message to mark as delivered.
 @param completion Completion block with failure error.
 */
- (void)markAsDelivered:(QBChatMessage *)message completion:(nullable QBChatCompletionBlock)completion;

@end

//MARK: - Privacy

@interface QBChat(Privacy)

/**
 Retrieve a privacy list by name.
 QBChatDelegate's method 'didReceivePrivacyList:' will be called if success or
 'didNotReceivePrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)retrievePrivacyListWithName:(NSString *)privacyListName;

/**
 Retrieve privacy list names.
 QBChatDelegate's method 'didReceivePrivacyListNames:' will be called if success or
 'didNotReceivePrivacyListNamesDueToError:' if there is an error
 */
- (void)retrievePrivacyListNames;

/**
 Create/edit a privacy list.
 QBChatDelegate's method 'didReceivePrivacyList:' will be called
 
 @param privacyList instance of QBPrivacyList
 */
- (void)setPrivacyList:(nullable QBPrivacyList *)privacyList;

/**
 Set a default privacy list.
 QBChatDelegate's method 'didSetDefaultPrivacyListWithName:' will be called if success or
 'didNotSetDefaultPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)setDefaultPrivacyListWithName:(nullable NSString *)privacyListName;

/**
 Remove a privacy list.
 
 QBChatDelegate's method 'didRemovedPrivacyListWithName:' will be called if success or
 'didNotSetPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)removePrivacyListWithName:(NSString *)privacyListName;

@end

//MARK: - System Messages

@interface QBChat(SystemMessage)

/**
 Send system message to dialog.
 
 @param message QBChatMessage instance of message to send.
 @param completion Completion block with failure error.
 */
- (void)sendSystemMessage:(QBChatMessage *)message
               completion:(nullable QBChatCompletionBlock)completion;
@end

//MARK: - Last Activity

@interface QBChat(LastActivity)

/**
 Get Last activity for user with id.
 
 @param userID User ID.
 @param completion completion block with last activity in seconds and error.
 */
- (void)lastActivityForUserWithID:(NSUInteger)userID
                       completion:(QBUserLastActivityCompletionBlock)completion;

/**
 Get Last activity for user with id.
 
 @param userID User ID
 @param timeout timeout
 @param completion Completion block with last activity in seconds and error.
 */
- (void)lastActivityForUserWithID:(NSUInteger)userID
                          timeout:(NSTimeInterval)timeout
                       completion:(QBUserLastActivityCompletionBlock)completion;
@end

//MARK: - Send pings to the server or a userID

@interface QBChat(Ping)

/**
 Send ping to server.
 
 @param completion Completion block with ping time interval and success flag.
 */
- (void)pingServer:(QBPingCompleitonBlock)completion;

/**
 Send ping to server with timeout.
 
 @param timeout Ping timeout.
 @param completion Completion block with ping time interval and success flag.
 */
- (void)pingServerWithTimeout:(NSTimeInterval)timeout completion:(QBPingCompleitonBlock)completion;

/**
 Send ping to user.
 @note You must be subscribed to user in contact list in order to successfully ping him.
 
 @param userID User ID.
 @param completion Completion block with ping time interval and success flag.
 */
- (void)pingUserWithID:(NSUInteger )userID completion:(QBPingCompleitonBlock)completion;

/**
 Send ping to user with timeout.
 @note You must be subscribed to user in contact list in order to successfully ping him.
 
 @param userID User ID.
 @param timeout Timeout in seconds.
 @param completion Completion block with ping time interval and success flag.
 */
- (void)pingUserWithID:(NSUInteger)userID timeout:(NSTimeInterval)timeout completion:(QBPingCompleitonBlock)completion;

@end

//MARK: - Contact list

@interface QBChat(ContactList)
/**
 After establishing a session, a client SHOULD send initial presence to the server in order to signal
 its availability for communications.
 */
@property (assign, nonatomic) BOOL manualInitialPresence;

/**
 Add user to contact list request
 
 @param userID  ID of user which you would like to add to contact list
 @param completion The block which informs whether a request was delivered to server or not. If the request is succeeded error is nil.
 */
- (void)addUserToContactListRequest:(NSUInteger)userID completion:(nullable QBChatCompletionBlock)completion;

/**
 Remove user from contact list.
 
 @param userID ID of user which you would like to remove from contact list
 @param completion The block which informs whether a request was delivered to server or not. If the request is succeeded error is nil.
 */
- (void)removeUserFromContactList:(NSUInteger)userID completion:(nullable QBChatCompletionBlock)completion;

/**
 Confirm add to contact list request.
 
 @param userID ID of user from which you would like to confirm add to contact request.
 @param completion The block which informs whether a request was delivered to server or not. If the request is succeeded error is nil.
 */
- (void)confirmAddContactRequest:(NSUInteger)userID completion:(nullable QBChatCompletionBlock)completion;

/**
 Reject add to contact list request or cancel previously-granted subscription request.
 
 @param userID ID of user from which you would like to reject add to contact request.
 @param completion The block which informs whether a request was delivered to server or not. If therequest is succeeded error is nil.
 */
- (void)rejectAddContactRequest:(NSUInteger)userID completion:(nullable QBChatCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
