//
//  QBMSubscriptionCreateQuery.h
//  MessagesService
//

//  Copyright 2010 QuickBlox team. All rights reserved.
//

@interface QBMSubscriptionCreateQuery : QBMSubscriptionQuery {
	QBMSubscription *subscription;
}
@property (nonatomic, retain) QBMSubscription *subscription;

- (id)initWithSubscription:(QBMSubscription *)tsubscription;

@end
