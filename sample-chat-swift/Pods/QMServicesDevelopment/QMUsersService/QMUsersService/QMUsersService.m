//
//  QMUsersService.m
//  QMUsersService
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMUsersService.h"

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
            __weak __typeof(self)weakSelf = self;
            [self.cacheDataSource cachedUsers:^(NSArray *collection) {
                
                [weakSelf.usersMemoryStorage addUsers:collection];
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

- (BFTask *)getUserWithID:(NSUInteger)userID
{
    return (BFTask *)[[self getUsersWithIDs:@[@(userID)]] continueWithBlock:^id(BFTask *task) {
        return [BFTask taskWithResult:[task.result firstObject]];
    }];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs
{
    QBGeneralResponsePage *pageResponse =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:usersIDs.count < 100 ? usersIDs.count : 100];
    
    return [self getUsersWithIDs:usersIDs page:pageResponse];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(usersIDs);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary* searchInfo = [strongSelf.usersMemoryStorage usersByExcludingUsersIDs:usersIDs];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        return [strongSelf getUsersWithIDs:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                          foundUsers:foundUsers
                       forceDownload:YES
                                page:page];
    }];
}

- (BFTask *)getUsersWithIDs:(NSArray *)ids foundUsers:(NSArray *)foundUsers forceDownload:(BOOL)forceDownload page:(QBGeneralResponsePage *)page
{
    if (ids.count == 0) {
        return [BFTask taskWithResult:foundUsers];
    }

    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithIDs:ids page:page successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray * users) {
            [strongSelf.usersMemoryStorage addUsers:users];
            
            if ([strongSelf.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                [strongSelf.multicastDelegate usersService:strongSelf didAddUsers:users];
            }
            
            [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
        } errorBlock:^(QBResponse *response) {
            [source setError:response.error.error];
        }];
        
        return source.task;
    }];
}


- (BFTask *)getUsersWithEmails:(NSArray *)emails
{
    return [self getUsersWithEmails:emails page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)getUsersWithEmails:(NSArray *)emails page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(emails);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary* searchInfo = [strongSelf.usersMemoryStorage usersByExcludingEmails:emails];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithEmails:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                              page:page
                      successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                          //
                          [strongSelf.usersMemoryStorage addUsers:users];
                          
                          if ([strongSelf.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                              [strongSelf.multicastDelegate usersService:strongSelf didAddUsers:users];
                          }
                          
                          [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
                      } errorBlock:^(QBResponse *response) {
                          //
                          [source setError:response.error.error];
                      }];
        
        return source.task;
    }];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs
{
    QBGeneralResponsePage *pageResponse =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:facebookIDs.count < 100 ? facebookIDs.count : 100];
    
    return [self getUsersWithFacebookIDs:facebookIDs page:pageResponse];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(facebookIDs);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary* searchInfo = [strongSelf.usersMemoryStorage usersByExcludingFacebookIDs:facebookIDs];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithFacebookIDs:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                                   page:page
                           successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                               [strongSelf.usersMemoryStorage addUsers:users];
                               
                               if ([strongSelf.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                                   [strongSelf.multicastDelegate usersService:strongSelf didAddUsers:users];
                               }
                               
                               [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
                           } errorBlock:^(QBResponse *response) {
                               [source setError:response.error.error];
                           }];
        return source.task;
    }];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins
{
    QBGeneralResponsePage *pageResponse =
    [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:logins.count < 100 ? logins.count : 100];
    
    return [self getUsersWithLogins:logins page:pageResponse];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(logins);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary* searchInfo = [strongSelf.usersMemoryStorage usersByExcludingLogins:logins];
        NSArray* foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        if ([searchInfo[QMUsersSearchKey.notFoundSearchValues] count] == 0) {
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithLogins:searchInfo[QMUsersSearchKey.notFoundSearchValues]
                              page:page
                      successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                          [strongSelf.usersMemoryStorage addUsers:users];
                          
                          if ([strongSelf.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                              [strongSelf.multicastDelegate usersService:strongSelf didAddUsers:users];
                          }
                          
                          [source setResult:[foundUsers arrayByAddingObjectsFromArray:users]];
                      } errorBlock:^(QBResponse *response) {
                          [source setError:response.error.error];
                      }];
        return source.task;
    }];
}

#pragma mark - Search

- (BFTask *)searchUsersWithFullName:(NSString *)searchText
{
    return [self searchUsersWithFullName:searchText page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithFullName:(NSString *)searchText page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(searchText);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithFullName:searchText page:page
                        successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                            [strongSelf.usersMemoryStorage addUsers:users];
                            
                            if ([strongSelf.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                                [strongSelf.multicastDelegate usersService:strongSelf didAddUsers:users];
                            }
                            
                            [source setResult:users];
                        } errorBlock:^(QBResponse *response) {
                            [source setError:response.error.error];
                        }];
        
        return source.task;
    }];
}

- (BFTask *)searchUsersWithTags:(NSArray *)tags
{
    return [self searchUsersWithTags:tags page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithTags:(NSArray *)tags page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(tags);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        __typeof(weakSelf)strongSelf = weakSelf;
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithTags:tags
                            page:page
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                        //
                        [strongSelf.usersMemoryStorage addUsers:users];
                        
                        if ([strongSelf.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                            [strongSelf.multicastDelegate usersService:strongSelf didAddUsers:users];
                        }
                        
                        [source setResult:users];
                    } errorBlock:^(QBResponse *response) {
                        //
                        [source setError:response.error.error];
                    }];
        return source.task;
    }];
}

@end
