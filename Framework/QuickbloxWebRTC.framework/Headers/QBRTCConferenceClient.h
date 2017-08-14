//
//  QBRTCConferenceClient.h
//  QuickbloxWebRTC
//
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import "QBRTCBaseClient.h"

#import "QBRTCConferenceClientDelegate.h"
#import "QBRTCTypes.h"

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

@interface QBRTCConferenceClient (Deprecated)

/**
 *  Send create session request.
 *
 *  @note Returns session without ID. When session will be created on server
 *  ID will be assigned and session will be returned in 'didCreateNewSession:' callback.
 *
 *  @see QBRTCConferenceClientDelegate
 *
 *  @param chatDialogID chat dialog ID
 *
 *  @warning Deprecated in 2.6.1. Use 'createSessionWithChatDialogID:conferenceType:' instead. This deprecated method will automatically create session with conference type QBRTCConferenceTypeVideo.
 */
- (QBRTCConferenceSession *)createSessionWithChatDialogID:(NSString *)chatDialogID DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.6.1. Use 'createSessionWithChatDialogID:conferenceType:' instead. This deprecated method will automatically create session with conference type QBRTCConferenceTypeVideo.");

@end

NS_ASSUME_NONNULL_END
