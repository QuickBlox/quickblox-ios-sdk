
//
//  QMBaseAuthService.m
//  QMServices
//
//  Created by Andrey Ivanov on 29.10.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMAuthService.h"

NSString *const kQMAuthSocialProvider = @"facebook";

@interface QMAuthService()

@property (strong, nonatomic) QBMulticastDelegate <QMAuthServiceDelegate> *multicastDelegate;
@property (assign, nonatomic) BOOL isAuthorized;

@end

@implementation QMAuthService

- (void)dealloc {
    
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

#pragma  mark Add / Remove multicast delegate

- (void)addDelegate:(id <QMAuthServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMAuthServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

#pragma mark - Will Start

- (void)serviceWillStart {
    
    self.multicastDelegate = (id<QMAuthServiceDelegate>)[[QBMulticastDelegate alloc] init];
}

- (QBRequest *)logOut:(void(^)(QBResponse *response))completion {

    __weak __typeof(self)weakSelf = self;
    
    weakSelf.isAuthorized = NO;
    QBRequest *request = [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        //Notify subscribes about logout
        if ([weakSelf.multicastDelegate respondsToSelector:@selector(authServiceDidLogOut:)]) {
            [weakSelf.multicastDelegate authServiceDidLogOut:self];
        }
        
        
        if (completion) {
            completion(response);
        }
        
    } errorBlock:^(QBResponse *response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response);
        }
    }];
    
    return request;
}

- (QBRequest *)signUpAndLoginWithUser:(QBUUser *)user completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    //1. Signup
    QBRequest *request = [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *newUser) {
        //2. Login
        [weakSelf logInWithUser:user completion:completion];
        
    } errorBlock:^(QBResponse *response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    }];
    
    return request;
}

#pragma mark - Private methods

- (QBRequest *)logInWithUser:(QBUUser *)user completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    __weak __typeof(self)weakSelf = self;
    //Common error block
    void (^errorBlock)(id) = ^(QBResponse *response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    };
    
    void (^successBlock)(id, id) = ^(QBResponse *response, QBUUser *userProfile){
        
        weakSelf.isAuthorized = YES;
        userProfile.password = user.password;
        
        if ([weakSelf.multicastDelegate respondsToSelector:@selector(authService:didLoginWithUser:)]) {
            [weakSelf.multicastDelegate authService:weakSelf didLoginWithUser:userProfile];
        }
        
        if (completion) {
            completion(response, userProfile);
        }
    };
    
    QBRequest *request = nil;
    
    if (user.email) {
        
        request = [QBRequest logInWithUserEmail:user.email password:user.password successBlock:successBlock errorBlock:errorBlock];
    }
    else if (user.login) {
        
        request = [QBRequest logInWithUserLogin:user.login password:user.password successBlock:successBlock errorBlock:errorBlock];
    }
    
    return request;
}

- (QBRequest *)loginWithTwitterDigitsAuthHeaders:(NSDictionary *)authHeaders completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    __weak __typeof(self)weakSelf = self;
    QBRequest *request = [QBRequest logInWithTwitterDigitsAuthHeaders:authHeaders successBlock:^(QBResponse * _Nonnull response, QBUUser * _Nullable user) {
        __typeof(weakSelf)strongSelf = weakSelf;
        user.password = [QBSession currentSession].sessionDetails.token;
        strongSelf.isAuthorized = YES;
        
        if ([strongSelf.multicastDelegate respondsToSelector:@selector(authService:didLoginWithUser:)]) {
            [strongSelf.multicastDelegate authService:strongSelf didLoginWithUser:user];
        }
        
        if (completion) {
            completion(response, user);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    }];
    
    return request;
}

#pragma mark - Social auth

- (QBRequest *)logInWithFacebookSessionToken:(NSString *)sessionToken completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    __weak __typeof(self)weakSelf = self;
    QBRequest *request = [QBRequest logInWithSocialProvider:kQMAuthSocialProvider accessToken:sessionToken accessTokenSecret:nil successBlock:^(QBResponse *response, QBUUser *tUser) {
        //set password
        tUser.password = [QBSession currentSession].sessionDetails.token;
        
        self.isAuthorized = YES;
        
        if ([weakSelf.multicastDelegate respondsToSelector:@selector(authService:didLoginWithUser:)]) {
            [weakSelf.multicastDelegate authService:weakSelf didLoginWithUser:tUser];
        }
        
        if (completion) {
            completion(response, tUser);
        }
        
    } errorBlock:^(QBResponse *response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    }];
    
    return request;
}

@end