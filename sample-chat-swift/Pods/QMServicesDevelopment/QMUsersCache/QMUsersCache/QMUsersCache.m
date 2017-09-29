//
//  QMUsersCache.m
//  QMUsersCache
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMUsersCache.h"
#import "QMUsersModelIncludes.h"

#import "QMSLog.h"

@implementation QMUsersCache

static QMUsersCache *_usersCacheInstance = nil;

//MARK: - Singleton

+ (QMUsersCache *)instance {
    
    NSAssert(_usersCacheInstance, @"You must first perform @selector(setupDBWithStoreNamed:)");
    return _usersCacheInstance;
}

//MARK: - Configure store

+ (void)setupDBWithStoreNamed:(NSString *)storeName
   applicationGroupIdentifier:(NSString *)appGroupIdentifier {
    
    NSManagedObjectModel *model =
    [NSManagedObjectModel QM_newModelNamed:@"QMUsersModel.momd"
                             inBundleNamed:@"QMUsersCacheModel.bundle"
                                 fromClass:[self class]];
    
    NSParameterAssert(!_usersCacheInstance);
    _usersCacheInstance =
    [[QMUsersCache alloc] initWithStoreNamed:storeName
                                       model:model
                  applicationGroupIdentifier:appGroupIdentifier];
}

+ (void)setupDBWithStoreNamed:(NSString *)storeName {
    
    return [self setupDBWithStoreNamed:storeName
            applicationGroupIdentifier:nil];
}

+ (void)cleanDBWithStoreName:(NSString *)name {
    
    if (_usersCacheInstance) {
        _usersCacheInstance = nil;
    }
    [super cleanDBWithStoreName:name];
}

//MARK: - Users

- (BFTask *)insertOrUpdateUser:(QBUUser *)user {
    
    return [self insertOrUpdateUsers:@[user]];
}

- (BFTask *)insertOrUpdateUsers:(NSArray<QBUUser *> *)users {
    
    BFTaskCompletionSource *source =
    [BFTaskCompletionSource taskCompletionSource];
    
    [self save:^(NSManagedObjectContext *ctx) {
        //To Insert / Update
        for (QBUUser *user in users) {
            
            CDUser *cachedUser =
            [CDUser QM_findFirstOrCreateByAttribute:@"id"
                                          withValue:@(user.ID)
                                          inContext:ctx];
            
            QBUUser *cachedQBUser = [cachedUser toQBUUser];
            if ([cachedQBUser.lastRequestAt compare:user.lastRequestAt] == NSOrderedDescending) {
                // always should have newest date
                user.lastRequestAt = cachedQBUser.lastRequestAt;
            }
            [cachedUser updateWithQBUser:user];
        }
        
        QMSLog(@"[%@] Users to insert %tu, update %tu",
               NSStringFromClass([QMUsersCache class]),
               ctx.insertedObjects.count,
               ctx.updatedObjects.count);
        
    } finish:^{
        [source setResult:nil];
    }];
    
    return source.task;
}

- (BFTask *)deleteUser:(QBUUser *)user {
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    [self save:^(NSManagedObjectContext *ctx) {
        
        [CDUser QM_deleteAllMatchingPredicate:IS(@"id", @(user.ID))
                                    inContext:ctx];
    } finish:^{
        
        [source setResult:nil];
    }];
    
    return source.task;
}

- (BFTask *)deleteAllUsers {
    
    BFTaskCompletionSource *source =
    [BFTaskCompletionSource taskCompletionSource];
    
    [self save:^(NSManagedObjectContext *ctx) {
        
        [CDUser QM_truncateAllInContext:ctx];
        
    } finish:^{
        
        [source setResult:nil];
    }];
    
    return source.task;
}

- (BFTask<QBUUser *> *)userWithPredicate:(NSPredicate *)predicate {
    
    BFTaskCompletionSource *source =
    [BFTaskCompletionSource taskCompletionSource];
    
    [self performMainQueue:^(NSManagedObjectContext *ctx) {
        
        QBUUser *user =
        [[CDUser QM_findFirstWithPredicate:predicate
                                 inContext:ctx] toQBUUser];
        [source setResult:user];
    }];
    
    return source.task;
}

- (BFTask <NSArray<QBUUser *> *> *)usersSortedBy:(NSString *)sortTerm
                                       ascending:(BOOL)ascending {
    
    return [self usersWithPredicate:nil
                           sortedBy:sortTerm
                          ascending:ascending];
}

- (NSArray <QBUUser*> *)allUsers {
    
    __block NSArray<QBUUser *> *result = nil;
    [self performMainQueue:^(NSManagedObjectContext *ctx) {
        result = [[CDUser QM_findAllInContext:ctx] toQBUUsers];
    }];
    
    return result;
}

- (BFTask <NSArray<QBUUser *> *> *)usersWithPredicate:(NSPredicate *)predicate
                                             sortedBy:(NSString *)sortTerm
                                            ascending:(BOOL)ascending {
    BFTaskCompletionSource *source =
    [BFTaskCompletionSource taskCompletionSource];
    
    [self performBackgroundQueue:^(NSManagedObjectContext *ctx) {
        
        NSArray<QBUUser *> *result =
        [[CDUser QM_findAllSortedBy:sortTerm
                          ascending:ascending
                      withPredicate:predicate
                          inContext:ctx] toQBUUsers];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [source setResult:result];
        });
    }];
    
    return source.task;
}

@end
