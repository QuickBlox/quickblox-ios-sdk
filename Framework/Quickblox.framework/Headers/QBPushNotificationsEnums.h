//
//  QBPushNotificationsEnums.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
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
