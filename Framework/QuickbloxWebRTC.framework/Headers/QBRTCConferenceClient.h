//
//  QBRTCConferenceClient.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCBaseClient.h"

#import "QBRTCConferenceClientDelegate.h"

@class QBRTCConferenceSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  QBRTCConferenceClient class interface.
 *  Represents conference client and session management.
 *
 *  @note Enterprise-only feature, conferenceEndpoint param must be set in QBRTCConfig
 *
 *  @see QBRTCConfig, https://quickblox.com/plans/
 */
@interface QBRTCConferenceClient : QBRTCBaseClient

/**
 *  QBRTCConferenceClient shared instance
 *
 *  @return QBRTCConferenceClient instance
 */
+ (instancetype)instance;

/**
 *  Add delegate to the observers list.
 *
 *  @param delegate delegate that conforms to QBRTCConferenceClientDelegate protocol
 *
 *  @see QBRTCConferenceClientDelegate
 */
- (void)addDelegate:(id<QBRTCConferenceClientDelegate>)delegate;

/**
 *  Remove delegate from the observers list.
 *
 *  @param delegate delegate that conforms to QBRTCConferenceClientDelegate protocol
 *
 *  @see QBRTCConferenceClientDelegate
 */
- (void)removeDelegate:(id<QBRTCConferenceClientDelegate>)delegate;

/**
 *  Send create session request.
 *
 *  @note Returns session without ID. When session will be created on server
 *  ID will be assigned and session will be returned in 'didCreateNewSession:' callback.
 *
 *  @see QBRTCConferenceClientDelegate
 *
 *  @param chatDialogID chat dialog ID
 */
- (QBRTCConferenceSession *)createSessionWithChatDialogID:(NSString *)chatDialogID;

@end

NS_ASSUME_NONNULL_END
