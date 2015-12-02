//
//  QMUsersCache.m
//  QMUsersCache
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMUsersCache.h"
#import "QMUsersModelIncludes.h"

@implementation QMUsersCache

static QMUsersCache *_usersCacheInstance = nil;

- (NSManagedObjectContext *)backgroundContext
{
    return self.stack.context;
}

#pragma mark - Singleton

+ (QMUsersCache *)instance
{
    NSAssert(_usersCacheInstance, @"You must first perform @selector(setupDBWithStoreNamed:)");
    return _usersCacheInstance;
}

#pragma mark - Configure store

+ (void)setupDBWithStoreNamed:(NSString *)storeName
{
    NSManagedObjectModel *model =
    [NSManagedObjectModel QM_newModelNamed:@"QMUsersModel.momd"
                             inBundleNamed:@"QMUsersCacheModel.bundle"];
    _usersCacheInstance = [[QMUsersCache alloc] initWithStoreNamed:storeName
                                                             model:model
                                                        queueLabel:"com.qmservices.QMUsersCacheQueue"];
}

+ (void)cleanDBWithStoreName:(NSString *)name
{
    if (_usersCacheInstance) {
        _usersCacheInstance = nil;
    }
    [super cleanDBWithStoreName:name];
}

#pragma mark - Users

- (BFTask *)insertOrUpdateUser:(QBUUser *)user
{
    return [self insertOrUpdateUsers:@[user]];
}

- (BFTask *)insertOrUpdateUsers:(NSArray *)users
{
    __weak __typeof(self)weakSelf = self;
    return [BFTask taskFromExecutor:[BFExecutor executorWithDispatchQueue:self.queue] withBlock:^id{
        __typeof(self) strongSelf = weakSelf;
        
        NSManagedObjectContext* context = [strongSelf backgroundContext];
        
        NSMutableArray *toInsert = [NSMutableArray array];
        NSMutableArray *toUpdate = [NSMutableArray array];
        
        //To Insert / Update
        for (QBUUser *user in users) {
            
            CDUser *cachedUser = [CDUser QM_findFirstWithPredicate:IS(@"id", @(user.ID)) inContext:context];
            
            if (cachedUser) {
                
                QBUUser *qbCachedUser = [cachedUser toQBUUser];
                
                if (![user isEqual:qbCachedUser]) {
                    [toUpdate addObject:user];
                }
            }
            else {
                
                [toInsert addObject:user];
            }
        }
        
        if (toUpdate.count > 0) {
            
            [strongSelf updateUsers:toUpdate inContext:context];
        }
        
        if (toInsert.count > 0) {
            
            [strongSelf insertUsers:toInsert inContext:context];
        }
        
        if (toInsert.count + toUpdate.count > 0) {
            [context QM_saveToPersistentStoreAndWait];
        }
        
        NSLog(@"Users to insert %lu", (unsigned long)toInsert.count);
        NSLog(@"Users to update %lu", (unsigned long)toUpdate.count);

        return nil;
    }];
}

- (BFTask *)deleteUser:(QBUUser *)user
{
    __weak __typeof(self)weakSelf = self;
    return [BFTask taskFromExecutor:[BFExecutor executorWithDispatchQueue:self.queue] withBlock:^id{
        __typeof(self) strongSelf = weakSelf;
        NSManagedObjectContext* context = [strongSelf backgroundContext];
        
        CDUser *cachedUser = [CDUser QM_findFirstWithPredicate:IS(@"id", @(user.ID)) inContext:context];
        [cachedUser QM_deleteEntityInContext:context];
        
        [context saveToPersistentStoreAndWait];
        
        return nil;
    }];
}

- (BFTask *)deleteAllUsers
{
    __weak __typeof(self)weakSelf = self;
    return [BFTask taskFromExecutor:[BFExecutor executorWithDispatchQueue:self.queue] withBlock:^id{
        __typeof(self) strongSelf = weakSelf;
        NSManagedObjectContext* context = [strongSelf backgroundContext];
        
        [CDUser QM_truncateAllInContext:context];
        
        [context saveToPersistentStoreAndWait];
        return nil;
    }];
}

- (BFTask *)userWithPredicate:(NSPredicate *) predicate
{
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];

    [BFTask taskFromExecutor:[BFExecutor executorWithDispatchQueue:self.queue] withBlock:^id{
        
        CDUser *user = [CDUser QM_findFirstWithPredicate:predicate];
        QBUUser *result = [user toQBUUser];
        
        [source setResult:result];
        
        return nil;
    }];
    
    return source.task;
}

- (BFTask *)usersSortedBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
    return [self usersWithPredicate:nil sortedBy:sortTerm ascending:ascending];
}

- (BFTask *)usersWithPredicate:(NSPredicate *)predicate sortedBy:(NSString *)sortTerm ascending:(BOOL)ascending
{
    __weak __typeof(self)weakSelf = self;
    BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
    
    [BFTask taskFromExecutor:[BFExecutor executorWithDispatchQueue:self.queue] withBlock:^id{
        __typeof(self) strongSelf = weakSelf;
        
        NSManagedObjectContext* context = [strongSelf backgroundContext];
        
        NSArray *users = [CDUser QM_findAllSortedBy:sortTerm ascending:ascending withPredicate:predicate inContext:context];
        NSArray *result = [weakSelf convertCDUsertsToQBUsers:users];
        
        [source setResult:result];
        
        return nil;
    }];
    
    return source.task;
}

#pragma mark - Private

- (void)insertUsers:(NSArray *)users inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *user in users) {
        
        CDUser *newUser = [CDUser QM_createEntityInContext:context];
        [newUser updateWithQBUser:user];
    }
}

- (void)updateUsers:(NSArray *)qbUsers inContext:(NSManagedObjectContext *)context {
    
    for (QBUUser *qbUser in qbUsers) {
        
        CDUser *userToUpdate = [CDUser QM_findFirstWithPredicate:IS(@"id", @(qbUser.ID)) inContext:context];
        [userToUpdate updateWithQBUser:qbUser];
    }
}

- (NSArray *)convertCDUsertsToQBUsers:(NSArray *)cdUsers {
    
    NSMutableArray *users =
    [NSMutableArray arrayWithCapacity:cdUsers.count];
    
    for (CDUser *user in cdUsers) {
        
        QBUUser *qbUser = [user toQBUUser];
        [users addObject:qbUser];
    }
    
    return users;
}

@end
