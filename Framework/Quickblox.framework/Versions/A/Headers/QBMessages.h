//
//  QBMessages.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBBaseModule.h"

@class QBMPushToken;
@protocol Cancelable;
@protocol QBActionStatusDelegate;
@class QBMSubscription;
@class QBMEvent;
@class PagedRequest;
@class QBMPushMessage;

/** QBMessages class declaration. */
/** Overview: */
/** This is a hub class for all Messages-related actions. */

@interface QBMessages : QBBaseModule {
    
}


#pragma mark -
#pragma mark Create Push Token

/** 
 Create push token
 
 Type of Result - QBMPushTokenResult
 
 @param pushToken An instance of QBMPushToken
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMPushTokenResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)createPushToken:(QBMPushToken *)pushToken delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest createPushToken:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)createPushToken:(QBMPushToken *)pushToken delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest createPushToken:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Delete Push Token with ID

/** 
 Delete push token with ID
 
 Type of Result - QBMPushTokenResult
 
 @param ID An ID of instance of QBMPushToken that will be deleted
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMPushTokenResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)deletePushTokenWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest deletePushToken:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)deletePushTokenWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest deletePushToken:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Create Subscription

/** 
 Create subscription
 
 Type of Result - QBMSubscriptionResult
 
 @param subscriber An instance of QBMSubscription
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMSubscriptionResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)createSubscription:(QBMSubscription *)subscriber delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest createSubscription:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)createSubscription:(QBMSubscription *)subscriber delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest createSubscription:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Get Subscriptions

/** 
 Retieve all subscriptions
 
 Type of Result - QBMSubscriptionPagedResult
 
 @param subscriber An instance of QBMSubscription
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMSubscriptionPagedResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)subscriptionsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest subscriptionsWithSuccessBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)subscriptionsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest subscriptionsWithSuccessBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Delete Subscription with ID

/** 
 Delete subscription with ID
 
 Type of Result - QBMSubscriptionResult
 
 @param ID An ID of instance of QBMSubscription that will be deleted
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMSubscriptionResult class.    
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)deleteSubscriptionWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest deleteSubscriptionWithID:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)deleteSubscriptionWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest deleteSubscriptionWithID:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Create Event 

/** Create an event
 
 Type of Result - QBMEventResult
 
 @param event An instance of QBMEvent to create
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMEventResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)createEvent:(QBMEvent *)event delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest createEvent:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)createEvent:(QBMEvent *)event delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest createEvent:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Get Event with ID 

/** Get an event with ID
 
 Type of Result - QBMEventResult
 
 @param ID ID of QBMEvent to be retrieved.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMEventResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)eventWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest eventWithID:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)eventWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest eventWithID:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Update Event

/** Update an event
 
 Type of Result - QBMEventResult
 
 @param event An instance of QBMEvent to update
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMEventResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)updateEvent:(QBMEvent *)event delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest updateEvent:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)updateEvent:(QBMEvent *)event delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest updateEvent:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Delet Event with ID 

/** Get an event with ID
 
 Type of Result - QBMEventResult
 
 @param ID ID of QBMEvent to be deleted.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMEventResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)deleteEventWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest deleteEventWithID:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)deleteEventWithID:(NSUInteger)ID delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest deleteEventWithID:successBlock:errorBlock:]' instead.")));

#pragma mark -
#pragma mark Get Events

/** Retrieve all events which were created by current user (last 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBMEventPagedResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMEventPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)eventsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate;
+ (NSObject<Cancelable> *)eventsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context;


/** Retrieve all events which were created by current user  (with extended set of pagination parameters)
 
 Type of Result - QBMEventPagedResult
 
 @param pagedRequest paged request
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMEventPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)eventsWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest eventsForPage:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)eventsWithPagedRequest:(PagedRequest *)pagedRequest delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest eventsForPage:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Get Pull Events

/** Retrieve all pull events which were created by current user (last 10 users, for more - use equivalent method with 'pagedRequest' argument)
 
 Type of Result - QBMEventPagedResult
 
 @warning *Deprecated in QB iOS SDK 1.8.5:* Pull events were removed completely. Use CustomObjects module to implement pull events
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMEventPagedResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation. 
 */
+ (NSObject<Cancelable> *)pullEventsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("Pull events were removed completely. Use CustomObjects module to implement pull events")));

+ (NSObject<Cancelable> *)pullEventsWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("Pull events were removed completely. Use CustomObjects module to implement pull events")));



#pragma mark -
#pragma mark Tasks


#pragma mark -
#pragma mark Register Subscription Task

/** Create subscription for current device. 
 
 This method registers push token on the server if they are not registered yet, then creates a Subscription and associates it with curent User. 
 
 Type of Result - QBMRegisterSubscriptionTaskResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMRegisterSubscriptionTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)TRegisterSubscriptionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest registerSubscriptionForDeviceToken:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)TRegisterSubscriptionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest registerSubscriptionForDeviceToken:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Unregister Subscription Task

/** Remove subscription for current device.
 
 This method remove subscription for current device from server.
 
 Type of Result - QBMUnregisterSubscriptionTaskResult
 
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMUnregisterSubscriptionTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)TUnregisterSubscriptionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest unregisterSubscriptionWithSuccessBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)TUnregisterSubscriptionWithDelegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest unregisterSubscriptionWithSuccessBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Send Push Task, to users with ids

/** Send Apple based push notification to users
 
 Type of Result - QBMSendPushTaskResult
 
 @param pushMessage composed push message to send
 @param usersIDs users identifiers who will get the message. Contain a string of users ids divided by comas.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMSendPushTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)TSendPush:(QBMPushMessage *)pushMessage
                            toUsers:(NSString *)usersIDs
						   delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest sendPush:toUsers:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)TSendPush:(QBMPushMessage *)pushMessage
                            toUsers:(NSString *)usersIDs
						   delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest sendPush:toUsers:successBlock:errorBlock:]' instead.")));


/** Send simple push notification to users
 
 Type of Result - QBMSendPushTaskResult
 
 @param text composed push notification's text to send
 @param usersIDs users identifiers who will get the message. Contain a string of users ids divided by comas.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMSendPushTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)TSendPushWithText:(NSString *)text
                                    toUsers:(NSString *)usersIDs
                                   delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest sendPushWithText:toUsers:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)TSendPushWithText:(NSString *)text
                                    toUsers:(NSString *)usersIDs
                                   delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest sendPushWithText:toUsers:successBlock:errorBlock:]' instead.")));


#pragma mark -
#pragma mark Send Push Task, to users with tags

/** Send Apple based push notification to users with tags
 
 Type of Result - QBMSendPushTaskResult
 
 @param pushMessage composed push message to send
 @param usersTags users tags who will get the message. Contain a string of users tags divided by comas.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMSendPushTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)TSendPush:(QBMPushMessage *)pushMessage
          toUsersWithAnyOfTheseTags:(NSString *)usersTags
						   delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest sendPush:toUsersWithAnyOfTheseTags:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)TSendPush:(QBMPushMessage *)pushMessage
          toUsersWithAnyOfTheseTags:(NSString *)usersTags
						   delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest sendPush:toUsersWithAnyOfTheseTags:successBlock:errorBlock:]' instead.")));


/** Send simple push notification to users with tags
 
 Type of Result - QBMSendPushTaskResult
 
 @param text composed push notification's text to send
 @param usersTags users tags who will get the message. Contain a string of users tags divided by comas.
 @param delegate An object for callback, must adopt QBActionStatusDelegate protocol. The delegate is retained.  Upon finish of the request, result will be an instance of QBMSendPushTaskResult class.
 @return An instance, which conforms Cancelable protocol. Use this instance to cancel the operation.
 */
+ (NSObject<Cancelable> *)TSendPushWithText:(NSString *)text
                  toUsersWithAnyOfTheseTags:(NSString *)usersTags
                                   delegate:(NSObject<QBActionStatusDelegate> *)delegate __attribute__((deprecated("use '+[QBRequest sendPushWithText:toUsersWithAnyOfTheseTags:successBlock:errorBlock:]' instead.")));
///
+ (NSObject<Cancelable> *)TSendPushWithText:(NSString *)text
                  toUsersWithAnyOfTheseTags:(NSString *)usersTags
                                   delegate:(NSObject<QBActionStatusDelegate> *)delegate context:(void *)context __attribute__((deprecated("use '+[QBRequest sendPushWithText:toUsersWithAnyOfTheseTags:successBlock:errorBlock:]' instead.")));

@end
