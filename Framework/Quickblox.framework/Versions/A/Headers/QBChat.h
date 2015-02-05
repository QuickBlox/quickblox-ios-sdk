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
    QBChatServiceErrorConnectionRefused,
    QBChatServiceErrorConnectionClosed,
    QBChatServiceErrorConnectionTimeout
} QBChatServiceError;

/** QBChat class declaration. */
/** Overview */
/** This class is the main entry point to work with Quickblox Chat API. */

@interface QBChat : NSObject{
@private
    QBUUser *qbUser;
}

/** QBChat delegate for callbacks */
@property (nonatomic, assign) id<QBChatDelegate> delegate;

/** Contact list */
@property (nonatomic, readonly) QBContactList *contactList;

/** Contact list mechanism */
@property (nonatomic, assign) BOOL useMutualSubscriptionForContactList;

/** Array of registered video chat instances */
@property (readonly) NSMutableArray *registeredVideoChatInstances;


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
 
 @param message QBChatMessage structure which contains message text and recipient id
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendMessage:(QBChatMessage *)message;


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


#pragma mark -
#pragma mark Contact list

/**
 Add user to contact list request
 
 @param userID ID of user which you would like to add to contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)addUserToContactListRequest:(NSUInteger)userID;

/**
 Remove user from contact list
 
 @param userID ID of user which you would like to remove from contact list
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)removeUserFromContactList:(NSUInteger)userID;

/**
 Confirm add to contact list request
 
 @param userID ID of user from which you would like to confirm add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)confirmAddContactRequest:(NSUInteger)userID;

/**
 Reject add to contact list request
 
 @param userID ID of user from which you would like to reject add to contact request
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)rejectAddContactRequest:(NSUInteger)userID;


#pragma mark -
#pragma mark Rooms

/**
 Create room or join if room with this name already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(\),(&),('),(/),(:),(<),(>),(@),((),()),(:),(;)  characters - they will be removed.
 As user room nickname we will use user ID
 
 @param name Room name
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithName:(NSString *)name membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent;

/**
 Create room or join if room with this JID already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 As user room nickname we will use user ID
 
 @param roomJID Room JID
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @param historyAttribute Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithJID:(NSString *)roomJID membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent historyAttribute:(NSDictionary *)historyAttribute;

/**
 Create room or join if room with this name already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 If room name contains (" ") (space) character - it will be replaceed with "_" (underscore) character.
 If room name contains ("),(\),(&),('),(/),(:),(<),(>),(@),((),()),(:),(;)  characters - they will be removed.
 
 @param name Room name
 @param nickname User nickname wich will be used in room
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithName:(NSString *)name nickname:(NSString *)nickname membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent;


/**
 Create room or join if room with this JID already exist. QBChatDelegate's method 'chatRoomDidEnter:' will be called.
 
 @param roomJID Room JID
 @param nickname User nickname wich will be used in room
 @param isMembersOnly YES if you want to create room that users cannot enter without being on the member list. If set NO - room will be opened for all users
 @param isPersistent YES if you want to create room that is not destroyed if the last user exits. If set NO - room will be destroyed if the last user exits.
 @param historyAttribute Attribite to manage the amount of discussion history provided on entering a room. More info here http://xmpp.org/extensions/xep-0045.html#enter-history
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)createOrJoinRoomWithJID:(NSString *)roomJID nickname:(NSString *)nickname membersOnly:(BOOL)isMembersOnly persistent:(BOOL)isPersistent historyAttribute:(NSDictionary *)historyAttribute;

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
 Destroy room. You can destroy room only if you are room owner or added to only members room by its owner. QBChatDelegate's method 'chatRoomDidDestroy:' will be called
 
 @param room Room to destroy
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)destroyRoom:(QBChatRoom *)room;

/**
 Send message to room
 
 @warning *Deprecated in QB iOS SDK 1.9:* Use sendChatMessage:toRoom: instead
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendMessage:(NSString *)message toRoom:(QBChatRoom *)room __attribute__((deprecated("Use sendChatMessage:toRoom: instead")));

/**
 Send chat message to room
 
 @param message Message body
 @param room Room to send message
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)sendChatMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)room;

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
 Send request for getting list of public groups. QBChatDelegate's method 'chatDidReceiveListOfRooms:' will be called
 
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestAllRooms;

/**
 Send request for getting room information. QBChatDelegate's method 'chatRoomDidReceiveInformation:room:' will be called
 
 @param room Room, which information you need to retrieve
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomInformation:(QBChatRoom *)room;

/**
 Request users who are able to join a room. QBChatDelegate's method 'chatRoomDidReceiveListOfUsers:room:' will be called
 
 @param room Room
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomUsers:(QBChatRoom *)room;

/**
 Request users with affiliation. QBChatDelegate's method 'chatRoomDidReceiveListOfUsers:room:' will be called
 
 @param affiliation User's affiliation
 @param room Room
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomUsersWithAffiliation:(NSString *)affiliation room:(QBChatRoom *)room;

/**
 Request users who are joined a room. QBChatDelegate's method 'chatRoomDidReceiveListOfOnlineUsers:room:' will be called
 
 @param room Room
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)requestRoomOnlineUsers:(QBChatRoom *)room;

/**
 Send request to adding users to room.
 
 @param usersIDs Array of users' IDs
 @param room Room in which users will be added
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)addUsers:(NSArray *)usersIDs toRoom:(QBChatRoom *)room;

/**
 Send request to remove users from room
 
 @param usersIDs Array of users' IDs
 @param room Room from which users will be removed
 @return YES if the request was sent successfully. If not - see log.
 */
- (BOOL)deleteUsers:(NSArray *)usersIDs fromRoom:(QBChatRoom *)room;


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
#pragma mark Retrive Dialogs

/**
 Retrieve chat dialogs
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBDialogsPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)dialogsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)dialogsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


/**
 Retrieve chat dialogs, with extended request
 
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBDialogsPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)dialogsWithExtendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)dialogsWithExtendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Create dialog

/**
 Create chat dialog
 
 @param dialog Entity if a new dialog
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)createDialog:(QBChatDialog *)dialog delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createDialog:(QBChatDialog *)dialog delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Update dialog

/**
 Update existing chat dialog
 
 @param dialogID ID of a dialog to update
 @param extendedRequest Set of parameters to update
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updateDialogWithID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete dialog

/**
 Delete chat dialog
 
 @param dialogID ID of a dialog to delete
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteDialogWithID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteDialogWithID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Retrive Messages

/**
 Retrieve all chat messages within particular dialog
 
 @param dialogID ID of a dialog
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatHistoryMessageResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


/**
 Retrieve all chat messages within particular dialog, with extended request
 
 @param dialogID ID of a dialog
 @param extendedRequest Extended set of request parameters
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatHistoryMessageResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)messagesWithDialogID:(NSString *)dialogID extendedRequest:(NSMutableDictionary *)extendedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Create message

/**
 Create chat message
 
 @param message Entity if a new message
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBChatDialogResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)createMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)createMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Update Message

/**
 Update existing chat message - mark it as read
 
 @param message Entity of a chat message to update
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)updateMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)updateMessage:(QBChatHistoryMessage *)message delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Update Messages

/**
 Mark mesasges as read
 
 @param messagesIDs An array of IDs of chat messages to read
 @param dialogID ID of a dialog
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)markMessagesAsRead:(NSArray *)messagesIDs dialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)markMessagesAsRead:(NSArray *)messagesIDs dialogID:(NSString *)dialogID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


#pragma mark -
#pragma mark Delete Message

/**
 Delete existing chat message
 
 @param messageID ID of a message to delete
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)deleteMessageWithID:(NSString *)messageID delegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)deleteMessageWithID:(NSString *)messageID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


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
