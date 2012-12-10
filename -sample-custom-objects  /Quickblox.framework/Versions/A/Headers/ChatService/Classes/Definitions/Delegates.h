//
//  Delegates.h
//  QBChat
//
//  Copyright 2012 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 QBChatServiceDelegate protocol definition
 This protocol defines methods signatures for callbacks. Implement this protocol in your class and
 set QBChat.delegate to your implementation instance to receive callbacks from QBChat
 */

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
 didNotSendMessage fired when message cannot be send to offline user
 
 @param message Message passed to sendMessage method into QBChat
 */
- (void)chatDidNotSendMessage:(QBChatMessage *)message;

/**
 didReceiveMessage fired when new message was received from QBChat
 
 @param message Message received from QBChat
 */
- (void)chatDidReceiveMessage:(QBChatMessage *)message;

/**
 didFailWithError fired when connection error occurs
 
 @param error Error code from QBChatServiceError enum
 */
- (void)chatDidFailWithError:(int)error;

/**
 Called in case receiving presence
 */
- (void)chatDidReceivePresenceOfUser:(NSUInteger)userID type:(NSString *)type;


#pragma mark -
#pragma mark Rooms

/**
 Fired when room was successfully created
 */
- (void)chatRoomDidCreate:(QBChatRoom*)room;

/**
 Called when room received message. It will be fired each time when room receiving message from any user
 */
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomName;

/**
 Fired when you did enter to room
 */
- (void)chatRoomDidEnter:(NSString *)roomName;

/**
 Called when you didn't enter to room
 */
- (void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error;

/**
 Fired when you did leave room
 */
- (void)chatRoomDidLeave:(NSString *)roomName;

/**
 Called in case changing occupant
 */
- (void)chatRoomDidChangeMembers:(NSArray *)members room:(NSString *)roomName;

/**
 Called in case receiving list of avaible to join rooms. Array rooms contains jids NSString type
 */
- (void)chatDidReceiveListOfRooms:(NSArray *)rooms;

/**
 Called in case receiving list of occupants of chat room. Array users contains jids NSString type
 */
- (void)chatDidReceiveListOfMembers:(NSArray *)users room:(NSString *)room;

@end
