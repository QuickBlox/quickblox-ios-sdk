//
//  QBRTCConferenceClientDelegate.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import "QBRTCBaseClientDelegate.h"

#import "QBRTCTypes.h"

@class QBRTCConferenceSession;

/**
 *  Conference client protocol.
 *
 *  @note Enterprise-only feature
 *
 *  @see QBRTCConferenceClient, https://quickblox.com/plans/
 */
@protocol QBRTCConferenceClientDelegate <QBRTCBaseClientDelegate>

/**
 *  Protocol methods down below are optional and not required to be implemented.
 */
@optional

/**
 *  Called when session was created on server.
 *
 *  @param session QBRTCConferenceSession instance
 *
 *  @discussion When this method is called, session instance that was already created by QBRTCConferenceClient
 *  will be assigned valid session ID from server.
 *
 *  @see QBRTCConferenceSession, QBRTCConferenceClient
 */
- (void)didCreateNewSession:(QBRTCConferenceSession *)session;

/**
 *  Called when join to session is performed and acknowledged by server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param chatDialogID chat dialog ID
 *  @param publishersList array of user IDs, that are currently publishers
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didJoinChatDialogWithID:(NSString *)chatDialogID publishersList:(NSArray <NSNumber *> *)publishersList;

/**
 *  Called when new publisher did join.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param userID new publisher user ID
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didReceiveNewPublisherWithUserID:(NSNumber *)userID;

/**
 *  Called when publisher did leave.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param userID publisher that left user ID
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session publisherDidLeaveWithUserID:(NSNumber *)userID;

/**
 *  Called when session did receive error from server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param error received error from server
 *
 *  @note Error doesn't necessarily means that session is closed. Can be just a minor error that can be fixed/ignored.
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didReceiveError:(NSError *)error;

/**
 *  Called when slowlink was received.
 *
 *  @param session  QBRTCConferenceSession instance
 *  @param uplink   whether the issue is uplink or not
 *  @param nacks    number of nacks
 *
 *  @discussion this callback is triggered when serber reports trouble either sending or receiving media on the
 *  specified connection, typically as a consequence of too many NACKs received from/sent to the user in the last
 *  second: for instance, a slowLink with uplink=true means you notified several missing packets from server,
 *  while uplink=false means server is not receiving all your packets.
 *
 *  @note useful to figure out when there are problems on the media path (e.g., excessive loss), in order to 
 *  possibly react accordingly (e.g., decrease the bitrate if most of our packets are getting lost).
 *
 *  @see QBRTCConferenceSession
 */
- (void)session:(QBRTCConferenceSession *)session didReceiveSlowlinkWithUplink:(BOOL)uplink nacks:(NSNumber *)nacks;

/**
 *  Called when media receiving state was changed on server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param mediaType media type
 *  @param receiving whether media is receiving by server
 *
 *  @see QBRTCConferenceSession, QBRTCConferenceMediaType
 */
- (void)session:(QBRTCConferenceSession *)session didChangeMediaStateWithType:(QBRTCConferenceMediaType)mediaType receiving:(BOOL)receiving;

/**
 *  Session did initiate close request.
 *
 *  @param session QBRTCConferenceSession instance
 *
 *  @discussion 'sessionDidClose:withTimeout:' will be called after server will close session with callback
 *
 *  @see QBRTCConferenceSession
 */
- (void)sessionWillClose:(QBRTCConferenceSession *)session;

/**
 *  Called when session was closed completely on server.
 *
 *  @param session QBRTCConferenceSession instance
 *  @param timeout whether session was closed due to timeout on server
 *
 *  @see QBRTCConferenceSession
 */
- (void)sessionDidClose:(QBRTCConferenceSession *)session withTimeout:(BOOL)timeout;

@end
