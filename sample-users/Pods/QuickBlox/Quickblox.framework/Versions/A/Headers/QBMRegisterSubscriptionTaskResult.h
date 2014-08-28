//
//  QBMRegisterSubscriptionTaskResult.h
//  MessagesService
//

//  Copyright 2011 QuickBlox team. All rights reserved.
//

#import "TaskResult.h"

@interface QBMRegisterSubscriptionTaskResult : TaskResult {
	NSArray *subscriptions;
}
@property (nonatomic,retain) NSArray *subscriptions;

@end
