//
//  QBMSubscription.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//
#import "QBCEntity.h"
#import "QBMSubscription.h"
#import "QBMessagesEnums.h"

/** QBMSubscription class declaration. */
/** Overview */
/** Class represents user subscription to push chanell */

@interface QBMSubscription : QBCEntity <NSCoding, NSCopying>

/** Declare which notification channels could be used to notify user about events. */
@property (nonatomic) QBMNotificationChannel notificationChannel;

/** Device UDID */
@property (nonatomic, copy) NSString *deviceUDID;

/** Device platform name */
@property (nonatomic, copy) NSString *devicePlatform;

/** Identifies client device in 3-rd party service like APNS, C2DM, MPNS, BBPS.*/
@property(nonatomic, strong) NSData *deviceToken;

/** Create new subscription
 @return New instance of QBMSubscription
 */
+ (QBMSubscription *)subscription;

#pragma mark -
#pragma mark Converters

+ (enum QBMNotificationChannel)notificationChannelFromString:(NSString *)notificationChannel;
+ (NSString *)notificationChannelToString:(enum QBMNotificationChannel)notificationChannel;

@end
