/*
 *  Enums.h
 *  MessagesService
 *
 *  Copyright 2011 QuickBlox team. All rights reserved.
 *
 */

// Event types
typedef NS_ENUM(NSUInteger, QBMEventType) {
    
    QBMEventTypeOneShot,
    QBMEventTypeFixedDate,
    QBMEventTypePeriodDate
};

// Event notification types
typedef NS_ENUM(NSUInteger, QBMNotificationType) {
    
    QBMNotificationTypePush,
    QBMNotificationTypeEmail
};

// Event push types
typedef NS_ENUM(NSUInteger, QBMPushType) {
    
    QBMPushTypeUndefined,
    QBMPushTypeAPNS,
    QBMPushTypeAPNSVOIP,
    QBMPushTypeGCM,
    QBMPushTypeMPNS,
    QBMPushTypeBBPS
};

// Notification channels
typedef NS_ENUM(NSUInteger, QBMNotificationChannel) {
    
    QBMNotificationChannelEmail,
    QBMNotificationChannelAPNS,
    QBMNotificationChannelAPNSVOIP,
    QBMNotificationChannelGCM,
    QBMNotificationChannelMPNS,
    QBMNotificationChannelBBPS
};
