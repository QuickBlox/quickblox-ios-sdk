//
//  Profile.h
//  sample-push-notifications
//
//  Created by Injoit on 3/18/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

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
