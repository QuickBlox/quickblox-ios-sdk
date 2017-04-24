//
//  QBMEvent.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCEntity.h"
#import "QBPushNotificationsEnums.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 *  QBMEvent class interface.
 *  Event representation. If you want to send Apple push - use the QBMApplePushEvent subclass. 
 */
@interface QBMEvent : QBCEntity <NSCoding, NSCopying>

/** 
 *  Event state. 
 *
 *  @discussion If you want to send specific notification more than once - just edit Event & set this field to 'YES', Then push will be send immediately, without creating a new one Event. */
@property (nonatomic, assign) BOOL active;

/** 
 *  Notification type.
 */
@property (nonatomic, assign) QBMNotificationType notificationType;

/** 
 *  Push type.
 */
@property (nonatomic, assign) QBMPushType pushType;

/** 
 *  Recipients - should contain a string of user ids divided by comas.
 */
@property (nonatomic, copy, nullable) NSString *usersIDs;

/** 
 *  Recipients - should contain a string of user external ids divided by comas.
 */
@property (nonatomic, copy, nullable) NSString *usersExternalIDs;

/** 
 *  Recipients tags - should contain a string of user tags divided by comas. 
 *  Recipients (users) must have at LEAST ONE tag that specified in list.
 */
@property (nonatomic, copy, nullable) NSString *usersTagsAny;

/** 
 *  Recipients tags - should contain a string of user tags divided by comas.
 *  Recipients (users) must exactly have ONLY ALL tags that specified in list. 
 */
@property (nonatomic, copy, nullable) NSString *usersTagsAll;

/** 
 *  Recipients tags - should contain a string of user tags divided by comas. 
 *  Recipients (users) mustn't have tags that specified in list. 
 */
@property (nonatomic, copy, nullable) NSString *usersTagsExclude;

/** 
 *  The name of the event. Service information. Only for the user.
 */
@property (nonatomic, copy, nullable) NSString *name;

/** 
 *  Event message.
 */
@property (nonatomic, strong, nullable) id message;

/** 
 *  Event type.
 */
@property (nonatomic, assign) QBMEventType type;

/** 
 *  The date of the event when it'll fire. 
 *
 *  @note Required: No, if the envent's 'type' = QBMEventTypeOneShot or QBMEventTypeMultiShot. Yes, if the envent's 'type' = QBMEventTypeFixedDate or QBMEventTypePeriodDate. 
 */
@property (nonatomic, strong, nullable) NSDate *date;

/** 
 *  Date of completion of the event. 
 *
 *  @note Can't be less than the 'date'. Required: Yes, if the envent's  'type' = QBMEventTypeMultiShot and 'notificationType' = QBMNotificationTypePull 
 */
@property (nonatomic, strong, nullable) NSDate *endDate;

/** The period of the event in seconds.
 *  Possible values:
 *  86400 (1 day)
 *  604800 (1 week)
 *  2592000 (1 month)
 *  31557600 (1 year).
 *  Required: No, if the envent's 'type' = QBMEventTypeOneShot, QBMEventTypeMultiShot or QBMEventTypeFixedDate
 *  Yes, if the envent's 'type' = QBMEventTypePeriodDate
 */
@property (nonatomic, assign) NSUInteger period;

/** 
 *  Event's occured count.
 */
@property (nonatomic, assign) NSUInteger occuredCount;

/** 
 *  Event's sender ID.
 */
@property (nonatomic, assign) NSUInteger senderID;

/** 
 *  Create new event.
 *
 *  @return New instance of QBMEvent
 */
+ (QBMEvent *)event;

- (void)prepareMessage;

//MARK: - Converters

+ (QBMEventType)eventTypeFromString:(nullable NSString *)eventType;
+ (nullable NSString *)eventTypeToString:(QBMEventType)eventType;

+ (QBMNotificationType)notificationTypeFromString:(nullable NSString *)notificationType;
+ (nullable NSString*)notificationTypeToString:(QBMNotificationType)notificationType;

+ (QBMPushType)pushTypeFromString:(nullable NSString *)pushType;
+ (nullable NSString *)pushTypeToString:(QBMPushType)pushType;

+ (NSString *)messageToString:(nullable NSDictionary<NSString *, NSString *> *)message;
+ (nullable NSDictionary<NSString *, NSString *> *)messageFromString:(nullable NSString *)message;

@end

NS_ASSUME_NONNULL_END
