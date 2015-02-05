//
//  QBMSubscriptionResult.h
//  MessagesService
//
//  Copyright 2010 QuickBlox team. All rights reserved.
//

#import "QBResult.h"

/** QBMSubscriptionResult class declaration. */
/** Overview */
/** This class is an instance, which will be returned to user after he made ​​the request for create/get subscriptions. */

@interface QBMSubscriptionResult : QBResult{
	
}

/** Subscriptions */
@property (nonatomic,readonly) NSArray *subscriptions;

@end
