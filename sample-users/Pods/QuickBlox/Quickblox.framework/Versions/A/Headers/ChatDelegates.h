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
 set [QBChat instance].delegate to your implementation instance to receive callbacks from QBChat
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
 */
- (void)chatDidNotLogin;

/**
 didNotSendMessage fired when message cannot be send to user
 
 @param message message passed to sendMessage method into QBChat
 @param error Error
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message error:(NSError *)error;

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from Chat
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message;

/**
 didFailWithError fired when connection error occurs
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithError:(NSInteger)code;

/**
 Called in case receiving presence
 
 @param userID User ID from which received presence
 @param type Presence type
 */
- (void)chatDidReceivePresenceOfUser:(NSUInteger)userID type:(NSString *)type;


#pragma mark -
#pragma mark Contact list

/**
 Called in case receiving contact request
 
 @param userID User ID from which received contact request
 */
- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID;

/**
 Called in case changing contact list
 */
- (void)chatContactListDidChange:(QBContactList *)contactList;

/**
 Called in case changing contact's online status
 
 @param userID User which online status has changed
 @param isOnline New user status (online or offline)
 @param status Custom user status
 */
- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status;


#pragma mark -
#pragma mark Rooms

/**
 Called in case received list of available to join rooms.
 
 @rooms Array of rooms
 */
- (void)chatDidReceiveListOfRooms:(NSArray *)rooms;

/**
 Called when room received message. It will be fired each time when room received message from any user
 
 @param message Received message
 @param roomName Name of room which reeived message
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName;

/**
 Called when room receives a message.
 
 @param message Received message
 @param roomJID Room JID
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID;

/**
 Called when received room information.
 
 @param information Room information
 @param roomName Name of room
 */
- (void)chatRoomDidReceiveInformation:(NSDictionary *)information room:(NSString *)roomName;

/**
 Fired when room was successfully created
 */
- (void)chatRoomDidCreate:(NSString *)roomName;

/**
 Fired when you did enter to room
 
 @param room which you have joined
 */
- (void)chatRoomDidEnter:(QBChatRoom *)room;

/**
 Called when you didn't enter to room
 
 @param room Name of room which you haven't joined
 @param error Error
 */
- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error;

/**
 Called when you didn't enter to room
 
 @param roomJID  JID of room which you haven't joined
 @param error Error
 */
- (void)chatRoomDidNotEnterRoomWithJID:(NSString *)roomJID error:(NSError *)error;

/**
 Fired when you did leave room
 
 @param roomName Name of room which you have leaved
 */
- (void)chatRoomDidLeave:(NSString *)roomName;

/**
 Fired when you did leave room
 
 @param roomJID JID of room which you have leaved
 */
- (void)chatRoomDidLeaveRoomWithJID:(NSString *)roomJID;

/**
 Fired when you did destroy room
 
 @param roomName of room which you have destroyed
 */
- (void)chatRoomDidDestroy:(NSString *)roomName;

/**
 Called in case changing online users
 
 @param onlineUsers Array of online users
 @param roomName Name of room in which have changed online users
 */
- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName;

/**
 Called in case changing online users
 
 @param onlineUsers Array of online users
 @param roomJID JID of room in which has changed online users list
 */
- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers roomJID:(NSString *)roomJID;

/**
 Called in case receiving list of users who can join room
 
 @param users Array of users which are able to join room
 @param roomName Name of room which provides access to join
 */
- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName;

/**
 Called in case receiving list of online users
 
 @param users Array of joined users
 @param roomName Name of room
 */
- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName;

/**
 Called in case receiving list of online users
 
 @param users Array of joined users
 @param roomJID JID of room
 */
- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users roomJID:(NSString *)roomJID;


#pragma mark -
#pragma mark Video Chat

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 */
-(void) chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString*)sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType;

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 @param customParameters Custom caller parameters
 */
-(void) chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString*)sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType customParameters:(NSDictionary *)customParameters;

/**
 Called in case when you are calling to user, but hi hasn't answered
 
 @param userID ID of opponent
 */
-(void) chatCallUserDidNotAnswer:(NSUInteger)userID;

/**
 Called in case when opponent has accepted you call
 
 @param userID ID of opponent
 */
-(void) chatCallDidAcceptByUser:(NSUInteger)userID;

/**
 Called in case when opponent has accepted you call
 
 @param userID ID of opponent
 @param customParameters Custom caller parameters
 */
-(void) chatCallDidAcceptByUser:(NSUInteger)userID customParameters:(NSDictionary *)customParameters;

/**
 Called in case when opponent has rejected you call
 
 @param userID ID of opponent
 */
-(void) chatCallDidRejectByUser:(NSUInteger)userID;

/**
 Called in case when opponent has finished call
 
 @param userID ID of opponent
 @param status Reason of finish call. There are 2 reasons: 1) Opponent did not answer - 'kStopVideoChatCallStatus_OpponentDidNotAnswer'. 2) Opponent finish call with method 'finishCall' - 'kStopVideoChatCallStatus_Manually'
 */
-(void) chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status;

/**
 Called in case when opponent has finished call
 
 @param userID ID of opponent
 @param status Reason of finish call. There are 2 reasons: 1) Opponent did not answer - 'kStopVideoChatCallStatus_OpponentDidNotAnswer'. 2) Opponent finish call with method 'finishCall' - 'kStopVideoChatCallStatus_Manually'
 @param customParameters Custom caller parameters
 */
-(void) chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status customParameters:(NSDictionary *)customParameters;

/**
 Called in case when call has started
 
 @param userID ID of opponent
 @param sessionID ID of session
 */
-(void) chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID;

/**
 Called in case when start using TURN relay for video chat (not p2p).
 */
- (void)didStartUseTURNForVideoChat;


#pragma mark -
#pragma mark Custom audio session

/**
 Called in case when user uses custom audio session for video chat
 
 @param buffer Audio buffer
 */
- (void)didReceiveAudioBuffer:(AudioBuffer)buffer;


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
 @param userID privacy list name
 */
- (void)chatDidReceiveUserIsTypingFromUserWithID:(NSUInteger)userID;

/**
 Called when you received a chat status "user stop typing"
 @param userID privacy list name
 */
- (void)chatDidReceiveUserStopTypingFromUserWithID:(NSUInteger)userID;


#pragma mark -
#pragma mark Delivered status

/**
 Called when you received a confirmation about message delivery
 
 @warning *Deprecated in QB iOS SDK 2.0.7:* Use chatDidDeliverMessageWithID: instead
 
 @param packetID ID of an original message
 */
- (void)chatDidDeliverMessageWithPacketID:(NSString *)packetID __attribute__((deprecated("use 'chatDidDeliverMessageWithID:' instead.")));

/**
 Called when you received a confirmation about message delivery
 @param messageID ID of an original message
 */
- (void)chatDidDeliverMessageWithID:(NSString *)messageID;


#pragma mark -
#pragma mark Read status

/**
 Called when you received a confirmation about message read
 @param messageID ID of an original message
 */
- (void)chatDidReadMessageWithID:(NSString *)messageID;


#pragma mark -
#pragma mark Draft

- (void)chatTURNServerDidDisconnect;
- (void)chatTURNServerdidFailWithError:(NSError *)error;
- (void)chatDidPassConnectionStep:(NSUInteger)step totalSteps:(NSUInteger)totalSteps;

- (void)chatDidExceedWriteVideoQueueMaxOperationsThresholdWithCount:(NSUInteger)operationsInQueue;
- (void)chatDidExceedWriteAudioQueueMaxOperationsThresholdWithCount:(NSUInteger)operationsInQueue;

@end


