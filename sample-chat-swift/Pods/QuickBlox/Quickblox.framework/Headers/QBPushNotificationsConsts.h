/*
 *  Consts.h
 *  MessagesService
 *
 *  Copyright 2011 QuickBlox team. All rights reserved.
 *
 */

NS_ASSUME_NONNULL_BEGIN

extern NSString * const QBMEventMessagePayloadKey;

extern NSString * const QBMEventMessagePushAlertKey;
extern NSString * const QBMEventMessagePushBadgeKey;
extern NSString * const QBMEventMessagePushSoundKey;

// Push message dict keys
extern NSString * const QBMPushMessageAdditionalInfoKey;
extern NSString * const QBMPushMessageApsKey;
extern NSString * const QBMPushMessageAlertKey;
extern NSString * const QBMPushMessageAlertBodyKey;
extern NSString * const QBMPushMessageAlertActionLocKey;
extern NSString * const QBMPushMessageAlertLocKey;
extern NSString * const QBMPushMessageAlertLocArgsKey;
extern NSString * const QBMPushMessageAlertLaunchImageKey;
extern NSString * const QBMPushMessageBadgeKey;
extern NSString * const QBMPushMessageSoundKey;
extern NSString * const QBMPushMessageRichContentKey;

// Event types
extern NSString * const kQBMEventTypeOneShot;
extern NSString * const kQBMEventTypeFixedDate;
extern NSString * const kQBMEventTypePeriodDate;
extern NSString * const kQBMEventTypeMultiShot;

// Notification channels
extern NSString * const kQBMNotificationChannelsEmail;
extern NSString * const kQBMNotificationChannelsAPNS;
extern NSString * const kQBMNotificationChannelsAPNSVOIP;
extern NSString * const kQBMNotificationChannelsGCM;
extern NSString * const kQBMNotificationChannelsMPNS;
extern NSString * const kQBMNotificationChannelsBBPS;
extern NSString * const kQBMNotificationChannelsPull;
extern NSString * const kQBMNotificationChannelsHttpRequest;

// Notification type
extern NSString * const kQBMNotificationTypePush;
extern NSString * const kQBMNotificationTypeEmail;
extern NSString * const kQBMNotificationTypeRequest;
extern NSString * const kQBMNotificationTypePull;

// Push type
extern NSString * const kQBMPushTypeAPNS;
extern NSString * const kQBMPushTypeAPNSVOIP;
extern NSString * const kQBMPushTypeGCM;
extern NSString * const kQBMPushTypeMPNS;
extern NSString * const kQBMPushTypeBBPS;

NS_ASSUME_NONNULL_END
