//
//  Delegates.h
//  QBChat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kStopVideoChatCallStatus_OpponentDidNotAnswer @"kStopVideoChatCallStatus_OpponentDidNotAnswer"
#define kStopVideoChatCallStatus_Manually @"kStopVideoChatCallStatus_Manually"
#define kStopVideoChatCallStatus_BadConnection @"kStopVideoChatCallStatus_BadConnection"

/**
 QBChatDelegate protocol definition
 This protocol defines methods signatures for callbacks. Implement this protocol in your class and
 set [QBChat instance].delegate to your implementation instance to receive callbacks from QBChat
 */

@class QBContactList, QBChatRoom, QBChatMessage;

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
 
 @param message Message passed to sendMessage method into QBChat
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message;

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from Chat
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message;

/**
 didFailWithError fired when connection error occurs
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithError:(int)code;

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
 Called when received room information. 
 
 @param information Room information
 @param roomName Name of room 
 */
- (void)chatRoomDidReceiveInformation:(NSDictionary *)information room:(NSString *)roomName;

/**
 Fired when room was successfully created
 */
- (void)chatRoomDidCreate:(NSString*)roomName;

/**
 Fired when you did enter to room
 
 @param room which you have joined
 */
- (void)chatRoomDidEnter:(QBChatRoom *)room;

/**
 Called when you didn't enter to room
 
 @param room which you haven't joined
 @param error Error
 */
- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error;

/**
 Fired when you did leave room
 
 @param Name of room which you have leaved
 */
- (void)chatRoomDidLeave:(NSString *)roomName;

/**
 Fired when you did destroy room
 
 @param Name of room which you have destroyed
 */
- (void)chatRoomDidDestroy:(NSString *)roomName;

/**
 Called in case changing online users  
 
 @param onlineUsers Array of online users
 @param roomName Name of room in which have changed online users
 */
- (void)chatRoomDidChangeOnlineUsers:(NSArray *)onlineUsers room:(NSString *)roomName;

/**
 Called in case receiving list of users who can join room
 
 @param users Array of users which are able to join room
 @param roomName Name of room which provides access to join
 */
- (void)chatRoomDidReceiveListOfUsers:(NSArray *)users room:(NSString *)roomName;

/**
 Called in case receiving list of active users (joined)
 
 @param users Array of joined users
 @param roomName Name of room
 */
- (void)chatRoomDidReceiveListOfOnlineUsers:(NSArray *)users room:(NSString *)roomName;


#pragma mark -
#pragma mark Video Chat

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 */
-(void) chatDidReceiveCallRequestFromUser:(NSUInteger)userID conferenceType:(enum QBVideoChatConferenceType)conferenceType;

/**
 Called in case when opponent is calling to you
 
 @param userID ID of uopponent
 @param conferenceType Type of conference. 'QBVideoChatConferenceTypeAudioAndVideo' and 'QBVideoChatConferenceTypeAudio' values are available
 @param customParameters Custom caller parameters
 */
-(void) chatDidReceiveCallRequestFromUser:(NSUInteger)userID conferenceType:(enum QBVideoChatConferenceType)conferenceType customParameters:(NSDictionary *)customParameters;

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
 */
-(void) chatCallDidStartWithUser:(NSUInteger)userID;

/**
 Called in case when start using TURN relay for video chat (not p2p).
 */
- (void)didStartUseTURNForVideoChat;


// TDB
- (void)chatTURNServerDidDisconnect;
- (void)chatTURNServerdidFailWithError:(NSError *)error;
- (void)chatDidPassConnectionStep:(int)step totalSteps:(int)totalSteps;

- (void)chatDidEexceedWriteVideoQueueMaxOperationsThresholdWithCount:(int)operationsInQueue;
- (void)chatDidEexceedWriteAudioQueueMaxOperationsThresholdWithCount:(int)operationsInQueue;

@end


