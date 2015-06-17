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
} QBMEventType;

// Event notification types
typedef enum QBMNotificationType{
	QBMNotificationTypePush,
    QBMNotificationTypeEmail,
} QBMNotificationType;

// Event push types
typedef enum QBMPushType{
    QBMPushTypeUndefined = 0,
    QBMPushTypeAPNS = 1,
    QBMPushTypeGCM = 2,
    QBMPushTypeMPNS = 3,
    QBMPushTypeBBPS = 4
} QBMPushType;

// Notification channels
typedef enum QBMNotificationChannel{
    QBMNotificationChannelEmail,
    QBMNotificationChannelAPNS,
    QBMNotificationChannelGCM,
    QBMNotificationChannelMPNS,
    QBMNotificationChannelBBPS,
} QBMNotificationChannel;