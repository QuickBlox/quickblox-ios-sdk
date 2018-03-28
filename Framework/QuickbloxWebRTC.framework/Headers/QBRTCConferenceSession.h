//
//  QBRTCConferenceSession.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import "QBRTCBaseSession.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Conference session class interface.
 *
 *  @note Enterprise-only feature
 *
 *  @see https://quickblox.com/plans/
 */
@interface QBRTCConferenceSession : QBRTCBaseSession

/**
 *  Conference session ID.
 * 
 *  @note Nil when session is newly created. Only assigned after callback from server 'didCreateNewSession:'.
 *
 *  @see QBRTCConferenceClientDelegate
 */
@property (strong, nonatomic, readonly, nullable) NSNumber *ID;

/**
 *  Session chat dialog ID.
 */
@property (strong, nonatomic, readonly) NSString *chatDialogID;

/**
 *  Session current active publishers list.
 */
@property (strong, nonatomic, readonly) NSArray <NSNumber *> *publishersList;

/**
 *  Request list of online participants in current room.
 *
 *  @note Session must receive session created callback first from server.
 *
 *  @param completionBlock completion block with publishers and listeners list
 */
- (void)listOnlineParticipantsWithCompletionBlock:(void(^)(NSArray <NSNumber *> *publishers, NSArray <NSNumber *> *listeners))completionBlock;

/**
 *  Perform join room as publisher.
 *
 *  @discussion 'session:didJoinChatDialogWithID:publishersList:' will be called upon successful join.
 *
 *  @see QBRTCConferenceClientDelegate
 */
- (void)joinAsPublisher;

/**
 *  Leave chat room and close session.
 *
 *  @discussion 'sessionWillClose:' will be called when all connection are closed, 'sessionDidClose:withTimeout:' will be called when session will be successfully closed by server.
 */
- (void)leave;

/**
 *  Subscribe to publisher's with user ID feed.
 *
 *  @param userID active publisher's user ID
 *
 *  @discussion If you want to receive publishers feeds, you need to subscribe to them.
 *
 *  @note User must be an active publisher.
 */
- (void)subscribeToUserWithID:(NSNumber *)userID;

/**
 *  Unsubscribe from publisher's with user ID feed.
 *
 *  @param userID active publisher's user ID
 *
 *  @discussion Do not need to be used when publisher did leave room, in that case unsibscribing will be performing automatically. Use if you need to unsubscribe from active publisher's feed.
 *
 *  @note User must be an active publisher.
 */
- (void)unsubscribeFromUserWithID:(NSNumber *)userID;

@end

NS_ASSUME_NONNULL_END
