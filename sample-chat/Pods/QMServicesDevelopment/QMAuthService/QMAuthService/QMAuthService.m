//
//  QMBaseAuthService.m
//  QMServices
//
//  Created by Andrey Ivanov on 29.10.14.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMAuthService.h"
#import "QMSLog.h"

static NSString *const kQMFacebookAuthSocialProvider = @"facebook";
static NSString *const kQMTwitterAuthSocialProvider  = @"twitter";

@interface QMAuthService()

@property (strong, nonatomic) QBMulticastDelegate <QMAuthServiceDelegate> *multicastDelegate;

@end

@implementation QMAuthService

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
}

//MARK: Add / Remove multicast delegate

- (void)addDelegate:(id <QMAuthServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMAuthServiceDelegate>)delegate {
    
    [self.multicastDelegate removeDelegate:delegate];
}

//MARK: - Will Start

- (void)serviceWillStart {
    
    _multicastDelegate = (id<QMAuthServiceDelegate>)[[QBMulticastDelegate alloc] init];
}

- (BOOL)isAuthorized {
    
    return !QBSession.currentSession.tokenHasExpired;
}

- (QBRequest *)logOut:(void(^)(QBResponse *response))completion {
    
    __weak __typeof(self)weakSelf = self;
    
    QBRequest *request = [QBRequest logOutWithSuccessBlock:^(QBResponse *response) {
        //Notify subscribes about logout
        if ([weakSelf.multicastDelegate respondsToSelector:@selector(authServiceDidLogOut:)]) {
            [weakSelf.multicastDelegate authServiceDidLogOut:weakSelf];
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

- (QBRequest *)signUpAndLoginWithUser:(QBUUser *)user
                           completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
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

//MARK: - Private methods

- (QBRequest *)logInWithUser:(QBUUser *)user
                  completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    __weak __typeof(self)weakSelf = self;
    //Common error block
    void (^errorBlock)(id) = ^(QBResponse *response) {
        
        [weakSelf.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    };
    
    void (^successBlock)(id, id) = ^(QBResponse *response, QBUUser *userProfile){
        
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
        
        request = [QBRequest logInWithUserEmail:user.email
                                       password:user.password
                                   successBlock:successBlock
                                     errorBlock:errorBlock];
    }
    else if (user.login) {
        
        request = [QBRequest logInWithUserLogin:user.login
                                       password:user.password
                                   successBlock:successBlock
                                     errorBlock:errorBlock];
    }
    
    return request;
}

- (QBRequest *)loginWithTwitterDigitsAuthHeaders:(NSDictionary *)authHeaders
                                      completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    QBRequest *request =
    [QBRequest logInWithTwitterDigitsAuthHeaders:authHeaders
                                    successBlock:^(QBResponse *response, QBUUser *user)
     {
         
         user.password = QBSession.currentSession.sessionDetails.token;
         
         if ([self.multicastDelegate respondsToSelector:@selector(authService:didLoginWithUser:)]) {
             [self.multicastDelegate authService:self didLoginWithUser:user];
         }
         
         if (completion) {
             completion(response, user);
         }
         
     } errorBlock:^(QBResponse *response) {
         
         [self.serviceManager handleErrorResponse:response];
         
         if (completion) {
             completion(response, nil);
         }
     }];
    
    return request;
}

- (QBRequest *)logInWithFirebaseProjectID:(NSString *)projectID
                              accessToken:(NSString *)accessToken
                                      completion:(void(^)(QBResponse *response,
                                                          QBUUser *userProfile))completion {
    
    return [QBRequest logInWithFirebaseProjectID:projectID
                              accessToken:accessToken
                             successBlock:^(QBResponse *response, QBUUser *tUser)
    {
        tUser.password = QBSession.currentSession.sessionDetails.token;
        
        if ([self.multicastDelegate respondsToSelector:@selector(authService:didLoginWithUser:)]) {
            [self.multicastDelegate authService:self didLoginWithUser:tUser];
        }
        
        if (completion) {
            completion(response, tUser);
        }
    } errorBlock:^(QBResponse * _Nonnull response) {
        
        [self.serviceManager handleErrorResponse:response];
        
        if (completion) {
            completion(response, nil);
        }
    }];
}

//MARK: - Social auth

- (QBRequest *)loginWithTwitterAccessToken:(NSString *)accessToken
                         accessTokenSecret:(NSString *)accessTokenSecret
                                completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    __weak __typeof(self)weakSelf = self;
    QBRequest *request =
    [QBRequest logInWithSocialProvider:kQMTwitterAuthSocialProvider
                           accessToken:accessToken
                     accessTokenSecret:accessTokenSecret
                          successBlock:^(QBResponse *response, QBUUser *tUser)
     {
         //set password
         tUser.password = [QBSession currentSession].sessionDetails.token;
         
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

- (QBRequest *)logInWithFacebookSessionToken:(NSString *)sessionToken
                                  completion:(void(^)(QBResponse *response, QBUUser *userProfile))completion {
    
    __weak __typeof(self)weakSelf = self;
    QBRequest *request =
    [QBRequest logInWithSocialProvider:kQMFacebookAuthSocialProvider
                           accessToken:sessionToken
                     accessTokenSecret:nil successBlock:^(QBResponse *response, QBUUser *tUser) {
                         //set password
                         tUser.password = [QBSession currentSession].sessionDetails.token;
                         
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
