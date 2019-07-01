//
//  Profile.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 3/12/19.
//  Copyright © 2019 QuickBlox. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Profile : NSObject

+ (void)clearProfile;
+ (void)synchronizeUser:(QBUUser *)user;
+ (void)updateUser:(QBUUser *)user;

@property (assign, nonatomic, readonly) BOOL isFull;
@property (assign, nonatomic, readonly) NSUInteger ID;
@property (strong, nonatomic, readonly) NSString *login;
@property (strong, nonatomic, readonly) NSString *password;
@property (strong, nonatomic, readonly) NSString *fullName;
@property (strong, nonatomic, readonly) NSString *tag;

@end

NS_ASSUME_NONNULL_END
