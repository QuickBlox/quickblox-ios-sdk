//
//  QBMSubscriptionDeleteQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBMSubscriptionDeleteQuery : QBMSubscriptionQuery{
    NSUInteger ID;
}
@property (nonatomic) NSUInteger ID;

- (id)initWithSubscriptionID:(NSUInteger)ID;

@end
