//
//  QBChat.h
//  Chat
//
//  Copyright 2013 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatEnums.h"
#import "QBCoreDelegates.h"

@protocol QBChatDelegate;
@class QBUUser;
@class QBContactList;
@class QBChatMessage;
@class QBChatRoom;
@class QBVideoChat;
@class QBChatDialog;
@class QBChatHistoryMessage;
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

/** Enable or disable auto кeconnect */
@property (nonatomic, assign, getter = isAutoReconnectEnabled) BOOL autoReconnectEnabled;

/** A reconnect timer may optionally be used to attempt a reconnect periodically.
  The default value is 5 seconds */
@property (nonatomic, assign) NSTimeInterval reconnectTimerInterval;

/** Contact list mechanism */
@property (nonatomic, assign) BOOL useMutualSubscriptionForContactList;

/** Array of registered video chat instances */
@property (readonly) NSMutableArray *registeredVideoChatInstances;


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
 Send message
 
 @param message QBChatMessage instance
 @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message;

/**
 Send message with 'sent' block
 
 @param message QBChatMessage instance
 @param sentBlock The block which informs whether a message was delivered to server or not. nil if no errors.
 @return YES if the message was sent. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message sentBlock:(void (^)(NSError *error))sentBlock;

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
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendDirectPresenceWithStatus:(NSString *)status toUser:(NSUInteger)userID;

/**
 Get current chat user
 
 @return An instance of QBUUser
 */
- (QBUUser *)currentUser;

/**
  Request service discovery information
 */
- (BOOL)requestServiceDiscoveryInformation;


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
 Reject add to contact list request
 
 @param userID ID of user from which you would like to reject add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID;

/**
 Reject add to contact list request
 
 @param userID ID of user from which you would like to reject add to contact request
 @param sentBlock The block which informs whether a request was delivered to server or not. nil if no errors.
 @return YES if the request was sent. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID sentBlock:(void (^)(NSError *error))sentBlock;


#pragma mark -
#pragma mark Rooms

/**
 Join room. QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @param room Room to join
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)joinRoom:(QBChatRoom *)room;

/**
 Join room. QBChatDelegate's method 'chatRoomDidEnter:' will be called
 
 @param room Room to join
 @param historyAttribute Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)joinRoom:(QBChatRoom *)room historyAttribute:(NSDictionary *)historyAttribute;

/**
 Leave joined room. QBChatDelegate's method 'chatRoomDidLeave:' will be called
 
 @param room Room to leave
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)leaveRoom:(QBChatRoom *)room;

/**
 Send chat message to room
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendChatMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)room;

/**
 Send chat message to room, without room join
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendChatMessageWithoutJoin:(QBChatMessage *)message toRoom:(QBChatRoom *)room;

/**
 Send presence with parameters to room
 
 @param parameters Presence parameters
 @param room Room to send presence
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithParameters:(NSDictionary *)parameters toRoom:(QBChatRoom *)room;

/**
 Send presence with status, show, priority, custom parameters to room
 
 @param status Element contains character data specifying a natural-language description of availability status
 @param show Element contains non-human-readable character data that specifies the particular availability status of an entity or specific resource.
 @param priority Element contains non-human-readable character data that specifies the priority level of the resource. The value MUST be an integer between -128 and +127.
 @param customParameters Custom parameters
 @param room Room to send presence
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendPresenceWithStatus:(NSString *)status show:(enum QBPresenseShow)show priority:(short)priority customParameters:(NSDictionary *)customParameters toRoom:(QBChatRoom *)room;

/**
 Request users who are joined a room. QBChatDelegate's method 'chatRoomDidReceiveListOfOnlineUsers:room:' will be called
 
 @param room Room
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomOnlineUsers:(QBChatRoom *)room;


#pragma mark -
#pragma mark VideoChat

/**
 Create and register new video chat instance
 
 @return Autoreleased instance of QBVideoChat;
 */
- (QBVideoChat *)createAndRegisterVideoChatInstance;

/**
 Create and register new video chat instance with particular session ID
 
 @param sessionID Video chat session ID
 @return Autoreleased instance of QBVideoChat;
 */
- (QBVideoChat *)createAndRegisterVideoChatInstanceWithSessionID:(NSString *)sessionID;

/**
 Unregister video chat instance
 
 @param videoChat Instance of video chat
 */
- (void)unregisterVideoChatInstance:(QBVideoChat *)videoChat;


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

@end


#pragma mark -
#pragma mark Deprecated

@interface QBChat (Deprecated)



/** QBChat delegate for callbacks
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use addDelegate: instead
 */
@property (weak, nonatomic) id <QBChatDelegate> delegate __attribute__((deprecated("Use addDelegate: instead")));



/**
 Send message to room
 
 @warning *Deprecated in QB iOS SDK 1.9:* Use sendChatMessage:toRoom: instead
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendMessage:(NSString *)message toRoom:(QBChatRoom *)room __attribute__((deprecated("Use sendChatMessage:toRoom: instead")));

/**
 Create room or join if room with this name already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(\),(&),('),(/),(:),(<),(>),(@),((),()),(:),(;)  characters - they will be removed.
 As user room nickname we will use user ID
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param name Room name
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithName:(NSString *)name membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent
 __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Create room or join if room with this JID already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 As user room nickname we will use user ID
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param roomJID Room JID
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @param historyAttribute Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithJID:(NSString *)roomJID membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent historyAttribute:(NSDictionary *)historyAttribute
 __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Create room or join if room with this name already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(\),(&),('),(/),(:),(<),(>),(@),((),()),(:),(;)  characters - they will be removed.
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param name Room name
 @param nickname User nickname wich will be used in room
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithName:(NSString *)name nickname:(NSString *)nickname membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent
 __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Create room or join if room with this JID already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param roomJID Room JID
 @param nickname User nickname wich will be used in room
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @param historyAttribute Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithJID:(NSString *)roomJID nickname:(NSString *)nickname membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent historyAttribute:(NSDictionary *)historyAttribute
 __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Destroy room. You can destroy room only if you are room owner or added to only members room by its owner. QBChatDelegate's method 'chatRoomDidDestroy:' will be called
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param room Room to destroy
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)destroyRoom:(QBChatRoom *)room __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Send request for getting list of public groups. QBChatDelegate's method 'chatDidReceiveListOfRooms:' will be called
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestAllRooms __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Send request for getting room information. QBChatDelegate's method 'chatRoomDidReceiveInformation:room:' will be called
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param room Room, which information you need to retrieve
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomInformation:(QBChatRoom *)room __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Request users who are able to join a room. QBChatDelegate's method 'chatRoomDidReceiveListOfUsers:room:' will be called
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param room Room
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomUsers:(QBChatRoom *)room __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Request users with affiliation. QBChatDelegate's method 'chatRoomDidReceiveListOfUsers:room:' will be called
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param affiliation User's affiliation
 @param room Room
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomUsersWithAffiliation:(NSString *)affiliation room:(QBChatRoom *)room __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Send request to adding users to room.
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param usersIDs Array of users' IDs
 @param room Room in which users will be added
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)addUsers:(NSArray *)usersIDs toRoom:(QBChatRoom *)room __attribute__((deprecated("Use Chat Dialogs API instead.")));

/**
 Send request to remove users from room
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use Chat Dialogs API instead.
 
 @param usersIDs Array of users' IDs
 @param room Room from which users will be removed
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)deleteUsers:(NSArray *)usersIDs fromRoom:(QBChatRoom *)room __attribute__((deprecated("Use Chat Dialogs API instead.")));



/**
 Retrieve chat dialogs
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest dialogsWithSuccessBlock:errorBlock:]' instead.
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBDialogsPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)dialogsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest dialogsWithSuccessBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)dialogsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest dialogsWithSuccessBlock:errorBlock:]' instead.")));

/**
 Retrieve chat dialogs, with extended request
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest dialogsForPage:extendedRequest:successBlock:errorBlock:]' instead."
 
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBDialogsPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)dialogsWithExtendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest dialogsForPage:extendedRequest:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)dialogsWithExtendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest dialogsForPage:successBlock:errorBlock:]' instead.")));

/**
 Create chat dialog
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest createDialog:successBlock:errorBlock:]' instead.
 
 @param dialog Entity if a new dialog
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)createDialog:(QBChatDialog *)dialog delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest createDialog:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)createDialog:(QBChatDialog *)dialog delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest createDialog:successBlock:errorBlock:]' instead.")));

/**
 Update existing chat dialog
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest updateDialog:successBlock:errorBlock:]' instead.
 
 @param dialogID ID of a dialog to update
 @param extendedRequest Set of parameters to update
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest updateDialog:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)updateDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest updateDialog:successBlock:errorBlock:]' instead.")));

/**
 Delete chat dialog
 
 @warning *Deprecated in QB iOS SDK 2.1:*
 
 @param dialogID ID of a dialog to delete
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteDialogWithID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteDialogWithID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;

/**
 Retrieve all chat messages within particular dialog
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest messagesWithDialogID:successBlock:errorBlock:]' instead.
 
 @param dialogID ID of a dialog
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatHistoryMessageResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest messagesWithDialogID:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest messagesWithDialogID:successBlock:errorBlock:]' instead.")));

/**
 Retrieve all chat messages within particular dialog, with extended request
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest messagesWithDialogID:forPage:successBlock:errorBlock:]' instead.
 
 @param dialogID ID of a dialog
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatHistoryMessageResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest messagesWithDialogID:forPage:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest messagesWithDialogID:forPage:successBlock:errorBlock:]' instead.")));

/**
 Create chat message
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest createMessage:successBlock:errorBlock:]' instead.
 
 @param message Entity if a new message
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)createMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest createMessage:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)createMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest createMessage:successBlock:errorBlock:]' instead.")));

/**
 Update existing chat message - mark it as read
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest updateMessage:successBlock:errorBlock:]' instead.
 
 @param message Entity of a chat message to update
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest updateMessage:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)updateMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest updateMessage:successBlock:errorBlock:]' instead.")));

/**
 Mark mesasges as read
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest markMessagesAsRead:dialogID:successBlock:errorBlock:]' instead.
 
 @param messagesIDs An array of IDs of chat messages to read
 @param dialogID ID of a dialog
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)markMessagesAsRead:(NSArray *)messagesIDs dialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest markMessagesAsRead:dialogID:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)markMessagesAsRead:(NSArray *)messagesIDs dialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest markMessagesAsRead:dialogID:successBlock:errorBlock:]' instead.")));

/**
 Delete existing chat message
 
 @warning *Deprecated in QB iOS SDK 2.1:* Use '+[QBRequest deleteMessageWithID:successBlock:errorBlock:]' instead.
 
 @param messageID ID of a message to delete
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteMessageWithID:(NSString *)messageID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest deleteMessageWithID:successBlock:errorBlock:]' instead.")));
+ (NSObject<Cancelable> *)deleteMessageWithID:(NSString *)messageID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest deleteMessageWithID:successBlock:errorBlock:]' instead.")));

@end
