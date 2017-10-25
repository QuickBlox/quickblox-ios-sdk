//
//  QMAuthService+Bolts.m
//  QMServices
//
//  Created by Vitaliy Gorbachov on 1/8/16.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMAuthService.h"

@implementation QMAuthService (Bolts)

- (BFTask *)signUpAndLoginWithUser:(QBUUser *)user {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self signUpAndLoginWithUser:user
                          completion:^(QBResponse *response,
                                       QBUUser *userProfile)
         {
             response.success ?
             [source setResult:userProfile] :
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)loginWithUser:(QBUUser *)user {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self logInWithUser:user
                 completion:^(QBResponse *response,
                              QBUUser *userProfile)
         {
             response.success ?
             [source setResult:userProfile] :
             [source setError:response.error.error];
         }];
    });
}

- (BFTask<QBUUser *> *)logInWithFirebaseProjectID:(NSString *)projectID
                                      accessToken:(NSString *)accessToken {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self logInWithFirebaseProjectID:projectID
                             accessToken:accessToken
                              completion:^(QBResponse *response,
                                           QBUUser *userProfile)
         {
             response.success ?
             [source setResult:userProfile] :
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)loginWithTwitterDigitsAuthHeaders:(NSDictionary *)authHeaders {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self loginWithTwitterDigitsAuthHeaders:authHeaders
                                     completion:^(QBResponse *response,
                                                  QBUUser *userProfile)
         {
             response.success ?
             [source setResult:userProfile] :
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)loginWithFacebookSessionToken:(NSString *)sessionToken {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self logInWithFacebookSessionToken:sessionToken
                                 completion:^(QBResponse *response,
                                              QBUUser *userProfile)
         {
             response.success ?
             [source setResult:userProfile] :
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)loginWithTwitterAccessToken:(NSString *)accessToken
                      accessTokenSecret:(NSString *)accessTokenSecret {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self loginWithTwitterAccessToken:accessToken
                        accessTokenSecret:accessTokenSecret
                               completion:^(QBResponse *response,
                                            QBUUser *userProfile)
         {
             response.success ?
             [source setResult:userProfile] :
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)logout {
    
    return make_task(^(BFTaskCompletionSource *source) {
        
        [self logOut:^(QBResponse *response) {
            
             response.success ?
             [source setResult:nil] :
             [source setError:response.error.error];
         }];
    });
}

@end
