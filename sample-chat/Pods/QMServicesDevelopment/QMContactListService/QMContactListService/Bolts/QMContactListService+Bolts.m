//
//  QMContactListService+Bolts.m
//  QMServices
//
//  Created by Vitaliy Gorbachov on 12/29/15.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMContactListService.h"

@interface QMContactListService ()

@property (weak, nonatomic) id<QMContactListServiceCacheDataSource> cacheDataSource;

@end

@implementation QMContactListService (Bolts)

- (BFTask *)addUserToContactListRequest:(QBUUser *)user {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    @weakify(self);
    [[QBChat instance] addUserToContactListRequest:user.ID completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            @strongify(self);
            if ([self.cacheDataSource respondsToSelector:@selector(contactListDidAddUser:)]) {
                [self.cacheDataSource contactListDidAddUser:user];
            }
            
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)removeUserFromContactListWithUserID:(NSUInteger)userID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [[QBChat instance] removeUserFromContactList:userID completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)acceptContactRequest:(NSUInteger)userID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [[QBChat instance] confirmAddContactRequest:userID completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

- (BFTask *)rejectContactRequest:(NSUInteger)userID {
    
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [[QBChat instance] rejectAddContactRequest:userID completion:^(NSError *error) {
        //
        if (error != nil) {
            [source setError:error];
        } else {
            [source setResult:nil];
        }
    }];
    
    return source.task;
}

@end
