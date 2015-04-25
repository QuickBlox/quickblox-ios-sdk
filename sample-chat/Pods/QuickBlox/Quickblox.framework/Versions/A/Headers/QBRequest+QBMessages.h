//
//  QBRequest+QBMessages.h
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

@interface QBRequest (QBMessages)

#pragma mark -
#pragma mark Create Push Token

/**
 Create push token
 
 @param pushToken An instance of QBMPushToken
 @param successBlock Block with response and token instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)createPushToken:(QBMPushToken *)pushToken successBlock:(void (^)(QBResponse *response, QBMPushToken *token))successBlock
					errorBlock:(QBRequestErrorBlock)errorBlock;


#pragma mark -
#pragma mark Delete Push Token with ID

/**
 Delete push token with ID
 
 @param ID Identifier of push token to delete
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deletePushTokenWithID:(NSUInteger)ID successBlock:(void (^)(QBResponse *response))successBlock
						  errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Create Subscription

/**
 Create subscription
 
 @param subscriber An instance of QBMSubscription
 @param successBlock Block with response and subscriber instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)createSubscription:(QBMSubscription *)subscriber successBlock:(void (^)(QBResponse *response, NSArray *objects))successBlock
					   errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Get Subscriptions

/**
 Retrieve all subscriptions
 
 @param successBlock Block with response and subscribers instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)subscriptionsWithSuccessBlock:(void (^)(QBResponse *response, NSArray *objects))successBlock
								  errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Delete Subscription with ID

/**
 Delete subscription with ID
 
 @param ID An ID of instance of QBMSubscription that will be deleted
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteSubscriptionWithID:(NSUInteger)ID successBlock:(void (^)(QBResponse *response))successBlock
							 errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Create Event

/** Create an event
 
 @param event An instance of QBMEvent to create
 @param successBlock Block with response and event instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)createEvent:(QBMEvent *)event successBlock:(void (^)(QBResponse *response, NSArray *events))successBlock
                errorBlock:(QBRequestErrorBlock)errorBlock;

/** Retrieve all events which were created by current user  (with extended set of pagination parameters)
 
 @param page Configured QBLGeneralResponsePage instance
 @param successBlock Block with response, page, events instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)eventsForPage:(QBGeneralResponsePage *)page successBlock:(void (^)(QBResponse *response, QBGeneralResponsePage* page, NSArray *events))successBlock
                  errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Get Event with ID

/** Get an event with ID
 
 @param ID ID of QBMEvent to be retrieved.
 @param successBlock Block with response and event instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)eventWithID:(NSUInteger)ID successBlock:(void (^)(QBResponse *response, QBMEvent *event))successBlock
				errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Update Event

/** Update an event
 
 @param event An instance of QBMEvent to update
 @param successBlock Block with response and event instances if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)updateEvent:(QBMEvent *)event successBlock:(void (^)(QBResponse *response, QBMEvent *event))successBlock
				errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Delete Event with ID

/** Get an event with ID
 
 @param ID ID of QBMEvent to be deleted.
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with response instance if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)deleteEventWithID:(NSUInteger)ID successBlock:(void (^)(QBResponse *response))successBlock
					  errorBlock:(QBRequestErrorBlock)errorBlock;

#pragma mark -
#pragma mark Register Subscription Task

/** Create subscription for current device.
 
 This method registers push token on the server if they are not registered yet, then creates a Subscription and associates it with curent User.
 
 @param deviceToken Token received from application:didRegisterForRemoteNotificationsWithDeviceToken: method
 @param successBlock Block with response and subscriptions instances if request succeded
 @param errorBlock Block with response error if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)registerSubscriptionForDeviceToken:(NSData *)deviceToken successBlock:(void(^)(QBResponse *response, NSArray *subscriptions))successBlock
                                       errorBlock:(void (^)(QBError *error))errorBlock;

#pragma mark -
#pragma mark Register Subscription Task With Custom UDID

/** Create subscription for current device.
 
 This method registers push token on the server if they are not registered yet, then creates a Subscription and associates it with curent User.
 
 @param deviceToken Token received from application:didRegisterForRemoteNotificationsWithDeviceToken: method
 @param uniqueDeviceIdentifier device unique identifier
 @param successBlock Block with response and subscriptions instances if request succeded
 @param errorBlock Block with response error if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)registerSubscriptionForDeviceToken:(NSData *)deviceToken uniqueDeviceIdentifier:(NSString *)uniqueDeviceIdentifier successBlock:(void(^)(QBResponse *response, NSArray *subscriptions))successBlock errorBlock:(void (^)(QBError *error))errorBlock;

#pragma mark -
#pragma mark Unregister Subscription Task

/** Remove subscription for current device.
 
 This method remove subscription for current device from server.
 
 @param successBlock Block with response instance if request succeded
 @param errorBlock Block with error if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)unregisterSubscriptionWithSuccessBlock:(void (^)(QBResponse *response))successBlock errorBlock:(void (^)(QBError *error))errorBlock;

#pragma mark -
#pragma mark Send Push Task, to users with ids

/** Send Apple based push notification to users
 
 Type of Result - QBMSendPushTaskResult
 
 @param pushMessage composed push message to send
 @param usersIDs users identifiers who will get the message. Contain a string of users ids divided by comas.
 @param successBlock Block with response and event instances if request succeded
 @param errorBlock Block with error if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)sendPush:(QBMPushMessage *)pushMessage toUsers:(NSString *)usersIDs successBlock:(void(^)(QBResponse *response, QBMEvent *event))successBlock
             errorBlock:(void (^)(QBError *error))errorBlock;

/** Send simple push notification to users
 
 Type of Result - QBMSendPushTaskResult
 
 @param text composed push notification's text to send
 @param usersIDs users identifiers who will get the message. Contain a string of users ids divided by comas.
 @param successBlock Block with response and event instances if request succeded
 @param errorBlock Block with error if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)sendPushWithText:(NSString *)text toUsers:(NSString *)usersIDs successBlock:(void(^)(QBResponse *response, NSArray *events))successBlock
                     errorBlock:(void (^)(QBError *error))errorBlock;

#pragma mark -
#pragma mark Send Push Task, to users with tags

/** Send Apple based push notification to users with tags
 
 Type of Result - QBMSendPushTaskResult
 
 @param pushMessage composed push message to send
 @param usersTags users tags who will get the message. Contain a string of users tags divided by comas.
 @param successBlock Block with response and event instances if request succeded
 @param errorBlock Block with error if request failed
 @return An instance of QBRequest. Use this instance to cancel the operation.
 */
+ (QBRequest *)sendPush:(QBMPushMessage *)pushMessage toUsersWithAnyOfTheseTags:(NSString *)usersTags successBlock:(void(^)(QBResponse *response, QBMEvent *event))successBlock
             errorBlock:(void (^)(QBError *error))errorBlock;

/** Send simple push notification to users with tags
 
 Type of Result - QBMSendPushTaskResult
 
 @param text composed push notification's text to send
 @param usersTags users tags who will get the message. Contain a string of users tags divided by comas.
 @param successBlock Block with response and token instances if request succeded
 @param errorBlock Block with response instance and QBMEvent instance if request failed
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (QBRequest *)sendPushWithText:(NSString *)text toUsersWithAnyOfTheseTags:(NSString *)usersTags successBlock:(void(^)(QBResponse *response, NSArray *events))successBlock
                     errorBlock:(void (^)(QBError *error))errorBlock;

@end
