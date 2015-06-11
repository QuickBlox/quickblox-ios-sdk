//
//  QBMSubscription.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//
#import "Entity.h"
#import "QBMSubscription.h"
#import "QBMessagesEnums.h"

/** QBMSubscription class declaration. */
/** Overview */
/** Class represents user subscription to push chanell */

@interface QBMSubscription : Entity <NSCoding, NSCopying>{
	QBMNotificationChannel notificationChannel;
	NSString *deviceUDID;
    NSString *devicePlatform;
    NSString *url;
}
/** Declare which notification channels could be used to notify user about events. */
@property (nonatomic) QBMNotificationChannel notificationChannel;

/** Device UDID */
@property (nonatomic, retain) NSString *deviceUDID;

/** Device platform name */
@property (nonatomic, retain) NSString *devicePlatform;

/** Url parameter have to be set in case of using http_request type notification_channel. This url will be posted with event data when event occurs. */
@property (nonatomic, retain) NSString *url;


/** Create new subscription
 @return New instance of QBMSubscription
 */
+ (QBMSubscription *)subscription;

#pragma mark -
#pragma mark Converters

+ (enum QBMNotificationChannel)notificationChannelFromString:(NSString *)notificationChannel;
+ (NSString *)notificationChannelToString:(enum QBMNotificationChannel)notificationChannel;

@end
