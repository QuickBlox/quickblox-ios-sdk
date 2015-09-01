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

@class QBContactList, QBChatRoom, QBChatMessage, QBPrivacyList;

@protocol QBChatDelegate <NSObject>
@optional

#pragma mark -
#pragma mark Base IM

/**
 didLogin fired by QBChat when connection to service established and login is successfull
 */
- (void)chatDidLogin;

/**
 didNotLogin fired when login process did not finished successfully
 
 @warning *Deprecated in QB iOS SDK 2.3:* Use chatDidNotLoginWithError: instead
 */
- (void)chatDidNotLogin __attribute__((deprecated("use 'chatDidNotLoginWithError:' instead.")));

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
 didNotSendMessage fired when message cannot be send to the group chat
 
 @warning *Deprecated in QB iOS SDK 2.4:* Use 'chatDidNotSendMessage:toDialogID:error:' instead.
 
 @param message message passed to sendMessage method into QBChat
 @param roomJid JID of the room
 @param error Error
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message toRoomJid:(NSString *)roomJid error:(NSError *)error __attribute__((deprecated("Use 'chatDidNotSendMessage:toDialogID:error:' instead.")));

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
 didFailWithError fired when connection error occurs
 
 @warning *Deprecated in QB iOS SDK 2.3:* Use chatDidFailWithStreamError: instead
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithError:(NSInteger)code __attribute__((deprecated("Use chatDidFailWithStreamError:")));

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
 Called when room receives a message.
 
 @warning *Deprecated in QB iOS SDK 2.4:* Use 'chatRoomDidReceiveMessage:fromDialogID:' instead.
 
 @param message Received message
 @param roomJID Room JID
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID __attribute__((deprecated("Use 'chatRoomDidReceiveMessage:fromDialogID:' instead.")));

/**
 *  Called when dialog receives message.
 *
 *  @param message  Received message.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID;


/**
 Fired when you did enter to room
 
 @warning *Deprecated in QB iOS SDK 2.4:* Use 'onJoin' from QBChatDialog instead.
 
 @param room which you have joined
 */
- (void)chatRoomDidEnter:(QBChatRoom *)room __attribute__((deprecated("Use 'onJoin' from QBChatDialog instead.")));

/**
 Called when you didn't enter to room.
 
 @warning *Deprecated in QB iOS SDK 2.3:* Use 'onJoinFailed:' block in 'QBChatDialog'.
 
 @param room Name of room which you haven't joined
 @param error Error
 */
- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error __attribute__((deprecated("Use 'onJoinFailed:' block in 'QBChatDialog'.")));

/**
 Called when you didn't enter to room
 
 @warning *Deprecated in QB iOS SDK 2.3:* Use 'onJoinFailed:' block in 'QBChatDialog'.
 
 @param roomJID  JID of room which you haven't joined
 @param error Error
 */
- (void)chatRoomDidNotEnterRoomWithJID:(NSString *)roomJID error:(NSError *)error __attribute__((deprecated("Use 'onJoinFailed:' block in 'QBChatDialog'.")));


/**
 Fired when you did leave room
 
 @warning *Deprecated in QB iOS SDK 2.4:* Use 'onLeave' in QBChatDialog instead.
 
 @param roomJID JID of room which you have leaved
 */
- (void)chatRoomDidLeaveRoomWithJID:(NSString *)roomJID __attribute__((deprecated("Use 'onLeave' in QBChatDialog instead.")));

/**
 Called in case changing online users
 
 @warning *Deprecated in QB iOS SDK 2.3:* This delegate doesn't work anymore. Use chatRoomOccupantDidJoin/Leave/Update:toRoomJID: instead.
 
 @param onlineUsers Array of online users
 @param roomName Name of room in which have changed online users
 */
- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName __attribute__((deprecated("This delegate doesn't work anymore. Use chatRoomOccupantDidJoin/Leave/Update:toRoomJID: instead.")));

/**
 Called in case changing online users
 
 @warning *Deprecated in QB iOS SDK 2.3:* This delegate doesn't work anymore. Use chatRoomOccupantDidJoin/Leave/Update:toRoomJID: instead.
 
 @param onlineUsers Array of online users
 @param roomJID JID of room in which has changed online users list
 */
- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers roomJID:(NSString *)roomJID __attribute__((deprecated("This delegate doesn't work anymore Use chatRoomOccupantDidJoin/Leave/Update:toRoomJID: instead.")));


/**
 *  Called when user joined room.
 *
 *  @warning *Deprecated in QB iOS SDK 2.4:* Use 'chatRoomOccupantDidJoin:dialogID:' instead.
 *
 *  @param userId User's ID.
 *  @param roomJID     JID of room.
 */
- (void)chatRoomOccupantDidJoin:(NSUInteger)userId roomJID:(NSString *)roomJID __attribute__((deprecated("Use 'chatRoomOccupantDidJoin:dialogID:' instead.")));

/**
 *  Called when user joined dialog.
 *
 *  @param userId   User's ID.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomOccupantDidJoin:(NSUInteger)userId dialogID:(NSString *)dialogID;

/**
 *  Called when user left room.
 *  
 *  @warning *Deprecated in QB iOS SDK 2.4:* Use 'chatRoomOccupantDidLeave:dialogID:' instead.
 *
 *  @param userId User's ID.
 *  @param roomJID     JID of room.
 */
- (void)chatRoomOccupantDidLeave:(NSUInteger)userId roomJID:(NSString *)roomJID __attribute__((deprecated("Use 'chatRoomOccupantDidLeave:dialogID:' instead.")));


/**
 *  Called when user left dialog.
 *
 *  @param userId   User's ID.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomOccupantDidLeave:(NSUInteger)userId dialogID:(NSString *)dialogID;

/**
 *  Called when user was updated in room.
 *
 *  @warning *Deprecated in QB iOS SDK 2.4:* Use 'chatRoomOccupantDidUpdate:dialogID:' instead.
 *
 *  @param userId User's ID.
 *  @param roomJID     JID of room.
 */
- (void)chatRoomOccupantDidUpdate:(NSUInteger)userId roomJID:(NSString *)roomJID __attribute__((deprecated("Use 'chatRoomOccupantDidUpdate:dialogID:' instead.")));

/**
 *  Called when user was updated in dialog.
 *
 *  @param userId   User's ID.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomOccupantDidUpdate:(NSUInteger)userId dialogID:(NSString *)dialogID;

/**
 Called in case receiving list of online users
 
 @warning *Deprecated in QB iOS SDK 2.4:* Use 'chatRoomDidReceiveListOfOnlineUsers:dialogID:' instead.
 
 @param users Array of joined users
 @param roomJID JID of room
 */
- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users roomJID:(NSString *)roomJID __attribute__((deprecated("Use 'chatRoomDidReceiveListOfOnlineUsers:dialogID:' instead.")));

/**
 *  Called in case of receiving list of online users in dialog.
 *
 *  @param users    Array of joined users.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users dialogID:(NSString *)dialogID;

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


