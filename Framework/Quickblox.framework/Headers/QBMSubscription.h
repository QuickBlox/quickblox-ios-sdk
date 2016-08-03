//
//  QBMSubscription.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//
#import "QBCEntity.h"
#import "QBMSubscription.h"
#import "QBPushNotificationsEnums.h"

/** QBMSubscription class declaration. */
/** Overview */
/** Class represents user subscription to push channel */

@interface QBMSubscription : QBCEntity <NSCoding, NSCopying>

/** Declare which notification channels could be used to notify user about events. */
@property (nonatomic) QBMNotificationChannel notificationChannel;

/** Device UDID */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSString *deviceUDID;

/** Device platform name */
@property (nonatomic, copy, QB_NULLABLE_PROPERTY) NSString *devicePlatform;

/** Identifies client device in 3-rd party service like APNS, C2DM, MPNS, BBPS.*/
@property(nonatomic, strong, QB_NULLABLE_PROPERTY) NSData *deviceToken;

/** Create new subscription
 @return New instance of QBMSubscription
 */
+ (QB_NONNULL QBMSubscription *)subscription;

#pragma mark -
#pragma mark Converters

+ (enum QBMNotificationChannel)notificationChannelFromString:(QB_NULLABLE NSString *)notificationChannel;
+ (QB_NULLABLE NSString *)notificationChannelToString:(enum QBMNotificationChannel)notificationChannel;

@end
