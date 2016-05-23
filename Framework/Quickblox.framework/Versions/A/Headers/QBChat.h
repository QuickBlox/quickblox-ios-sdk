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
@class QBPrivacyList;

/** QBChat class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Chat API. */

@interface QBChat : NSObject

/**
 *  Check if current user is connected to Chat
 */
@property (assign, nonatomic, readonly) BOOL isConnected;

/** 
 *  Contact list
 */
@property (nonatomic, readonly, QB_NULLABLE_PROPERTY) QBContactList *contactList;

- (QB_NONNULL id)init NS_UNAVAILABLE;

#pragma mark -
#pragma mark Multicast Delegate

/**
 *  Adds the given delegate implementation to the list of observers
 *
 *  @param delegate The delegate to add
 */
- (void)addDelegate:(QB_NONNULL id<QBChatDelegate>)delegate;

/**
 *  Removes the given delegate implementation from the list of observers
 *
 *  @param delegate The delegate to remove
 */
- (void)removeDelegate:(QB_NONNULL id<QBChatDelegate>)delegate;

/** 
 * Removes all delegates
 */
- (void)removeAllDelegates;

/** 
 *  Array of all delegates
 */
- (QB_NULLABLE NSArray QB_GENERIC(id<QBChatDelegate>) *)delegates;

#pragma mark -
#pragma mark Reconnection

/**
 *  Run force reconnect. This method disconnects from chat and runs reconnection logic.
 *  Works only if autoReconnectEnabled=YES. Otherwise it does nothing.
 */
- (void)forceReconnect;

#pragma mark -
#pragma mark Base Messaging

/**
 *  Get QBChat singleton
 *
 *  @return QBChat Chat service singleton
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
 *  Disconnect current user from Chat and leave all rooms
 *
 *  @param completion  Completion block with failure error.
 */
- (void)disconnectWithCompletionBlock:(QB_NULLABLE QBChatCompletionBlock)completion;

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
 *  @param message      QBChatMessage message to mark as delivered.
 *  @param completion   Completion block with failure error.
 */
- (void)markAsDelivered:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

/**
 *  Send presence message. Session will be closed in 90 seconds since last activity.
 *  @warning *Deprecated in 2.7.0.:*
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresence DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.0.");

/**
 *  Send presence message with status. Session will be closed in 90 seconds since last activity.
 *
 *  @param status Presence status.
 *
 *  @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithStatus:(QB_NONNULL NSString *)status;

/**
 *  Get current chat user
 *
 *  @return An instance of QBUUser
 */
- (QB_NULLABLE QBUUser *)currentUser;

#pragma mark -
#pragma mark Contact list

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
 *  @param userID     ID of user which you would like to remove from contact list
 *  @param completion Completion block with failure error.
 */
- (void)removeUserFromContactList:(NSUInteger)userID completion:(QB_NULLABLE QBChatCompletionBlock)completion;

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
 *  @param userID       ID of user from which you would like to reject add to contact request
 *  @param completion   The block which informs whether a request was delivered to server or not. If request succeded error is nil.
 */
- (void)rejectAddContactRequest:(NSUInteger)userID completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark -
#pragma mark Privacy

/**
 *  Retrieve a privacy list by name. QBChatDelegate's method 'didReceivePrivacyList:' will be called if success or 'didNotReceivePrivacyListWithName:error:' if there is an error
 *  @param privacyListName name of privacy list
 */
- (void)retrievePrivacyListWithName:(QB_NONNULL NSString *)privacyListName;

/**
 *  Retrieve privacy list names. QBChatDelegate's method 'didReceivePrivacyListNames:' will be called if success or 'didNotReceivePrivacyListNamesDueToError:' if there is an error
 */
- (void)retrievePrivacyListNames;

/**
 *  Create/edit a privacy list. QBChatDelegate's method 'didReceivePrivacyList:' will be called
 *
 *  @param privacyList instance of QBPrivacyList
 */
- (void)setPrivacyList:(QB_NULLABLE QBPrivacyList *)privacyList;

/**
 *  Set an active privacy list. QBChatDelegate's method 'didSetActivePrivacyListWithName:' will be called if success or 'didNotSetActivePrivacyListWithName:error:' if there is an error
 *
 *  @param privacyListName name of privacy list
 */
- (void)setActivePrivacyListWithName:(QB_NULLABLE NSString *)privacyListName;

/**
 *  Set a default privacy list. QBChatDelegate's method 'didSetDefaultPrivacyListWithName:' will be called if success or 'didNotSetDefaultPrivacyListWithName:error:' if there is an error
 *
 *  @param privacyListName name of privacy list
 */
- (void)setDefaultPrivacyListWithName:(QB_NULLABLE NSString *)privacyListName;

/**
 *  Remove a privacy list. QBChatDelegate's method 'didRemovedPrivacyListWithName:' will be called if success or 'didNotSetPrivacyListWithName:error:' if there is an error
 *
 *  @param privacyListName name of privacy list
 */
- (void)removePrivacyListWithName:(QB_NONNULL NSString *)privacyListName;

#pragma mark -
#pragma mark System Messages

/**
 *  Send system message to dialog.
 *
 *  @param message      QBChatMessage instance of message to send.
 *  @param completion   Completion block with failure error.
 */
- (void)sendSystemMessage:(QB_NONNULL QBChatMessage *)message completion:(QB_NULLABLE QBChatCompletionBlock)completion;

#pragma mark - Send pings to the server or a userID

/**
 *  Send ping to server
 *
 *  @param completion  Completion block with failure error.
 */
- (void)pingServer:(QB_NONNULL QBPingCompleitonBlock)completion;

/**
 *  Send ping to server with timeout
 *
 *  @param timeout    timout
 *  @param completion Completion block with failure error.
 */
- (void)pingServerWithTimeout:(NSTimeInterval)timeout completion:(QB_NONNULL QBPingCompleitonBlock)completion;

/**
 *  Send ping to user
 *
 *  @param userID     User ID
 *  @param completion Completion block with failure error.
 */
- (void)pingUserWithID:(NSUInteger )userID completion:(QB_NONNULL QBPingCompleitonBlock)completion;

/**
 *  Send ping to user with timeout
 *
 *  @param userID     User ID
 *  @param timeout    Timeout in seconds
 *  @param completion Completion block with failure error.
 */
- (void)pingUserWithID:(NSUInteger)userID timeout:(NSTimeInterval)timeout completion:(QB_NONNULL QBPingCompleitonBlock)completion;

@end
