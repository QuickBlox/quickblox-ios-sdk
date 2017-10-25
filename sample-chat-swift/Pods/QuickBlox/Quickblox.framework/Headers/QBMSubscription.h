//
//  QBMSubscription.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//
#import "QBCEntity.h"
#import "QBMSubscription.h"
#import "QBPushNotificationsEnums.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 *  QBMSubscription class interface.
 *  Class represents user subscription to push channel.
 */
@interface QBMSubscription : QBCEntity <NSCoding, NSCopying>

/**
 *  Declare which notification channels could be used to notify user about events.
 */
@property (nonatomic, assign) QBMNotificationChannel notificationChannel;

/** 
 *  Device UDID.
 */
@property (nonatomic, copy, nullable) NSString *deviceUDID;

/**
 *  Device platform name.
 */
@property (nonatomic, copy, nullable) NSString *devicePlatform;

/** 
 *  Identifies client device in 3-rd party service like APNS, APNSVOIP C2DM, MPNS, BBPS.
 */
@property(nonatomic, strong, nullable) NSData *deviceToken;

/** 
 *  Create new subscription.
 *
 *  @return New instance of QBMSubscription
 */
+ (QBMSubscription *)subscription;

//MARK: - Converters

+ (QBMNotificationChannel)notificationChannelFromString:(nullable NSString *)notificationChannel;
+ (nullable NSString *)notificationChannelToString:(QBMNotificationChannel)notificationChannel;

@end

NS_ASSUME_NONNULL_END
