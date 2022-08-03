//
//  Profile.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
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

@property (assign, nonatomic, readonly) BOOL isFull;
@property (assign, nonatomic, readonly) NSUInteger ID;
@property (strong, nonatomic, readonly) NSString *login;
@property (strong, nonatomic, readonly) NSString *password;
@property (strong, nonatomic, readonly) NSString *fullName;

@end

NS_ASSUME_NONNULL_END
