/*
 *  Enums.h
 *  MessagesService
 *

 *  Copyright 2011 QuickBlox team. All rights reserved.
 *
 */

// Event types
typedef enum QBMEventType{
	QBMEventTypeOneShot,
    QBMEventTypeFixedDate,
    QBMEventTypePeriodDate,
    QBMEventTypeMultiShot
} QBMEventType;

// Event notification types
typedef enum QBMNotificationType{
	QBMNotificationTypePush,
    QBMNotificationTypeEmail,
    QBMNotificationTypeRequest,
    QBMNotificationTypePull
} QBMNotificationType;

// Event push types
typedef enum QBMPushType{
    QBMPushTypeAPNS = 1,
    QBMPushTypeGCM = 2,
    QBMPushTypeMPNS = 3,
    QBMPushTypeBBPS = 4
} QBMPushType;

// Notification channels
typedef enum QBMNotificatioChannel{
    QBMNotificatioChannelEmail,
    QBMNotificatioChannelAPNS,
    QBMNotificatioChannelGCM,
    QBMNotificatioChannelMPNS,
    QBMNotificatioChannelBBPS,
    QBMNotificatioChannelPull,
    QBMNotificatioChannelHttpRequest
} QBMNotificatioChannel;