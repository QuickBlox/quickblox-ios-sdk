//
//  QBMSubscriptionResult.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

/** QBMSubscriptionResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get subscriptions. */

@interface QBMSubscriptionResult : Result {
	
}

/** Subscriptions */
@property (nonatomic,readonly) NSArray *subscriptions;

@end
