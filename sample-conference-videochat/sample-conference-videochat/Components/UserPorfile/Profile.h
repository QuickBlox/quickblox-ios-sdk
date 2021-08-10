//
//  Profile.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kSubscriptionID = @"last_voip_subscription_id";
static NSString * const kToken = @"last_voip_token";
static NSString * const kNeedUpdateToken = @"last_voip_token_need_update";

@interface Profile : NSObject

+ (void)clear;
+ (void)synchronizeUser:(QBUUser *)user;
+ (void)updateUser:(QBUUser *)user;

- (BOOL)isFull;
- (NSUInteger)ID;
- (NSString *)login;
- (NSString *)password;
- (NSString *)fullName;

@end

NS_ASSUME_NONNULL_END
