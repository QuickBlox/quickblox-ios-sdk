//
//  QBMEvent.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBCEntity.h"
#import "QBMessagesEnums.h"

/** QBMEvent class declaration. */
/** Overview */
/** Event representation. If you want to send Apple push - use the QBMApplePushEvent subclass. */

@interface QBMEvent : QBCEntity <NSCoding, NSCopying>{
    BOOL active;
    enum QBMNotificationType notificationType;
    
    enum QBMPushType pushType;
    
    NSString *usersIDs;
    NSString *usersTagsAny;
    NSString *usersTagsAll;
    NSString *usersTagsExclude;
    
    NSString *name;
    
    id message;
    enum QBMEventType type;
    
    NSDate *date;
    NSDate *endDate;
    NSUInteger period;
    
    NSUInteger occuredCount;
}

/** Event state. If you want to send specific notification more than once - just edit Event & set this field to 'YES', Then push will be send immediately, without creating a new one Event. */
@property (nonatomic) BOOL active;

/** Notification type*/
@property (nonatomic) QBMNotificationType notificationType;

/** Push type */
@property (nonatomic) QBMPushType pushType;

/** Recipients - should contain a string of user ids divided by comas.*/
@property (nonatomic,retain) NSString *usersIDs;

/** Recipients - should contain a string of user external ids divided by comas.*/
@property (nonatomic,retain) NSString *usersExternalIDs;

/** Recipients tags - should contain a string of user tags divided by comas. Recipients (users) must have at LEAST ONE tag that specified in list.*/
@property (nonatomic,retain) NSString *usersTagsAny;

/** Recipients tags - should contain a string of user tags divided by comas. Recipients (users) must exactly have ONLY ALL tags that specified in list. */
@property (nonatomic,retain) NSString *usersTagsAll;

/** Recipients tags - should contain a string of user tags divided by comas. Recipients (users) mustn't have tags that specified in list. */
@property (nonatomic,retain) NSString *usersTagsExclude;

/** The name of the event. Service information. Only for the user..*/
@property (nonatomic,retain) NSString *name;

/** Environment of the notification */
@property (nonatomic) BOOL isDevelopmentEnvironment;

/** Event message */
@property (nonatomic,retain) id message;

/** Event type */
@property (nonatomic) QBMEventType type;

/** The date of the event when it'll fire. Required: No, if the envent's 'type' = QBMEventTypeOneShot or QBMEventTypeMultiShot. Yes, if the envent's 'type' = QBMEventTypeFixedDate or QBMEventTypePeriodDate. */
@property (nonatomic,retain) NSDate *date;

/** Date of completion of the event. Can't be less than the 'date'. Required: Yes, if the envent's  'type' = QBMEventTypeMultiShot and 'notificationType' = QBMNotificationTypePull **/
@property (nonatomic,retain) NSDate *endDate;

/** The period of the event in seconds.
 Possible values:
 86400 (1 day)
 604800 (1 week)
 2592000 (1 month)
 31557600 (1 year).
 Required: No, if the envent's 'type' = QBMEventTypeOneShot, QBMEventTypeMultiShot or QBMEventTypeFixedDate
 Yes, if the envent's 'type' = QBMEventTypePeriodDate */
@property (nonatomic) NSUInteger period;

/** Event's occured count */
@property (nonatomic) NSUInteger occuredCount;

/** Event's sender ID */
@property (nonatomic) NSUInteger senderID;

/** Create new event
 @return New instance of QBMEvent
 */
+ (QBMEvent *)event;


- (void)prepareMessage;


#pragma mark -
#pragma mark Converters

+ (enum QBMEventType)eventTypeFromString:(NSString*)eventType;
+ (NSString*)eventTypeToString:(enum QBMEventType)eventType;

+ (enum QBMNotificationType)notificationTypeFromString:(NSString*)notificationType;
+ (NSString*)notificationTypeToString:(enum QBMNotificationType)notificationType;

+ (enum QBMPushType)pushTypeFromString:(NSString*)pushType;
+ (NSString*)pushTypeToString:(enum QBMPushType)pushType;

+ (NSString*)messageToString:(NSDictionary*)message;
+ (NSDictionary*)messageFromString:(NSString*)message;

@end
