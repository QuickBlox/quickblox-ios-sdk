//
//  QBRequest+QBPushNotifications.h
//  Quickblox
//
//  Created by Andrey Moskvin on 4/29/14.
//  Copyright (c) 2014 QuickBlox. All rights reserved.
//

#import "QBRequest.h"

@class QBMPushToken;
@class QBMSubscription;
@class QBMEvent;
@class QBGeneralResponsePage;
@class QBMPushMessage;
@class QBError;

@interface QBRequest (QBPushNotifications)

/**
*  Create subscription.
*
*  @param subscription An instance of QBMSubscription
*  @param successBlock Block with response and subscriber instances if request succeded
*  @param errorBlock   Block with response instance if request failed
*
*  @return An instance of QBRequest for cancel operation mainly.
*/
+ (QB_NONNULL QBRequest *)createSubscription:(QB_NONNULL QBMSubscription *)subscription
                                successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBMSubscription *) * QB_NULLABLE_S objects))successBlock
                                  errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Get Subscriptions

/**
 *  Retrieve all subscriptions.
 *
 *  @param successBlock Block with response and subscribers instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)subscriptionsWithSuccessBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBMSubscription *) * QB_NULLABLE_S objects))successBlock
                                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Delete Subscription with ID

/**
 *  Delete subscription with ID.
 *
 *  @param ID           An ID of instance of QBMSubscription that will be deleted
 *  @param successBlock Block with response instance if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteSubscriptionWithID:(NSUInteger)ID
                                      successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                        errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Create Event

/**
 *  Create an event.
 *
 *  @param event        An instance of QBMEvent to create
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)createEvent:(QB_NONNULL QBMEvent *)event
                         successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBMEvent *) * QB_NULLABLE_S events))successBlock
                           errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;

/**
 *  Retrieve all events which were created by current user (with extended set of pagination parameters).
 *
 *  @param page         Configured QBLGeneralResponsePage instance
 *  @param successBlock Block with response, page, events instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)eventsForPage:(QB_NULLABLE QBGeneralResponsePage *)page
                           successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBGeneralResponsePage * QB_NULLABLE_S page, NSArray QB_GENERIC(QBMEvent *) * QB_NULLABLE_S events))successBlock
                             errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Get Event with ID

/**
 *  Get an event with ID.
 *
 *  @param ID           ID of QBMEvent to be retrieved
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)eventWithID:(NSUInteger)ID
                         successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBMEvent * QB_NULLABLE_S event))successBlock
                           errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Update Event

/**
 *  Update an event.
 *
 *  @param event        An instance of QBMEvent to update
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)updateEvent:(QB_NONNULL QBMEvent *)event
                         successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response, QBMEvent * QB_NULLABLE_S event))successBlock
                           errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Delete Event with ID

/**
 *  Get an event with ID.
 *
 *  @param ID           ID of QBMEvent to be deleted.
 *  @param successBlock Block with response instance if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)deleteEventWithID:(NSUInteger)ID
                               successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                 errorBlock:(QB_NULLABLE QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Send push Tasks

/**
 *  Send Apple based push notification to users.
 *
 *  @param pushMessage  Composed push message to send
 *  @param usersIDs     Users identifiers who will get the message. Contain a string of users ids divided by comas
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with error if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)sendPush:(QB_NONNULL QBMPushMessage *)pushMessage
                           toUsers:(QB_NONNULL NSString *)usersIDs
                      successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBMEvent * QB_NULLABLE_S event))successBlock
                        errorBlock:(QB_NULLABLE void (^)(QBError * QB_NULLABLE_S error))errorBlock;

/**
 *  Send simple push notification to users.
 *
 *  @param text         composed push notification's text to send
 *  @param usersIDs     users identifiers who will get the message. Contain a string of users ids divided by comas.
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with error if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)sendPushWithText:(QB_NONNULL NSString *)text
                                   toUsers:(QB_NONNULL NSString *)usersIDs
                              successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBMEvent *) * QB_NULLABLE_S events))successBlock
                                errorBlock:(QB_NULLABLE void (^)(QBError * QB_NULLABLE_S error))errorBlock;

/**
 *  Send Apple based push notification to users with tags.
 *
 *  @param pushMessage  composed push message to send
 *  @param usersTags    users tags who will get the message. Contain a string of users tags divided by comas
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with error if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)sendPush:(QB_NONNULL QBMPushMessage *)pushMessage
         toUsersWithAnyOfTheseTags:(QB_NONNULL NSString *)usersTags
                      successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, QBMEvent * QB_NULLABLE_S event))successBlock
                        errorBlock:(QB_NULLABLE void (^)(QBError * QB_NULLABLE_S error))errorBlock;

/**
 *  Send simple push notification to users with tags.
 *
 *  @param text         composed push notification's text to send
 *  @param usersTags    users tags who will get the message. Contain a string of users tags divided by comas.
 *  @param successBlock Block with response and token instances if request succeded
 *  @param errorBlock   Block with response instance and QBMEvent instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)sendPushWithText:(QB_NONNULL NSString *)text
                 toUsersWithAnyOfTheseTags:(QB_NONNULL NSString *)usersTags
                              successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBMEvent *) * QB_NULLABLE_S events))successBlock
                                errorBlock:(QB_NULLABLE void (^)(QBError * QB_NULLABLE_S error))errorBlock;


#pragma mark -
#pragma mark Unregister and Register Subscription Tasks

/**
 *  Create subscription for current device with custom UDID. This method registers push token on the server if they are not registered yet, then creates a Subscription and associates it with curent User.
 *
 *  @param deviceToken            Token received from application:didRegisterForRemoteNotificationsWithDeviceToken: method
 *  @param uniqueDeviceIdentifier The device unique identifier
 *  @param successBlock           Block with response and subscriptions instances if request succeded
 *  @param errorBlock             Block with response error if request failed
 *
 *  @warning Deprecated in QB iOS SDK 2.7.2. Use 'createSubscription:successBlock:errorBlock:' instead.
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)registerSubscriptionForDeviceToken:(QB_NONNULL NSData *)deviceToken
                                      uniqueDeviceIdentifier:(QB_NULLABLE NSString *)uniqueDeviceIdentifier
                                                successBlock:(QB_NULLABLE void(^)(QBResponse * QB_NONNULL_S response, NSArray QB_GENERIC(QBMSubscription *) * QB_NULLABLE_S subscriptions))successBlock
                                                  errorBlock:(QB_NULLABLE void (^)(QBError * QB_NULLABLE_S error))errorBlock
DEPRECATED_MSG_ATTRIBUTE("Deprecated in 2.7.2. Use 'createSubscription:successBlock:errorBlock:' instead.");

/**
 *  Remove subscription for a specific device. This method remove subscription for a specific device.
 *
 *  @param uniqueDeviceIdentifier The device unique identifier
 *  @param successBlock           Block with response instance if request succeded
 *  @param errorBlock             Block with error if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QB_NONNULL QBRequest *)unregisterSubscriptionForUniqueDeviceIdentifier:(QB_NONNULL NSString *)uniqueDeviceIdentifier
                                                             successBlock:(QB_NULLABLE void (^)(QBResponse * QB_NONNULL_S response))successBlock
                                                               errorBlock:(QB_NULLABLE void (^)(QBError * QB_NULLABLE_S error))errorBlock;

@end
