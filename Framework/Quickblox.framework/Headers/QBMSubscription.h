//
//  QBMSubscription.h
//
//  Created by QuickBlox team
//  Copyright (c) 2017 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBCEntity.h>
#import <Quickblox/QBMSubscription.h>
#import <Quickblox/QBPushNotificationsEnums.h>

NS_ASSUME_NONNULL_BEGIN

/** 
 QBMSubscription class interface.
 Class represents user subscription to push channel.
 */
@interface QBMSubscription : QBCEntity <NSCoding, NSCopying>

/**
 Declare which notification channels could be used to notify user about events.
 */
@property (nonatomic, assign) QBMNotificationChannel notificationChannel;

/** 
 Device UDID.
 */
@property (nonatomic, copy, nullable) NSString *deviceUDID;

/**
 Device platform name.
 */
@property (nonatomic, copy, nullable) NSString *devicePlatform;

/** 
 Identifies client device in 3-rd party service like APNS, APNSVOIP, GCM, MPNS.
 */
@property(nonatomic, strong, nullable) NSData *deviceToken;

/** 
 Create new subscription.
 
 @return New instance of QBMSubscription
 */
+ (QBMSubscription *)subscription;

@end

NS_ASSUME_NONNULL_END
