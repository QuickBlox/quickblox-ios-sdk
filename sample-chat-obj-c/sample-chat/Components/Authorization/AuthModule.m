//
//  AuthModule.m
//  sample-chat
//
//  Created by Injoit on 30.09.2022.
//  Copyright © 2022 Quickblox. All rights reserved.
//

#import "AuthModule.h"
#import <Quickblox/Quickblox.h>

NSString *const DEFAULT_PASSWORD = @"quickblox";

@implementation AuthModule
//MARK: - Public Methods
- (void)signUpWithFullName:(NSString *)fullName login:(NSString *)login {
    QBUUser *newUser = [[QBUUser alloc] init];
    newUser.login = login;
    newUser.fullName = fullName;
    newUser.password = DEFAULT_PASSWORD;
    
    __weak __typeof(self)weakSelf = self;
    [QBRequest signUp:newUser successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(authModule:didSignUpUser:)]) {
            [strongSelf.delegate authModule:strongSelf didSignUpUser:user];
        }
        
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if (response.status == QBResponseStatusCodeValidationFailed) {
            // The user with existent login was created earlier
            if ([strongSelf.delegate respondsToSelector:@selector(authModule:didSignUpUser:)]) {
                [strongSelf.delegate authModule:strongSelf didSignUpUser:newUser];
            }
            return;
        }
        if ([strongSelf.delegate respondsToSelector:@selector(authModule:didReceivedError:)]) {
            [strongSelf.delegate authModule:strongSelf didReceivedError:response.error.error];
        }
    }];
}

- (void)loginWithFullName:(NSString *)fullName login:(NSString *)login {
    __weak __typeof(self)weakSelf = self;
    [QBRequest logInWithUserLogin:login
                         password:DEFAULT_PASSWORD
                     successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(authModule:didLoginUser:)]) {
            [strongSelf.delegate authModule:strongSelf didLoginUser:user];
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(authModule:didReceivedError:)]) {
            [strongSelf.delegate authModule:strongSelf didReceivedError:response.error.error];
        }
    }];
}

- (void)updateFullName:(NSString *)fullName {
    QBUpdateUserParameters *updateUserParameter = [[QBUpdateUserParameters alloc] init];
    updateUserParameter.fullName = fullName;
    __weak __typeof(self)weakSelf = self;
    [QBRequest updateCurrentUser:updateUserParameter
                    successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nonnull user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(authModule:didUpdateUpdateFullNameUser:)]) {
            [strongSelf.delegate authModule:strongSelf didUpdateUpdateFullNameUser:user];
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(authModule:didReceivedError:)]) {
            [strongSelf.delegate authModule:strongSelf didReceivedError:response.error.error];
        }
    }];
}

- (void)logout {
    __weak __typeof(self)weakSelf = self;
    [QBRequest logOutWithSuccessBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(authModuleDidLogout:)]) {
            [strongSelf.delegate authModuleDidLogout:strongSelf];
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        __typeof(weakSelf)strongSelf = weakSelf;
        if ([strongSelf.delegate respondsToSelector:@selector(authModule:didReceivedError:)]) {
            [strongSelf.delegate authModule:strongSelf didReceivedError:response.error.error];
        }
    }];
}

@end
