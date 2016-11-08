//
//  QMUsersService.m
//  QMUsersService
//
//  Created by Andrey Moskvin on 10/23/15.
//  Copyright © 2015 Quickblox. All rights reserved.
//

#import "QMUsersService.h"

#import "QMSLog.h"

@interface QMUsersService () <QBChatDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QMUsersServiceDelegate> *multicastDelegate;
@property (strong, nonatomic) QMUsersMemoryStorage *usersMemoryStorage;
@property (weak, nonatomic) id<QMUsersServiceCacheDataSource> cacheDataSource;

@end

@implementation QMUsersService {
    BFTask* loadFromCacheTask;
}

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QBChat instance] removeDelegate:self];
}

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager cacheDataSource:(id<QMUsersServiceCacheDataSource>)cacheDataSource {
    
    self = [super initWithServiceManager:serviceManager];
    if (self) {
        
        self.cacheDataSource = cacheDataSource;
    }
    
    return self;
}

- (void)serviceWillStart {
    
    self.multicastDelegate = (id<QMUsersServiceDelegate>)[[QBMulticastDelegate alloc] init];
    self.usersMemoryStorage = [[QMUsersMemoryStorage alloc] init];
}

#pragma mark - Tasks

- (BFTask *)loadFromCache {
    
    if (loadFromCacheTask == nil) {
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        if ([self.cacheDataSource respondsToSelector:@selector(cachedUsersWithCompletion:)]) {
            
            __weak __typeof(self)weakSelf = self;
            [self.cacheDataSource cachedUsersWithCompletion:^(NSArray *collection) {
                __typeof(weakSelf)strongSelf = weakSelf;
                
                if (collection.count > 0) {
                    
                    [strongSelf.usersMemoryStorage addUsers:collection];
                    
                    if ([strongSelf.multicastDelegate respondsToSelector:@selector(usersService:didLoadUsersFromCache:)]) {
                        
                        [strongSelf.multicastDelegate usersService:strongSelf didLoadUsersFromCache:collection];
                    }
                }
                
                [source setResult:collection];
            }];
            
            loadFromCacheTask = source.task;
            
            return loadFromCacheTask;
        }
        else {
            
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
#pragma mark - Get users by ID

- (BFTask *)getUserWithID:(NSUInteger)userID {
    
    return [self getUserWithID:userID
                     forceLoad:NO];
}

- (BFTask *)getUserWithID:(NSUInteger)userID forceLoad:(BOOL)forceLoad {
    
    return [[self getUsersWithIDs:@[@(userID)]
                             page:[self generalResponsePageForCount:1]
                        forceLoad:forceLoad] continueWithBlock:^id(BFTask *task) {
        
        return [BFTask taskWithResult:[task.result firstObject]];
    }];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs {
    
    return [self getUsersWithIDs:usersIDs
                            page:[self generalResponsePageForCount:usersIDs.count]
                       forceLoad:NO];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithIDs:usersIDs
                            page:[self generalResponsePageForCount:usersIDs.count]
                       forceLoad:forceLoad];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithIDs:usersIDs
                            page:page
                       forceLoad:NO];
}

-  (BFTask *)getUsersWithIDs:(NSArray *)usersIDs page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad {
    NSParameterAssert(usersIDs);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary *searchInfo = [strongSelf.usersMemoryStorage usersByExcludingUsersIDs:usersIDs];
        NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        NSArray *notFoundIDs = searchInfo[QMUsersSearchKey.notFoundSearchValues];
        
        if (!forceLoad && notFoundIDs.count == 0) {
            
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        NSArray *searchableUsers = forceLoad ? usersIDs : notFoundIDs;
        
        [QBRequest usersWithIDs:searchableUsers
                           page:page
                   successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                       
                       NSArray *result = [strongSelf performUpdateWithLoadedUsers:users
                                                                       foundUsers:foundUsers
                                                                    wasLoadForced:forceLoad];
                       
                       [source setResult:result];
                       
                   } errorBlock:^(QBResponse *response) {
                       
                       [source setError:response.error.error];
                   }];
        
        return source.task;
    }];
}

#pragma mark - Get user by External IDs

- (BFTask *)getUserWithExternalID:(NSUInteger)externalUserID {
    
    return [self getUserWithExternalID:externalUserID
                             forceLoad:NO];
}

- (BFTask *)getUserWithExternalID:(NSUInteger)externalUserID forceLoad:(BOOL)forceLoad {
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        
        QBUUser *user = [strongSelf.usersMemoryStorage userWithExternalID:externalUserID];
        if (user != nil) {
            
            [source setResult:user];
        }
        else {
            
            [QBRequest userWithExternalID:externalUserID
                             successBlock:^(QBResponse *response, QBUUser *user) {
                                 
                                 [source setResult:user];
                                 
                             } errorBlock:^(QBResponse *response) {
                                 
                                 [source setError:response.error.error];
                             }];
        }
        
        return source.task;
    }];
}

#pragma mark - Get users by emails

- (BFTask *)getUsersWithEmails:(NSArray *)emails {
    
    return [self getUsersWithEmails:emails
                               page:[self generalResponsePageForCount:emails.count]
                          forceLoad:NO];
}

- (BFTask *)getUsersWithEmails:(NSArray *)emails forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithEmails:emails
                               page:[self generalResponsePageForCount:emails.count]
                          forceLoad:forceLoad];
}

- (BFTask *)getUsersWithEmails:(NSArray *)emails page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithEmails:emails
                               page:page
                          forceLoad:NO];
}

- (BFTask *)getUsersWithEmails:(NSArray *)emails page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad {
    NSParameterAssert(emails);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary *searchInfo = [strongSelf.usersMemoryStorage usersByExcludingEmails:emails];
        NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        NSArray *notFoundEmails = searchInfo[QMUsersSearchKey.notFoundSearchValues];
        
        if (!forceLoad && notFoundEmails.count == 0) {
            
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        NSArray *searchableUsers = forceLoad ? emails : notFoundEmails;
        
        [QBRequest usersWithEmails:searchableUsers
                              page:page
                      successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                          
                          NSArray *result = [strongSelf performUpdateWithLoadedUsers:users
                                                                          foundUsers:foundUsers
                                                                       wasLoadForced:forceLoad];
                          
                          [source setResult:result];
                          
                      } errorBlock:^(QBResponse *response) {
                          
                          [source setError:response.error.error];
                      }];
        
        return source.task;
    }];
}

#pragma mark - Get users by Facebook IDs

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs {
    
    return [self getUsersWithFacebookIDs:facebookIDs
                                    page:[self generalResponsePageForCount:facebookIDs.count]
                               forceLoad:NO];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithFacebookIDs:facebookIDs
                                    page:[self generalResponsePageForCount:facebookIDs.count]
                               forceLoad:forceLoad];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithFacebookIDs:facebookIDs
                                    page:page
                               forceLoad:NO];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad {
    NSParameterAssert(facebookIDs);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary *searchInfo = [strongSelf.usersMemoryStorage usersByExcludingFacebookIDs:facebookIDs];
        NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        NSArray *notFoundFacebookIDs = searchInfo[QMUsersSearchKey.notFoundSearchValues];
        
        if (!forceLoad && notFoundFacebookIDs.count == 0) {
            
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        NSArray *searchableUsers = forceLoad ? facebookIDs : notFoundFacebookIDs;
        
        [QBRequest usersWithFacebookIDs:searchableUsers
                                   page:page
                           successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                               
                               NSArray *result = [strongSelf performUpdateWithLoadedUsers:users
                                                                               foundUsers:foundUsers
                                                                            wasLoadForced:forceLoad];
                               
                               [source setResult:result];
                               
                           } errorBlock:^(QBResponse *response) {
                               
                               [source setError:response.error.error];
                           }];
        
        return source.task;
    }];
}

#pragma mark - Get users by Twitter IDs

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs {
    
    return [self getUsersWithTwitterIDs:twitterIDs
                                   page:[self generalResponsePageForCount:twitterIDs.count]
                              forceLoad:NO];
}

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithTwitterIDs:twitterIDs
                                   page:[self generalResponsePageForCount:twitterIDs.count]
                              forceLoad:forceLoad];
}

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithTwitterIDs:twitterIDs
                                   page:page
                              forceLoad:NO];
}

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad {
    NSParameterAssert(twitterIDs);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary *searchInfo = [strongSelf.usersMemoryStorage usersByExcludingTwitterIDs:twitterIDs];
        NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        NSArray *notFoundTwitterIDs = searchInfo[QMUsersSearchKey.notFoundSearchValues];
        
        if (!forceLoad && notFoundTwitterIDs.count == 0) {
            
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        NSArray *searchableUsers = forceLoad ? twitterIDs : notFoundTwitterIDs;
        
        [QBRequest usersWithTwitterIDs:searchableUsers
                                  page:page
                          successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                              
                              NSArray *result = [strongSelf performUpdateWithLoadedUsers:users
                                                                              foundUsers:foundUsers
                                                                           wasLoadForced:forceLoad];
                              
                              [source setResult:result];
                              
                          } errorBlock:^(QBResponse *response) {
                              
                              [source setError:response.error.error];
                          }];
        
        return source.task;
    }];
}

#pragma mark - Get users by Logins

- (BFTask *)getUsersWithLogins:(NSArray *)logins {
    
    return [self getUsersWithLogins:logins
                               page:[self generalResponsePageForCount:logins.count]
                          forceLoad:NO];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithLogins:logins
                               page:[self generalResponsePageForCount:logins.count]
                          forceLoad:forceLoad];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithLogins:logins
                               page:page
                          forceLoad:NO];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins page:(QBGeneralResponsePage *)page forceLoad:(BOOL)forceLoad {
    NSParameterAssert(logins);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        NSDictionary *searchInfo = [strongSelf.usersMemoryStorage usersByExcludingLogins:logins];
        NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
        NSArray *notFoundLogins = searchInfo[QMUsersSearchKey.notFoundSearchValues];
        
        if (!forceLoad && notFoundLogins.count == 0) {
            
            return [BFTask taskWithResult:foundUsers];
        }
        
        BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
        NSArray *searchableUsers = forceLoad ? logins : notFoundLogins;
        
        [QBRequest usersWithLogins:searchableUsers
                              page:page
                      successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                          
                          NSArray *result = [strongSelf performUpdateWithLoadedUsers:users
                                                                          foundUsers:foundUsers
                                                                       wasLoadForced:forceLoad];
                          
                          [source setResult:result];
                          
                      } errorBlock:^(QBResponse *response) {
                          
                          [source setError:response.error.error];
                      }];
        
        return source.task;
    }];
}

#pragma mark - Search

- (BFTask *)searchUsersWithFullName:(NSString *)searchText {
    
    return [self searchUsersWithFullName:searchText
                                    page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithFullName:(NSString *)searchText page:(QBGeneralResponsePage *)page
{
    NSParameterAssert(searchText);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithFullName:searchText
                                page:page
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

- (BFTask *)searchUsersWithTags:(NSArray *)tags {
    
    return [self searchUsersWithTags:tags
                                page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithTags:(NSArray *)tags page:(QBGeneralResponsePage *)page {
    NSParameterAssert(tags);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithTags:tags
                            page:page
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

- (BFTask *)searchUsersWithPhoneNumbers:(NSArray *)phoneNumbers {
    
    return [self searchUsersWithPhoneNumbers:phoneNumbers
                                        page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithPhoneNumbers:(NSArray *)phoneNumbers page:(QBGeneralResponsePage *)page {
    NSParameterAssert(phoneNumbers);
    NSParameterAssert(page);
    
    __weak __typeof(self)weakSelf = self;
    return [[self loadFromCache] continueWithBlock:^id(BFTask *task) {
        
        __typeof(weakSelf)strongSelf = weakSelf;
        
        BFTaskCompletionSource* source = [BFTaskCompletionSource taskCompletionSource];
        
        [QBRequest usersWithPhoneNumbers:phoneNumbers
                                    page:page
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

#pragma mark - Helpers

- (NSArray *)performUpdateWithLoadedUsers:(NSArray *)loadedUsers
                               foundUsers:(NSArray *)foundUsers
                            wasLoadForced:(BOOL)wasLoadForced {
    
    [self.usersMemoryStorage addUsers:loadedUsers];
    
    NSArray *result = loadedUsers;
    
    if (wasLoadForced) {
        
        NSMutableArray *mutableNewUsers = loadedUsers.mutableCopy;
        [mutableNewUsers removeObjectsInArray:foundUsers];
        
        NSMutableArray *mutableUpdatedUsers = loadedUsers.mutableCopy;
        [mutableUpdatedUsers removeObjectsInArray:mutableNewUsers];
        
        if (mutableNewUsers.count > 0 &&
            [self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
            
            [self.multicastDelegate usersService:self didAddUsers:mutableNewUsers.copy];
        }
        
        if (mutableUpdatedUsers.count > 0 &&
            [self.multicastDelegate respondsToSelector:@selector(usersService:didUpdateUsers:)]) {
            
            [self.multicastDelegate usersService:self didUpdateUsers:mutableUpdatedUsers.copy];
        }
    }
    else {
        
        if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
            
            [self.multicastDelegate usersService:self didAddUsers:loadedUsers];
        }
        
        result = [foundUsers arrayByAddingObjectsFromArray:result];
    }
    
    return result;
}

- (QBGeneralResponsePage *)generalResponsePageForCount:(NSUInteger)count {
    
    return [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:count < 100 ? count : 100];
}

@end
