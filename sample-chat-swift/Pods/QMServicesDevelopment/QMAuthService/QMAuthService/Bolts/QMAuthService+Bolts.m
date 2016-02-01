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
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self signUpAndLoginWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
        //
        response.success ? [source setResult:userProfile] : [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)loginWithUser:(QBUUser *)user {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self logInWithUser:user completion:^(QBResponse *response, QBUUser *userProfile) {
        //
        response.success ? [source setResult:userProfile] : [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)loginWithTwitterDigitsAuthHeaders:(NSDictionary *)authHeaders {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self loginWithTwitterDigitsAuthHeaders:authHeaders completion:^(QBResponse *response, QBUUser *userProfile) {
        //
        response.success ? [source setResult:userProfile] : [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)loginWithFacebookSessionToken:(NSString *)sessionToken {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self logInWithFacebookSessionToken:sessionToken completion:^(QBResponse *response, QBUUser *userProfile) {
        //
        response.success ? [source setResult:userProfile] : [source setError:response.error.error];
    }];
    
    return source.task;
}

- (BFTask *)logout {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [self logOut:^(QBResponse *response) {
        //
        response.success ? [source setResult:nil] : [source setError:response.error.error];
    }];
    
    return source.task;
}

@end
