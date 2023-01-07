//
//  AuthModule.h
//  sample-videochat-webrtc
//
//  Created by Injoit on 07.10.2022.
//  Copyright © 2022 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>

NS_ASSUME_NONNULL_BEGIN

@class AuthModule;

@protocol AuthModuleDelegate <NSObject>
@optional
- (void)authModule:(AuthModule *)authModule didSignUpUser:(QBUUser *)user;
- (void)authModule:(AuthModule *)authModule didLoginUser:(QBUUser *)user;
- (void)authModule:(AuthModule *)authModule didUpdateUpdateFullNameUser:(QBUUser *)user;
- (void)authModuleDidLogout:(AuthModule *)authModule;
- (void)authModule:(AuthModule *)authModule didReceivedError:(NSError *)error;

@end

@interface AuthModule : NSObject
@property (nonatomic, weak) id <AuthModuleDelegate> delegate;

- (void)signUpWithFullName:(NSString *)fullName login:(NSString *)login;
- (void)loginWithFullName:(NSString *)fullName login:(NSString *)login;
- (void)updateFullName:(NSString *)fullName;
- (void)logout;
@end

NS_ASSUME_NONNULL_END
