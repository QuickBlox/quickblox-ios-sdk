//
//  Delegates.h
//  QBChat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStopVideoChatCallStatus_OpponentDidNotAnswer @"kStopVideoChatCallStatus_OpponentDidNotAnswer"
#define kStopVideoChatCallStatus_Manually @"kStopVideoChatCallStatus_Manually"
#define kStopVideoChatCallStatus_Cancel @"kStopVideoChatCallStatus_Cancel"
#define kStopVideoChatCallStatus_BadConnection @"kStopVideoChatCallStatus_BadConnection"

/**
 QBChatDelegate protocol definition
 This protocol defines methods signatures for callbacks. Implement this protocol in your class and
 add [QBChat instance].addDelegate to your implementation instance to receive callbacks from QBChat
 */

@class QBContactList, QBChatMessage, QBPrivacyList;

@protocol QBChatDelegate <NSObject>
@optional

#pragma mark -
#pragma mark Base IM

/**
 didLogin fired by QBChat when connection to service established and login is successfull
 */
- (void)chatDidLogin;

/**
 didNotLoginWithError fired when login process did not finished successfully

 @param error Error
 */
- (void)chatDidNotLoginWithError:(NSError *)error;

/**
 didNotSendMessage fired when message cannot be send to user
 
 @param message message passed to sendMessage method into QBChat
 @param error Error
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message error:(NSError *)error;

/**
 *  Fired when message cannot be send to the group chat.
 *
 *  @param message  QBChatMessage message.
 *  @param dialogID QBChatDialog identifier.
 *  @param error    Error.
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message toDialogID:(NSString *)dialogID error:(NSError *)error;

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from Chat
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message;

/**
 didReceiveSystemMessage fired when new system message was received from QBChat
 
 @param message Message received from Chat
 */
- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message;

/**
 chatDidFailWithStreamError fired when connection error
 
 @param error XMPPStream Error
 */
- (void)chatDidFailWithStreamError:(NSError *)error;

/**
 *  Fired when XMPP stream established connection
 */
- (void)chatDidConnect;

/**
 *  Fired when XMPP stream is accidentaly disconnected
 */
- (void)chatDidAccidentallyDisconnect;

/**
 *  Fired after successful connection to stream after disconnect.
 */
- (void)chatDidReconnect;


#pragma mark -
#pragma mark Contact list

/**
 Called in case receiving contact request
 
 @param userID User ID from which received contact request
 */
- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID;

/**
 Called in case of changing contact list
 */
- (void)chatContactListDidChange:(QBContactList *)contactList;

/**
 Called in case changing contact's online status
 
 @param userID User which online status has changed
 @param isOnline New user status (online or offline)
 @param status Custom user status
 */
- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status;

/**
 + Called when user has accepted your contact request
 +
 + @param userID User ID from which accepted your request
 + */
- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID;

/**
 + Called when user has rejected your contact request
 +
 + @param userID User ID from which rejected your request
 + */
- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID;


#pragma mark -
#pragma mark Rooms

/**
 *  Called when dialog receives message.
 *
 *  @param message  Received message.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID;

/**
 *  Called when user joined dialog.
 *
 *  @param userId   User's ID.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomOccupantDidJoin:(NSUInteger)userId dialogID:(NSString *)dialogID;

/**
 *  Called when user left dialog.
 *
 *  @param userId   User's ID.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomOccupantDidLeave:(NSUInteger)userId dialogID:(NSString *)dialogID;

/**
 *  Called when user was updated in dialog.
 *
 *  @param userId   User's ID.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomOccupantDidUpdate:(NSUInteger)userId dialogID:(NSString *)dialogID;

/**
 *  Called in case of receiving list of online users in dialog.
 *
 *  @param users    Array of joined users.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users dialogID:(NSString *)dialogID __attribute__((deprecated("Use QBChatDialog 'setOnReceiveListOfOnlineUsers:' block instead.")));;

#pragma mark -
#pragma mark Privacy

/**
 Called in case receiving privacy list names
 
 @param listNames array with privacy list names
 */
- (void)chatDidReceivePrivacyListNames:(NSArray *)listNames;

/**
 Called in case receiving privacy list
 
 @param privacyList list with privacy items
 */
- (void)chatDidReceivePrivacyList:(QBPrivacyList *)privacyList;

/**
 Called when you failed to receive privacy list names
 
 @param error Error
 */
- (void)chatDidNotReceivePrivacyListNamesDueToError:(id)error;

/**
 Called when you failed to receive a list of privacy items
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotReceivePrivacyListWithName:(NSString *)name error:(id)error;

/**
 Called when you successfully created/edited a list
 @param name privacy list name
 */
- (void)chatDidSetPrivacyListWithName:(NSString *)name;

/**
 Called when you successfully set an active privacy list
 @param name active privacy list name
 */
- (void)chatDidSetActivePrivacyListWithName:(NSString *)name;

/**
 Called when you successfully set a default privacy list
 @param name default privacy list name
 */
- (void)chatDidSetDefaultPrivacyListWithName:(NSString *)name;

/**
 Called when you failed to create/edit a privacy list
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotSetPrivacyListWithName:(NSString *)name error:(id)error;

/**
 Called when you failed to create/edit an active privacy list
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotSetActivePrivacyListWithName:(NSString *)name error:(id)error;

/**
 Called when you failed to set a default privacy list
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotSetDefaultPrivacyListWithName:(NSString *)name error:(id)error;

/**
 Called when you removed a privacy list
 @param name privacy list name
 @param error Error
 */
- (void)chatDidRemovedPrivacyListWithName:(NSString *)name;


#pragma mark -
#pragma mark Typing Status

/**
 Called when you received a chat status "user is typing"
 
 @warning Deprecated in 2.4. Use 'onUserIsTyping:' block in 'QBChatDialog'.
 
 @param userID privacy list name
 */
- (void)chatDidReceiveUserIsTypingFromUserWithID:(NSUInteger)userID __attribute__((deprecated("Use 'onUserIsTyping:' block in 'QBChatDialog'.")));

/**
 Called when you received a chat status "user stop typing"

 @warning Deprecated in 2.4. Use 'onUserStoppedTyping:' block in 'QBChatDialog'.
 
 @param userID privacy list name
 */
- (void)chatDidReceiveUserStopTypingFromUserWithID:(NSUInteger)userID __attribute__((deprecated("Use 'onUserStoppedTyping:' block in 'QBChatDialog'.")));;


#pragma mark -
#pragma mark Delivered status

/**
 Called when you received a confirmation about message delivery
 
 @warning Deprecated in 2.4. Use 'chatDidDeliverMessageWithID:dialogID:toUserID:' instead.
 
 @param messageID ID of an original message
 */
- (void)chatDidDeliverMessageWithID:(NSString *)messageID;

/**
 *  Called when message is delivered to user.
 *
 *  @param messageID Message identifier.
 *  @param dialogID  Dialog identifier.
 *  @param readerID  User identifier.
 */
- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userID;

#pragma mark -
#pragma mark Read status

/**
 Called when you received a confirmation about message read.
 
 @warning Deprecated in 2.4. Use 'chatDidReadMessageWithID:dialogID:readerID:' instead.
 
 @param messageID ID of an original message
 */
- (void)chatDidReadMessageWithID:(NSString *)messageID __attribute__((deprecated("Use 'chatDidReadMessageWithID:dialogID:readerID:' instead.")));

/**
 *  Called when message is read by opponent.
 *
 *  @param messageID Message identifier.
 *  @param dialogID  Dialog identifier.
 *  @param readerID  Reader identifier.
 */
- (void)chatDidReadMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID readerID:(NSUInteger)readerID;

@end


