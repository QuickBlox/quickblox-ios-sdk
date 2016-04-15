//
//  ChatDelegates.h
//  QBChat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

/**
 QBChatDelegate protocol definition
 This protocol defines methods signatures for callbacks. Implement this protocol in your class and
 add [QBChat instance].addDelegate to your implementation instance to receive callbacks from QBChat
 */

@class QBContactList, QBChatMessage, QBPrivacyList, QBContactListItem;

@protocol QBChatDelegate <NSObject>
@optional

#pragma mark -
#pragma mark Base IM

/**
 didReceiveMessage fired when new 1-1 message was received from QBChat
 
 @note Will fire only on recipient device
 @param message Message received from Chat
 */
- (void)chatDidReceiveMessage:(QB_NONNULL QBChatMessage *)message;

/**
 didReceiveSystemMessage fired when new system message was received from QBChat
 
 @note Will fire only on recipient device
 @param message Message received from Chat
 */
- (void)chatDidReceiveSystemMessage:(QB_NONNULL QBChatMessage *)message;

/**
 chatDidFailWithStreamError fired when connection error
 
 @param error XMPPStream Error
 */
- (void)chatDidFailWithStreamError:(QB_NULLABLE NSError *)error;

/**
 *  Fired when XMPP stream established connection
 */
- (void)chatDidConnect;

/**
 chatDidNotConnectWithError fired when connect process did not finished successfully
 
 @param error Error
 */
- (void)chatDidNotConnectWithError:(QB_NULLABLE NSError *)error;

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
- (void)chatContactListDidChange:(QB_NONNULL QBContactList *)contactList;

/**
 Called in case changing contact's online status
 
 @param userID User which online status has changed
 @param isOnline New user status (online or offline)
 @param status Custom user status
 */
- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(QB_NULLABLE NSString *)status;

/**
 * Called when user has accepted your contact request
 *
 * @param userID User ID from which accepted your request
 * */
- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID;

/**
 * Called when user has rejected your contact request
 *
 * @param userID User ID from which rejected your request
 */
- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID;

#pragma mark -
#pragma mark Presence
/**
 *  Called in case receiving presence with status
 *
 *  @param status Recieved presence's status
 *  @param userID User ID from which received presence
 */
- (void)chatDidReceivePresenceWithStatus:(QB_NONNULL NSString *)status fromUser:(NSInteger)userID;

#pragma mark -
#pragma mark Rooms

/**
 *  Called when group chat dialog receives message.
 *
 *  @note Will fire both on recepient and sender device (with corrected time from server)
 *  @param message  Received message.
 *  @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomDidReceiveMessage:(QB_NONNULL QBChatMessage *)message fromDialogID:(QB_NONNULL NSString *)dialogID;

#pragma mark -
#pragma mark Privacy

/**
 Called in case receiving privacy list names
 
 @param listNames array with privacy list names
 */
- (void)chatDidReceivePrivacyListNames:(QB_NONNULL NSArray QB_GENERIC(NSString *) *)listNames;

/**
 Called in case receiving privacy list
 
 @param privacyList list with privacy items
 */
- (void)chatDidReceivePrivacyList:(QB_NONNULL QBPrivacyList *)privacyList;

/**
 Called when you failed to receive privacy list names
 
 @param error Error
 */
- (void)chatDidNotReceivePrivacyListNamesDueToError:(QB_NULLABLE id)error;

/**
 Called when you failed to receive a list of privacy items
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotReceivePrivacyListWithName:(QB_NONNULL NSString *)name error:(QB_NULLABLE id)error;

/**
 Called when you successfully created/edited a list
 @param name privacy list name
 */
- (void)chatDidSetPrivacyListWithName:(QB_NONNULL NSString *)name;

/**
 Called when you successfully set an active privacy list
 @param name active privacy list name
 */
- (void)chatDidSetActivePrivacyListWithName:(QB_NONNULL NSString *)name;

/**
 Called when you successfully set a default privacy list
 @param name default privacy list name
 */
- (void)chatDidSetDefaultPrivacyListWithName:(QB_NONNULL NSString *)name;

/**
 Called when you failed to create/edit a privacy list
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotSetPrivacyListWithName:(QB_NONNULL NSString *)name error:(QB_NULLABLE id)error;

/**
 Called when you failed to create/edit an active privacy list
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotSetActivePrivacyListWithName:(QB_NONNULL NSString *)name error:(QB_NULLABLE id)error;

/**
 Called when you failed to set a default privacy list
 @param name privacy list name
 @param error Error
 */
- (void)chatDidNotSetDefaultPrivacyListWithName:(QB_NONNULL NSString *)name error:(QB_NULLABLE id)error;

/**
 Called when you removed a privacy list
 @param name privacy list name
 */
- (void)chatDidRemovedPrivacyListWithName:(QB_NONNULL NSString *)name;

#pragma mark -
#pragma mark Delivered status

/**
 *  Called when message is delivered to user.
 *
 *  @param messageID Message identifier.
 *  @param dialogID  Dialog identifier.
 *  @param userID  User identifier.
 */
- (void)chatDidDeliverMessageWithID:(QB_NONNULL NSString *)messageID dialogID:(QB_NONNULL NSString *)dialogID toUserID:(NSUInteger)userID;

#pragma mark -
#pragma mark Read status

/**
 *  Called when message is read by opponent.
 *
 *  @param messageID Message identifier.
 *  @param dialogID  Dialog identifier.
 *  @param readerID  Reader identifier.
 */
- (void)chatDidReadMessageWithID:(QB_NONNULL NSString *)messageID dialogID:(QB_NONNULL NSString *)dialogID readerID:(NSUInteger)readerID;

@end


