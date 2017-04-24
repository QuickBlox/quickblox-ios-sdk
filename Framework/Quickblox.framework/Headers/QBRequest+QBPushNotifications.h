//
//  QBRequest+QBPushNotifications.h
//  Quickblox
//
//  Created by QuickBlox team on 4/29/14.
//  Copyright (c) 2016 QuickBlox. All rights reserved.
//

#import "QBRequest.h"

@class QBMPushToken;
@class QBMSubscription;
@class QBMEvent;
@class QBGeneralResponsePage;
@class QBMPushMessage;
@class QBError;

NS_ASSUME_NONNULL_BEGIN

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
+ (QBRequest *)createSubscription:(QBMSubscription *)subscription
                     successBlock:(nullable void (^)(QBResponse *response, NSArray<QBMSubscription *> * _Nullable objects))successBlock
                       errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Get Subscriptions

/**
 *  Retrieve all subscriptions.
 *
 *  @param successBlock Block with response and subscribers instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)subscriptionsWithSuccessBlock:(nullable void (^)(QBResponse *response, NSArray<QBMSubscription *> * _Nullable objects))successBlock
                                  errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Delete Subscription with ID

/**
 *  Delete subscription with ID.
 *
 *  @param ID           An ID of instance of QBMSubscription that will be deleted
 *  @param successBlock Block with response instance if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteSubscriptionWithID:(NSUInteger)ID
                           successBlock:(nullable qb_response_block_t)successBlock
                             errorBlock:(nullable qb_response_block_t)errorBlock;
//MARK: - Create Event

/**
 *  Create an event.
 *
 *  @param event        An instance of QBMEvent to create
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)createEvent:(QBMEvent *)event
              successBlock:(nullable void (^)(QBResponse *response, NSArray<QBMEvent *> * _Nullable events))successBlock
                errorBlock:(nullable qb_response_block_t)errorBlock;

/**
 *  Retrieve all events which were created by current user (with extended set of pagination parameters).
 *
 *  @param page         Configured QBLGeneralResponsePage instance
 *  @param successBlock Block with response, page, events instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)eventsForPage:(nullable QBGeneralResponsePage *)page
                successBlock:(nullable void (^)(QBResponse *response, QBGeneralResponsePage * _Nullable page, NSArray<QBMEvent *> * _Nullable events))successBlock
                  errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Get Event with ID

/**
 *  Get an event with ID.
 *
 *  @param ID           ID of QBMEvent to be retrieved
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)eventWithID:(NSUInteger)ID
              successBlock:(nullable void (^)(QBResponse *response, QBMEvent * _Nullable event))successBlock
                errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Update Event

/**
 *  Update an event.
 *
 *  @param event        An instance of QBMEvent to update
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)updateEvent:(QBMEvent *)event
              successBlock:(nullable void (^)(QBResponse *response, QBMEvent * _Nullable event))successBlock
                errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Delete Event with ID

/**
 *  Get an event with ID.
 *
 *  @param ID           ID of QBMEvent to be deleted.
 *  @param successBlock Block with response instance if request succeded
 *  @param errorBlock   Block with response instance if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)deleteEventWithID:(NSUInteger)ID
                    successBlock:(nullable qb_response_block_t)successBlock
                      errorBlock:(nullable qb_response_block_t)errorBlock;

//MARK: - Send push Tasks

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
+ (QBRequest *)sendPush:(QBMPushMessage *)pushMessage
                toUsers:(NSString *)usersIDs
           successBlock:(nullable void(^)(QBResponse *response, QBMEvent * _Nullable event))successBlock
             errorBlock:(nullable QBErrorBlock)errorBlock;

/**
 *  Send apns-voip push notification to users.
 *
 *  @param pushMessage  Composed push message to send
 *  @param usersIDs     Users identifiers who will get the message. Contain a string of users ids divided by comas
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with error if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)sendVoipPush:(QBMPushMessage *)pushMessage
                    toUsers:(NSString *)usersIDs
               successBlock:(nullable void(^)(QBResponse *response, QBMEvent * _Nullable event))successBlock
                 errorBlock:(nullable QBErrorBlock)errorBlock;
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
+ (QBRequest *)sendPushWithText:(NSString *)text
                        toUsers:(NSString *)usersIDs
                   successBlock:(nullable void(^)(QBResponse *response, NSArray<QBMEvent *> * _Nullable events))successBlock
                     errorBlock:(nullable QBErrorBlock)errorBlock;

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
+ (QBRequest *)sendPush:(QBMPushMessage *)pushMessage
toUsersWithAnyOfTheseTags:(NSString *)usersTags
           successBlock:(nullable void(^)(QBResponse *response, QBMEvent * _Nullable event))successBlock
             errorBlock:(nullable QBErrorBlock)errorBlock;

/**
 *  Send apns-voip push notification to users with tags.
 *
 *  @param pushMessage  composed push message to send
 *  @param usersTags    users tags who will get the message. Contain a string of users tags divided by comas
 *  @param successBlock Block with response and event instances if request succeded
 *  @param errorBlock   Block with error if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)sendVoipPush:(QBMPushMessage *)pushMessage
  toUsersWithAnyOfTheseTags:(NSString *)usersTags
               successBlock:(nullable void(^)(QBResponse *response, QBMEvent * _Nullable event))successBlock
                 errorBlock:(nullable QBErrorBlock)errorBlock;

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
+ (QBRequest *)sendPushWithText:(NSString *)text
      toUsersWithAnyOfTheseTags:(NSString *)usersTags
                   successBlock:(nullable void(^)(QBResponse *response, NSArray<QBMEvent *> * _Nullable events))successBlock
                     errorBlock:(nullable QBErrorBlock)errorBlock;

//MARK: - Unregister and Register Subscription Tasks

/**
 *  Remove subscription for a specific device. This method remove subscription for a specific device.
 *
 *  @param uniqueDeviceIdentifier The device unique identifier
 *  @param successBlock           Block with response instance if request succeded
 *  @param errorBlock             Block with error if request failed
 *
 *  @return An instance of QBRequest for cancel operation mainly.
 */
+ (QBRequest *)unregisterSubscriptionForUniqueDeviceIdentifier:(NSString *)uniqueDeviceIdentifier
                                                  successBlock:(nullable qb_response_block_t)successBlock
                                                    errorBlock:(nullable QBErrorBlock)errorBlock;
@end

NS_ASSUME_NONNULL_END
