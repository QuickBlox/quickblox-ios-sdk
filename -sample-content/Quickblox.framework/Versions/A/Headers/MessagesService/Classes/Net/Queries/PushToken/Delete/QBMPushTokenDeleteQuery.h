//
//  QBMPushTokenDeleteQuery.h
//  Quickblox
//
//  Created by Igor Khomenko on 7/18/12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

@interface QBMPushTokenDeleteQuery : QBMPushTokenQuery{
	NSUInteger ID;
}
@property (nonatomic) NSUInteger ID;

- (id)initWithPushTokenID:(NSUInteger)ID;

@end
