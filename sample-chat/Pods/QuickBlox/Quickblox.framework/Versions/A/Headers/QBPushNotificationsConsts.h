/*
 *  Consts.h
 *  MessagesService
 *

 *  Copyright 2011 QuickBlox team. All rights reserved.
 *
 */

#import <Quickblox/QBNullability.h>
#import <Quickblox/QBGeneric.h>

extern NSString* const QB_NONNULL_S QBMEventMessagePayloadKey;

extern NSString* const QB_NONNULL_S QBMEventMessagePushAlertKey;
extern NSString* const QB_NONNULL_S QBMEventMessagePushBadgeKey;
extern NSString* const QB_NONNULL_S QBMEventMessagePushSoundKey;


// Push message dict keys
extern NSString* const QB_NONNULL_S QBMPushMessageAdditionalInfoKey;
extern NSString* const QB_NONNULL_S QBMPushMessageApsKey;
extern NSString* const QB_NONNULL_S QBMPushMessageAlertKey;
extern NSString* const QB_NONNULL_S QBMPushMessageAlertBodyKey;
extern NSString* const QB_NONNULL_S QBMPushMessageAlertActionLocKey;
extern NSString* const QB_NONNULL_S QBMPushMessageAlertLocKey;
extern NSString* const QB_NONNULL_S QBMPushMessageAlertLocArgsKey;
extern NSString* const QB_NONNULL_S QBMPushMessageAlertLaunchImageKey;
extern NSString* const QB_NONNULL_S QBMPushMessageBadgeKey;
extern NSString* const QB_NONNULL_S QBMPushMessageSoundKey;
extern NSString* const QB_NONNULL_S QBMPushMessageRichContentKey;

// Event types
extern NSString *const QB_NONNULL_S kQBMEventTypeOneShot;
extern NSString *const QB_NONNULL_S kQBMEventTypeFixedDate;
extern NSString *const QB_NONNULL_S kQBMEventTypePeriodDate;
extern NSString *const QB_NONNULL_S kQBMEventTypeMultiShot;

// Notification channels
extern NSString *const QB_NONNULL_S kQBMNotificationChannelsEmail;
extern NSString *const QB_NONNULL_S kQBMNotificationChannelsAPNS;
extern NSString *const QB_NONNULL_S kQBMNotificationChannelsGCM;
extern NSString *const QB_NONNULL_S kQBMNotificationChannelsMPNS;
extern NSString *const QB_NONNULL_S kQBMNotificationChannelsBBPS;
extern NSString *const QB_NONNULL_S kQBMNotificationChannelsPull;
extern NSString *const QB_NONNULL_S kQBMNotificationChannelsHttpRequest;

// Notification type
extern NSString *const QB_NONNULL_S kQBMNotificationTypePush;
extern NSString *const QB_NONNULL_S kQBMNotificationTypeEmail;
extern NSString *const QB_NONNULL_S kQBMNotificationTypeRequest;
extern NSString *const QB_NONNULL_S kQBMNotificationTypePull;

// Push type
extern NSString *const QB_NONNULL_S kQBMPushTypeAPNS;
extern NSString *const QB_NONNULL_S kQBMPushTypeGCM;
extern NSString *const QB_NONNULL_S kQBMPushTypeMPNS;
extern NSString *const QB_NONNULL_S kQBMPushTypeBBPS;


#define eventsElement @"events"
#define eventElement @"event"
