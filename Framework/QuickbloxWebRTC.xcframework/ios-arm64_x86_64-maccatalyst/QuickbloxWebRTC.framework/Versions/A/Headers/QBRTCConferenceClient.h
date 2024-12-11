//
//  QBRTCConferenceClient.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2018 QuickBlox. All rights reserved.
//

#import <QuickbloxWebRTC/QBRTCBaseClient.h>

#import <QuickbloxWebRTC/QBRTCConferenceClientDelegate.h>
#import <QuickbloxWebRTC/QBRTCTypes.h>

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
 *  Send create session request with conference type.
 *
 *  @param chatDialogID chat dialog ID
 *  @param conferenceType conference type (video/audio)
 *
 *  @note Returns session without ID. When session will be created on server
 *  ID will be assigned and session will be returned in 'didCreateNewSession:' callback.
 *
 *  @see QBRTCConferenceClientDelegate, QBRTCConferenceType
 */
- (QBRTCConferenceSession *)createSessionWithChatDialogID:(NSString *)chatDialogID conferenceType:(QBRTCConferenceType)conferenceType;

@end

NS_ASSUME_NONNULL_END
