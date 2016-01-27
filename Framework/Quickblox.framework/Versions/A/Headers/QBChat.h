//
//  QBChat.h
//  Chat
//
//  Copyright 2013 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatEnums.h"

@protocol QBChatDelegate;
@class QBUUser;
@class QBContactList;
@class QBChatMessage;
@class QBChatDialog;
@class QBPrivacyList;

/** QBChat class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Chat API. */

@interface QBChat : NSObject 

/** Contact list */
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) QBContactList *contactList;

/**
 *  Enable or disable message carbons
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setCarbonsEnabled:] instead.
 */
@property (nonatomic, assign, getter = isCarbonsEnabled) BOOL carbonsEnabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setCarbonsEnabled:] instead");

/**
 *  Enable or disable Stream Resumption (XEP-0198). Works only if streamManagementEnabled=YES.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setStreamResumptionEnabled:] instead.
 */
@property (nonatomic, assign, getter = isStreamResumptionEnabled) BOOL streamResumptionEnabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setStreamResumptionEnabled:] instead");

/**
 *  The timeout value for Stream Management send a message operation
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setStreamManagementSendMessageTimeout:] instead.
 */
@property (nonatomic, assign) int streamManagementSendMessageTimeout DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setStreamManagementSendMessageTimeout:] instead");

/**
 *  Enable or disable auto reconnect
 *  
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setAutoReconnectEnabled:] instead.
 */
@property (nonatomic, assign, getter = isAutoReconnectEnabled) BOOL autoReconnectEnabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setAutoReconnectEnabled:] instead");

/**
 *  A reconnect timer may optionally be used to attempt a reconnect periodically.
 *  The default value is 5 seconds
 *  
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setReconnectTimerInterval:] instead.
 */
@property (nonatomic, assign) NSTimeInterval reconnectTimerInterval DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setReconnectTimerInterval:] instead");

/**
 * Many routers will teardown a socket mapping if there is no activity on the socket.
 * For this reason, the stream supports sending keep-alive data.
 * This is simply whitespace, which is ignored by the protocol.
 *
 * Keep-alive data is only sent in the absence of any other data being sent/received.
 *
 * The default value is 20s.
 * The minimum value for TARGET_OS_IPHONE is 10s, else 20s.
 *
 * To disable keep-alive, set the interval to zero (or any non-positive number).
 *
 * The keep-alive timer (if enabled) fires every (keepAliveInterval / 4) seconds.
 * Upon firing it checks when data was last sent/received,
 * and sends keep-alive data if the elapsed time has exceeded the keepAliveInterval.
 * Thus the effective resolution of the keepalive timer is based on the interval.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use [QBSettings setKeepAliveInterval:] instead.
 */
@property (nonatomic, assign) NSTimeInterval keepAliveInterval DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5. Use [QBSettings setKeepAliveInterval:] instead");

/* Background mode for stream. Not supported from 2.5.0 due to Apple policy on using battery in background mode.
 *
 * @warning *Deprecated in QB iOS SDK 2.5.0:* Method is no longer available.
 */
@property (nonatomic, assign, getter = isBackgroundingEnabled) BOOL backgroundingEnabled DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.5.0. Method is no longer available.");

- (QB_NONNULL id)init __attribute__((unavailable("'init' is not a supported initializer for this class.")));

#pragma mark -
#pragma mark Multicaste Delegate

/** 
 Adds the given delegate implementation to the list of observers
 
 @param delegate The delegate to add
 */
- (void)addDelegate:(QB_NONNULL id<QBChatDelegate>)delegate;

/** 
 Removes the given delegate implementation from the list of observers
 
 @param delegate The delegate to remove
 */
- (void)removeDelegate:(QB_NONNULL id<QBChatDelegate>)delegate;

/** Removes all delegates */
- (void)removeAllDelegates;

/** Array of all delegates*/
- (QB_NULLABLE NSArray QB_GENERIC(id<QBChatDelegate>) *)delegates;


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
+ (QB_NONNULL instancetype)instance;

/**
 *  Connect to QuickBlox Chat with completion.
 *
 *  @param user       QBUUser structure represents user's login. Required user's fields: ID, password.
 *  @param completion Completion block with failure error.
 */
- (void)connectWithUser:(QB_NONNULL QBUUser *)user completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Connect to QuickBlox Chat.
 *
 *  @param user       QBUUser structure represents user's login. Required user's fields: ID, password.
 *  @param resource   The resource identifier of user.
 *  @param completion Completion block with failure error.
 */
- (void)connectWithUser:(QB_NONNULL QBUUser *)user resource:(nullable NSString *)resource completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 * Check if current user connected to Chat
 *
 * @return YES if user is connected in, NO otherwise
 */
- (BOOL)isConnected;

/**
 *  Disconnect current user from Chat
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'disconnectWithCompletionBlock:' instead.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)disconnect DEPRECATED_MSG_ATTRIBUTE("Use 'disconnectWithCompletionBlock:' instead.");

/**
 *  Disconnect current user from Chat and leave all rooms
 *
 *  @param completion  Completion block with failure error.
 */
- (void)disconnectWithCompletionBlock:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Send "read" status for message and update "read" status on a server
 *
 *  @param message QBChatMessage message to mark as read.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'readMessage:completion:' instead.
 *  
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)readMessage:(QB_NONNULL QBChatMessage *)message DEPRECATED_MSG_ATTRIBUTE("Use 'readMessage:completion:' instead.");

/**
 *  Send "read" status for message and update "read" status on a server
 *
 *  @param message      QBChatMessage message to mark as read.
 *  @param completion   Completion block with failure error.
 */
- (void)readMessage:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Send "delivered" status for message.
 *
 *  @param message QBChatMessage message to mark as delivered.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'markAsDelivered:completion:' instead.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)markAsDelivered:(QB_NONNULL QBChatMessage *)message DEPRECATED_MSG_ATTRIBUTE("Use 'markAsDelivered:completion:' instead.");

/**
 *  Send "delivered" status for message.
 *
 *  @param message      QBChatMessage message to mark as delivered.
 *  @param completion   Completion block with failure error.
 */
- (void)markAsDelivered:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 Send presence message. Session will be closed in 90 seconds since last activity.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresence;

/**
 Send presence message with status. Session will be closed in 90 seconds since last activity.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithStatus:(QB_NONNULL NSString *)status;

/**
 Get current chat user
 
 @return An instance of QBUUser
 */
- (QB_NULLABLE QBUUser *)currentUser;


#pragma mark -
#pragma mark Contact list

/**
 *  Add user to contact list request
 *
 *  @param userID ID of user which you would like to add to contact list
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'addUserToContactListRequest:completion:' instead.
 *  
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)addUserToContactListRequest:(NSUInteger)userID DEPRECATED_MSG_ATTRIBUTE("Use 'addUserToContactListRequest:completion:' instead.");

/**
 *  Add user to contact list request
 *
 *  @param userID ID of user which you would like to add to contact list
 *  @param sentBlock The block which informs whether a request was delivered to server or not. If request succeded error is nil.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'addUserToContactListRequest:completion:' instead.
 *  
 *  @return YES if the request was sent. If not - see log.
 */
- (BOOL)addUserToContactListRequest:(NSUInteger)userID sentBlock:(QB_NULLABLE QBChatCompletionBlock)sentBlock DEPRECATED_MSG_ATTRIBUTE("Use 'addUserToContactListRequest:completion:' instead.");

/**
 *  Add user to contact list request
 *
 *  @param userID       ID of user which you would like to add to contact list
 *  @param completion   Completion block with failure error.
 */
- (void)addUserToContactListRequest:(NSUInteger)userID completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Remove user from contact list
 *
 *  @param userID ID of user which you would like to remove from contact list
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'removeUserFromContactList:completion:' instead.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)removeUserFromContactList:(NSUInteger)userID DEPRECATED_MSG_ATTRIBUTE("Use 'removeUserFromContactList:completion:' instead.");

/**
 *  Remove user from contact list
 *
 *  @param userID ID of user which you would like to remove from contact list
 *  @param sentBlock The block which informs whether a request was delivered to server or not. If request succeded error is nil.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'removeUserFromContactList:completion:' instead.
 *
 *  @return YES if the request was sent. If not - see log.
 */
- (BOOL)removeUserFromContactList:(NSUInteger)userID sentBlock:(QB_NULLABLE QBChatCompletionBlock)sentBlock DEPRECATED_MSG_ATTRIBUTE("Use 'removeUserFromContactList:completion:' instead.");

/**
 *  Remove user from contact list
 *
 *  @param userID     ID of user which you would like to remove from contact list
 *  @param completion Completion block with failure error.
 */
- (void)removeUserFromContactList:(NSUInteger)userID completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Confirm add to contact list request
 *
 *  @param userID ID of user from which you would like to confirm add to contact request
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'confirmAddContactRequest:completion:' instead.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID DEPRECATED_MSG_ATTRIBUTE("Use 'confirmAddContactRequest:completion:' instead.");

/**
 *  Confirm add to contact list request
 *
 *  @param userID ID of user from which you would like to confirm add to contact request
 *  @param sentBlock The block which informs whether a request was delivered to server or not. If request succeded error is nil.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'confirmAddContactRequest:completion:' instead.
 *
 *  @return YES if the request was sent. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID sentBlock:(QB_NULLABLE QBChatCompletionBlock)sentBlock DEPRECATED_MSG_ATTRIBUTE("Use 'confirmAddContactRequest:completion:' instead.");

/**
 *  Confirm add to contact list request
 *
 *  @param userID       ID of user from which you would like to confirm add to contact request
 *  @param completion   The block which informs whether a request was delivered to server or not. If request succeded error is nil.
 */
- (void)confirmAddContactRequest:(NSUInteger)userID completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Reject add to contact list request or cancel previously-granted subscription request
 *
 *  @param userID ID of user from which you would like to reject add to contact request
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'rejectAddContactRequest:completion:' instead.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID DEPRECATED_MSG_ATTRIBUTE("Use 'rejectAddContactRequest:completion:' instead.");

/**
 *  Reject add to contact list request or cancel previously-granted subscription request
 *
 *  @param userID ID of user from which you would like to reject add to contact request
 *  @param sentBlock The block which informs whether a request was delivered to server or not. If request succeded error is nil.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'rejectAddContactRequest:completion:' instead.
 *
 *  @return YES if the request was sent. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID sentBlock:(QB_NULLABLE QBChatCompletionBlock)sentBlock DEPRECATED_MSG_ATTRIBUTE("Use 'rejectAddContactRequest:completion:' instead.");

/**
 *  Reject add to contact list request or cancel previously-granted subscription request
 *
 *  @param userID       ID of user from which you would like to reject add to contact request
 *  @param completion   The block which informs whether a request was delivered to server or not. If request succeded error is nil.
 */
- (void)rejectAddContactRequest:(NSUInteger)userID completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark -
#pragma mark Privacy

/**
 Retrieve a privacy list by name. QBChatDelegate's method 'didReceivePrivacyList:' will be called if success or 'didNotReceivePrivacyListWithName:error:' if there is an error
 @param privacyListName name of privacy list
 */
- (void)retrievePrivacyListWithName:(QB_NONNULL NSString *)privacyListName;

/**
 Retrieve privacy list names. QBChatDelegate's method 'didReceivePrivacyListNames:' will be called if success or 'didNotReceivePrivacyListNamesDueToError:' if there is an error
 */
- (void)retrievePrivacyListNames;

/**
 Create/edit a privacy list. QBChatDelegate's method 'didReceivePrivacyList:' will be called
 
 @param privacyList instance of QBPrivacyList
 */
- (void)setPrivacyList:(QB_NULLABLE QBPrivacyList *)privacyList;

/**
 Set an active privacy list. QBChatDelegate's method 'didSetActivePrivacyListWithName:' will be called if success or 'didNotSetActivePrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)setActivePrivacyListWithName:(QB_NULLABLE NSString *)privacyListName;

/**
 Set a default privacy list. QBChatDelegate's method 'didSetDefaultPrivacyListWithName:' will be called if success or 'didNotSetDefaultPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)setDefaultPrivacyListWithName:(QB_NULLABLE NSString *)privacyListName;

/**
 Remove a privacy list. QBChatDelegate's method 'didRemovedPrivacyListWithName:' will be called if success or 'didNotSetPrivacyListWithName:error:' if there is an error
 
 @param privacyListName name of privacy list
 */
- (void)removePrivacyListWithName:(QB_NONNULL NSString *)privacyListName;

#pragma mark -
#pragma mark System Messages

/**
 *  Send system message to dialog.
 *
 *  @param message Chat message to send.
 *
 *  @warning *Deprecated in QB iOS SDK 2.5.0:* Use 'sendSystemMessage:completion:' instead.
 *
 *  @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendSystemMessage:(QB_NONNULL QBChatMessage *)message DEPRECATED_MSG_ATTRIBUTE("Use 'sendSystemMessage:completion:' instead.");

/**
 *  Send system message to dialog.
 *
 *  @param message      QBChatMessage instance of message to send.
 *  @param completion   Completion block with failure error.
 */
- (void)sendSystemMessage:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

@end
