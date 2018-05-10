//
//  QBChatDelegate.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class QBContactList, QBChatMessage, QBPrivacyList, QBContactListItem;

//MARK: - Manage chat connection callbacks

@protocol QBChatConnectionProtocol
@optional

/** Called whenever QBChat did connect. */
- (void)chatDidConnect;

/**
 Called whenever connection process did not finish successfully.
 
 @param error connection error
 */
- (void)chatDidNotConnectWithError:(NSError *)error;

/**
 Called whenever QBChat connection error happened.
 @note See https://xmpp.org/rfcs/rfc3920.html#streams-error-conditions.
 
 @param error Stream error.
 */
- (void)chatDidFailWithStreamError:(NSError *)error;

/**
 Called whenever QBChat connection disconnect happened.
 
 @param error Error.
 */
- (void)chatDidDisconnectWithError:(NSError *)error;

/**
 Called whenever QBChat did accidentally disconnect.
 @note For example, if on the iPhone, one may want to prevent auto reconnect when WiFi is not available.
 */
- (void)chatDidAccidentallyDisconnect;

/** Called after successful connection to chat after disconnect. */
- (void)chatDidReconnect;

@end

// MARK: - Manage chat receive message callback's

@protocol QBChatReceiveMessageProtocol
@optional

/**
 Called whenever new private message was received from QBChat.
 @note Will be called only on recipient device
 
 @param message Message received from Chat
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message;

/**
 Called whenever new system message was received from QBChat.
 @note Will be called only on recipient device
 
 @param message Message that was received from Chat
 */
- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message;

/**
 Called whenever group chat dialog did receive a message.
 @note Will be called on both recepients' and senders' device (with corrected time from server)
 
 @param message Received message.
 @param dialogID QBChatDialog identifier.
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message
                     fromDialogID:(NSString *)dialogID;

//MARK: Delivered / Read status

/**
 Called whenever message was delivered to user.

 @param messageID Message identifier
 @param dialogID Dialog identifier
 @param userID User identifier
 */
- (void)chatDidDeliverMessageWithID:(NSString *)messageID
                           dialogID:(NSString *)dialogID
                           toUserID:(NSUInteger)userID;

/**
 Called whenever message was read by opponent user.
 
 @param messageID Message identifier
 @param dialogID Dialog identifier
 @param readerID Reader user identifier
 */
- (void)chatDidReadMessageWithID:(NSString *)messageID
                        dialogID:(NSString *)dialogID
                        readerID:(NSUInteger)readerID;

@end

//MARK: - Privacy

@protocol QBChatPrivacyProtocol
@optional

/**
 Called in case of receiving privacy list names.
 
 @param listNames array with privacy list names
 */
- (void)chatDidReceivePrivacyListNames:(NSArray<NSString *> *)listNames;

/**
 Called in case of receiving privacy list.
 
 @param privacyList list with privacy items
 */
- (void)chatDidReceivePrivacyList:(QBPrivacyList *)privacyList;

/**
 Called when you failed to receive privacy list names
 @param error Error
 */
- (void)chatDidNotReceivePrivacyListNamesDueToError:(NSError *)error;

/**
 Called whenever you have failed to receive a list of privacy items.
 
 @param name Privacy list name
 @param error Error
 */
- (void)chatDidNotReceivePrivacyListWithName:(NSString *)name
                                       error:(NSError *)error;

/**
 Called whenever you have successfully created or edited a list.
 
 @param name Privacy list name
 */
- (void)chatDidSetPrivacyListWithName:(NSString *)name;

/**
 Called whenever you have successfully set a default privacy list.
 
 @param name default privacy list name
 */
- (void)chatDidSetDefaultPrivacyListWithName:(NSString *)name;

/**
 Called whenever you have failed to create or edit a privacy list.

 @param name Privacy list name
 @param error Error
 */
- (void)chatDidNotSetPrivacyListWithName:(NSString *)name
                                   error:(NSError *)error;

/**
Called whenever you have failed to set a default privacy list.

@param name Privacy list name
@param error Error
 */
- (void)chatDidNotSetDefaultPrivacyListWithName:(NSString *)name
                                          error:(NSError *)error;

/**
 Called whenever you have removed a privacy list.
 
 @param name Privacy list name
 */
- (void)chatDidRemovedPrivacyListWithName:(NSString *)name;

@end

// MARK: - Manage contact list callbacks's

@protocol QBChatContactListProtocol
@optional

/**
 Called in case contact request was received.

 @param userID User ID from received contact request
 */
- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID;

/**
 Called whenever contact list was changed.

 @param contactList Contact list
 */
- (void)chatContactListDidChange:(QBContactList *)contactList;

/**
 Called whenever contact list was populated
 
 @param contactList Contact list
 */
- (void)chatContactListDidPopulate:(QBContactList *)contactList;
/**
 Called in case when user's from contact list online status has been changed.
 
 @param userID User which online status has changed.
 @param isOnline New user status (online or offline).
 @param status Custom user status.
 */
- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID
                                 isOnline:(BOOL)isOnline
                                   status:(nullable NSString *)status;

/**
 Called whenever user has accepted your contact request.
 
 @param userID User ID who did accept your contact request.
 */
- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID;

/**
 Called whenever user has rejected your contact request.
 
 @param userID User ID who did reject your contact reqiest.
 */
- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID;

@end

//MARK: - Manage received presence callback

@protocol QBChatPresenceProtocol
@optional

/**
 Called in case of receiving presence with status.

 @param status Recieved presence status.
 @param userID User ID who did send presence.
 */
- (void)chatDidReceivePresenceWithStatus:(NSString *)status
                                fromUser:(NSInteger)userID;

@end

/**
 QBChatDelegate protocol definition.
 This protocol defines methods signatures for callbacks.
 Implement this protocol in your class and add [QBChat instance].addDelegate to your implementation
 instance to receive callbacks from QBChat
 */
@protocol QBChatDelegate <NSObject, QBChatConnectionProtocol, QBChatReceiveMessageProtocol,
QBChatContactListProtocol, QBChatPrivacyProtocol, QBChatPresenceProtocol>

@end

NS_ASSUME_NONNULL_END
