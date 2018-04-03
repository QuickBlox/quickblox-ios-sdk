//
//  QBProfile.h
//  LoginComponent
//
//  Created by Andrey Ivanov on 02/06/16.
//  Copyright © 2016 Quickblox. All rights reserved.
//

#import <Foundation/Foundation.h>


@class QBUUser;

NS_ASSUME_NONNULL_BEGIN

@interface QBProfile : NSObject <NSCoding>

/**
 *  User data.
 */
@property (strong, nonatomic, readonly, nullable) QBUUser *userData;

/**
 *  Returns loaded current profile with user.
 *
 *  @return current profile
 */
+ (nullable instancetype)currentProfile;

/**
 *  Synchronize current profile in keychain.
 *
 *  @return whether synchronize was successful
 */

- (OSStatus)synchronize;

/**
 *  Synchronize user data in keychain.
 *
 *  @param userData user data to synchronize
 *
 *  @return whether synchronize was successful
 */
- (OSStatus)synchronizeWithUserData:(QBUUser *)userData;

/**
 *  Remove all user data.
 *
 *  @return Whether clear was successful
 */
- (OSStatus)clearProfile;

@end

NS_ASSUME_NONNULL_END
