//
//  QBMSubscriptionAnswer.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "EntityAnswer.h"

@interface QBMSubscriptionAnswer : EntityAnswer{
@protected 
    NSMutableArray *subscriptions;
}

@property (nonatomic, readonly) NSMutableArray *subscriptions;

@end

