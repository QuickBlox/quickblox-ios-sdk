//
//  ChatDelegates.h
//  QBChat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QBContactList, QBChatMessage, QBPrivacyList, QBContactListItem;

/**
 *  QBChatDelegate protocol definition.
 *  This protocol defines methods signatures for callbacks. Implement this protocol in your class and
 *  add [QBChat instance].addDelegate to your implementation instance to receive callbacks from QBChat
 */
@protocol QBChatDelegate <NSObject>
@optional

//MARK: - Base IM

/**
 *  Called whenever new private message was received from QBChat.
 *
 *  @param message Message received from Chat
 *
 *  @note Will be called only on recipient device
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message;

/**
 *  Called whenever new system message was received from QBChat.
 *
 *  @param message Message that was received from Chat
 *
 *  @note Will be called only on recipient device
 */
- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message;

/**
 *  Called whenever QBChat connection error happened.
 *
 *  @param error XMPPStream Error
 */
- (void)chatDidFailWithStreamError:(nullable NSError *)error;

/**
 *  Called whenever QBChat did connect.
 */
- (void)chatDidConnect;

/**
 *  Called whenever connection process did not finish successfully.
 *
 *  @param error connection error
 */
- (void)chatDidNotConnectWithError:(nullable NSError *)error;

/**
 *  Called whenever QBChat did accidentally disconnect.
 */
- (void)chatDidAccidentallyDisconnect;

/**
 *  Called after successful connection to chat after disconnect.
 */
- (void)chatDidReconnect;

//MARK: - Contact list

/**
 *  Called in case contact request was received.
 *
 *  @param userID User ID from received contact request
 */
- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID;

/**
 *  Called whenver contact list was changed.
 */
- (void)chatContactListDidChange:(QBContactList *)contactList;

/**
 *  Called in case when user's from contact list online status has been changed.
 *
 *  @param userID   User which online status has changed
 *  @param isOnline New user status (online or offline)
 *  @param status   Custom user status
 */
- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(nullable NSString *)status;

/**
 *  Called whenever user has accepted your contact request.
 *
 *  @param userID User ID who did accept your contact request
 */
- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID;

/**
 *  Called whenever user has rejected your contact request.
 *
 *  @param userID User ID who did reject your contact reqiest
 */
- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID;

//MARK: - Presence

/**
 *  Called in case of receiving presence with status.
 *
 *  @param status Recieved presence status
 *  @param userID User ID who did send presence
 */
- (void)chatDidReceivePresenceWithStatus:(NSString *)status fromUser:(NSInteger)userID;

//MARK: - Rooms

/**
 *  Called whenever group chat dialog did receive a message.
 *
 *  @param message  Received message.
 *  @param dialogID QBChatDialog identifier.
 *
 *  @note Will be called on both recepients' and senders' device (with corrected time from server)
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromDialogID:(NSString *)dialogID;

//MARK: - Privacy

/**
 *  Called in case of receiving privacy list names.
 *
 *  @param listNames array with privacy list names
 */
- (void)chatDidReceivePrivacyListNames:(NSArray<NSString *> *)listNames;

/**
 *  Called in case of receiving privacy list.
 *
 *  @param privacyList list with privacy items
 */
- (void)chatDidReceivePrivacyList:(QBPrivacyList *)privacyList;

/**
 *  Called when you failed to receive privacy list names
 *
 *  @param error Error
 */
- (void)chatDidNotReceivePrivacyListNamesDueToError:(nullable id)error;

/**
 *  Called whenever you have failed to receive a list of privacy items.
 *
 *  @param name privacy list name
 *  @param error Error
 */
- (void)chatDidNotReceivePrivacyListWithName:(NSString *)name error:(nullable id)error;

/**
 *  Called whenever you have successfully created or edited a list.
 *
 *  @param name privacy list name
 */
- (void)chatDidSetPrivacyListWithName:(NSString *)name;

/**
 *  Called whenever you have successfully set an active privacy list.
 *
 *  @param name active privacy list name
 */
- (void)chatDidSetActivePrivacyListWithName:(NSString *)name;

/**
 *  Called whenever you have successfully set a default privacy list.
 *
 *  @param name default privacy list name
 */
- (void)chatDidSetDefaultPrivacyListWithName:(NSString *)name;

/**
 *  Called whenever you have failed to create or edit a privacy list.
 *
 *  @param name     privacy list name
 *  @param error    Error
 */
- (void)chatDidNotSetPrivacyListWithName:(NSString *)name error:(nullable id)error;

/**
 *  Called whenever you have failed to create or edit an active privacy list.
 *
 *  @param name     privacy list name
 *  @param error    Error
 */
- (void)chatDidNotSetActivePrivacyListWithName:(NSString *)name error:(nullable id)error;

/**
 *  Called whenever you have failed to set a default privacy list.
 *
 *  @param name     privacy list name
 *  @param error    Error
 */
- (void)chatDidNotSetDefaultPrivacyListWithName:(NSString *)name error:(nullable id)error;

/**
 *  Called whenever you have removed a privacy list.
 *
 *  @param name privacy list name
 */
- (void)chatDidRemovedPrivacyListWithName:(NSString *)name;

//MARK: - Delivered status

/**
 *  Called whenever message was delivered to user.
 *
 *  @param messageID Message identifier
 *  @param dialogID  Dialog identifier
 *  @param userID   User identifier
 */
- (void)chatDidDeliverMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID toUserID:(NSUInteger)userID;

//MARK: - Read status

/**
 *  Called whenever message was read by opponent user.
 *
 *  @param messageID Message identifier
 *  @param dialogID  Dialog identifier
 *  @param readerID  Reader user identifier
 */
- (void)chatDidReadMessageWithID:(NSString *)messageID dialogID:(NSString *)dialogID readerID:(NSUInteger)readerID;

@end

NS_ASSUME_NONNULL_END
