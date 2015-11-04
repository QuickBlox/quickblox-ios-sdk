//
//  QMUsersService.m
//  QMUsersService
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMUsersService.h"
#import "QMCancellationToken.h"

@interface QMUsersService () <QBChatDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QMUsersServiceDelegate> *multicastDelegate;
@property (strong, nonatomic) QMUsersMemoryStorage *usersMemoryStorage;
@property (weak, nonatomic) id<QMUsersServiceCacheDataSource> cacheDataSource;

@end

@implementation QMUsersService {
    BFTask* loadFromCacheTask;
}

- (void)dealloc {
    
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QBChat instance] removeDelegate:self];
    self.usersMemoryStorage = nil;
}

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager cacheDataSource:(id<QMUsersServiceCacheDataSource>)cacheDataSource
{
    self = [super initWithServiceManager:serviceManager];
    if (self) {
        self.cacheDataSource = cacheDataSource;
    }
    return self;
}

- (void)serviceWillStart
{
    self.multicastDelegate = (id<QMUsersServiceDelegate>)[[QBMulticastDelegate alloc] init];
    self.usersMemoryStorage = [[QMUsersMemoryStorage alloc] init];
}

#pragma mark - Tasks

- (BFTask *)loadFromCache
{
    if (loadFromCacheTask == nil) {
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        if ([self.cacheDataSource respondsToSelector:@selector(cachedUsers:)]) {
            @weakify(self);
            [self.cacheDataSource cachedUsers:^(NSArray *collection) {
                @strongify(self);
                [self.usersMemoryStorage addUsers:collection];
                [source setResult:collection];
            }];
            loadFromCacheTask = source.task;
            return loadFromCacheTask;
        } else {
            loadFromCacheTask = [BFTask taskWithResult:nil];
        }
    }
    
    return loadFromCacheTask;
}

#pragma mark - Add Remove multicaste delegate

- (void)addDelegate:(id <QMUsersServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMUsersServiceDelegate>)delegate {
    
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - Retrive users

- (BFTask<QBUUser *> *)getUserWithID:(NSUInteger)userID
{
    return (BFTask<QBUUser *> *)[[self getUsersWithIDs:@[@(userID)]] continueWithBlock:^id(BFTask *task) {
        return [BFTask taskWithResult:[task.result firstObject]];
    }];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithIDs:(NSArray<NSNumber *> *)usersIDs
{
    QBGeneralResponsePage *pageResponse =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:usersIDs.count < 100 ? usersIDs.count : 100];
    
    return [self getUsersWithIDs:usersIDs page:pageResponse];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithIDs:(NSArray<NSNumber *> *)usersIDs page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(usersIDs);
    NSParameterAssert(page);
    
    @weakify(self);
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        @strongify(self);
        
        NSDictionary* searchInfo = [self.usersMemoryStorage usersByExcludingUsersIDs:usersIDs];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        return [self getUsersWithIDs:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                          foundUsers:foundUsers
                       forceDownload:YES
                                page:page];
    }];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithIDs:(NSArray *)ids foundUsers:(NSArray *)foundUsers forceDownload:(BOOL)forceDownload page:(QBGeneralResponsePage *)page
{
    if (ids.count == 0) {
        return [BFTask taskWithResult:foundUsers];
    }

    @weakify(self);
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        @strongify(self);
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithIDs:ids page:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray * users) {
            [self.usersMemoryStorage addUsers:users];
            
            if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                [self.multicastDelegate usersService:self didAddUsers:users];
            }
            
            [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
        } errorBlock:^(QBResponse *response) {
            [source setError:response.error.error];
        }];
        
        return source.task;
    }];
}


- (BFTask<NSArray<QBUUser *> *> *)getUsersWithEmails:(NSArray<NSString *> *)emails
{
    return [self getUsersWithEmails:emails page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithEmails:(NSArray<NSString *> *)emails page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(emails);
    NSParameterAssert(page);
    
    @weakify(self)
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        @strongify(self);
        
        NSDictionary* searchInfo = [self.usersMemoryStorage usersByExcludingEmails:emails];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithEmails:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                              page:page
                      successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users) {
                          //
                          [self.usersMemoryStorage addUsers:users];
                          
                          if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                              [self.multicastDelegate usersService:self didAddUsers:users];
                          }
                          
                          [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
                      } errorBlock:^(QBResponse * _Nonnull response) {
                          //
                          [source setError:response.error.error];
                      }];
        
        return source.task;
    }];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithFacebookIDs:(NSArray<NSString *> *)facebookIDs
{
    QBGeneralResponsePage *pageResponse =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:facebookIDs.count < 100 ? facebookIDs.count : 100];
    
    return [self getUsersWithFacebookIDs:facebookIDs page:pageResponse];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithFacebookIDs:(NSArray<NSString *> *)facebookIDs page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(facebookIDs);
    NSParameterAssert(page);
    
    @weakify(self);
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        @strongify(self);
        
        NSDictionary* searchInfo = [self.usersMemoryStorage usersByExcludingFacebookIDs:facebookIDs];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithFacebookIDs:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                                   page:page
                           successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                               [self.usersMemoryStorage addUsers:users];
                               
                               if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                                   [self.multicastDelegate usersService:self didAddUsers:users];
                               }
                               
                               [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
                           } errorBlock:^(QBResponse *response) {
                               [source setError:response.error.error];
                           }];
        return source.task;
    }];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithLogins:(NSArray<NSString *> *)logins
{
    QBGeneralResponsePage *pageResponse =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:logins.count < 100 ? logins.count : 100];
    
    return [self getUsersWithLogins:logins page:pageResponse];
}

- (BFTask<NSArray<QBUUser *> *> *)getUsersWithLogins:(NSArray<NSString *> *)logins page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(logins);
    NSParameterAssert(page);
    
    @weakify(self);
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        @strongify(self);
        
        NSDictionary* searchInfo = [self.usersMemoryStorage usersByExcludingLogins:logins];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithLogins:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                              page:page
                      successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                          [self.usersMemoryStorage addUsers:users];
                          
                          if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                              [self.multicastDelegate usersService:self didAddUsers:users];
                          }
                          
                          [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
                      } errorBlock:^(QBResponse *response) {
                          [source setError:response.error.error];
                      }];
        return source.task;
    }];
}

#pragma mark - Search

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithFullName:(NSString *)searchText
{
    return [self searchUsersWithFullName:searchText page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithFullName:(NSString *)searchText page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(searchText);
    NSParameterAssert(page);
    
    @weakify(self);
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        @strongify(self);
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithFullName:searchText page:page
                        successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                            [self.usersMemoryStorage addUsers:users];
                            
                            if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                                [self.multicastDelegate usersService:self didAddUsers:users];
                            }
                            
                            [source setResult:users];
                        } errorBlock:^(QBResponse *response) {
                            [source setError:response.error.error];
                        }];
        
        return source.task;
    }];
}

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithTags:(NSArray<NSString *> *)tags
{
    return [self searchUsersWithTags:tags page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask<NSArray<QBUUser *> *> *)searchUsersWithTags:(NSArray<NSString *> *)tags page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(tags);
    NSParameterAssert(page);
    
    @weakify(self);
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        @strongify(self);
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithTags:tags
                            page:page
                    successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users) {
                        //
                        [self.usersMemoryStorage addUsers:users];
                        
                        if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                            [self.multicastDelegate usersService:self didAddUsers:users];
                        }
                        
                        [source setResult:users];
                    } errorBlock:^(QBResponse * _Nonnull response) {
                        //
                        [source setError:response.error.error];
                    }];
        return source.task;
    }];
}

@end
