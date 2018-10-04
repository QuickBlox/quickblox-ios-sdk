//
//  QBPushNotificationsConsts.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

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

// Notification type
extern NSString * const kQBMNotificationTypePush;
extern NSString * const kQBMNotificationTypeEmail;

// Push type
extern NSString * const kQBMPushTypeAPNS;
extern NSString * const kQBMPushTypeAPNSVOIP;
extern NSString * const kQBMPushTypeGCM;
extern NSString * const kQBMPushTypeMPNS;

NS_ASSUME_NONNULL_END
