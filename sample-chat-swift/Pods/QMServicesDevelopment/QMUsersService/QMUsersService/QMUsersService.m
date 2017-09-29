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
@property (strong, nonatomic) NSMutableDictionary <QBUUser *, QBMulticastDelegate <QMUsersServiceListenerProtocol> *> *listeners;

@end

@implementation QMUsersService

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QBChat instance] removeDelegate:self];
}

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(id<QMUsersServiceCacheDataSource>)cacheDataSource {
    
    self = [super initWithServiceManager:serviceManager];
    if (self) {
        
        _cacheDataSource = cacheDataSource;
        [self loadFromCache];
        _listeners = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)serviceWillStart {
    
    _multicastDelegate =
    (id<QMUsersServiceDelegate>)[[QBMulticastDelegate alloc] init];
    _usersMemoryStorage = [[QMUsersMemoryStorage alloc] init];
}

- (void)free {
    
    [self.usersMemoryStorage free];
}
//MARK: - Tasks

- (void)loadFromCache {
    
    if ([self.cacheDataSource
         respondsToSelector:@selector(cachedUsersWithCompletion:)]) {
        
        __weak __typeof(self)weakSelf = self;
        [self.cacheDataSource cachedUsersWithCompletion:^(NSArray *collection) {
            
            if (collection.count > 0) {
                
                [weakSelf.usersMemoryStorage addUsers:collection];
                
                if ([weakSelf.multicastDelegate
                     respondsToSelector:@selector(usersService:
                                                  didLoadUsersFromCache:)]) {
                         [weakSelf.multicastDelegate usersService:weakSelf
                                            didLoadUsersFromCache:collection];
                     }
            }
        }];
    }
}

//MARK: - Add Remove multicaste delegate

- (void)addDelegate:(id <QMUsersServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMUsersServiceDelegate>)delegate {
    
    [self.multicastDelegate removeDelegate:delegate];
}

// MARK: - Listeners

- (void)addListener:(id<QMUsersServiceListenerProtocol>)listenerDelegate forUser:(QBUUser *)user {
    QBMulticastDelegate<QMUsersServiceListenerProtocol> *multicastDelegate = self.listeners[user];
    if (multicastDelegate == nil) {
        multicastDelegate = (id<QMUsersServiceListenerProtocol>)[[QBMulticastDelegate alloc] init];
        self.listeners[user] = multicastDelegate;
    }
    [multicastDelegate addDelegate:listenerDelegate];
}

- (void)removeListener:(id<QMUsersServiceListenerProtocol>)listenerDelegate forUser:(QBUUser *)user {
    QBMulticastDelegate<QMUsersServiceListenerProtocol> *multicastDelegate = self.listeners[user];
    if (multicastDelegate != nil) {
        [multicastDelegate removeDelegate:listenerDelegate];
        if (multicastDelegate.delegates.count == 0) {
            self.listeners[user] = nil;
        }
    }
}

//MARK: - Retrive users
//MARK: - Get users by ID

- (BFTask *)getUserWithID:(NSUInteger)userID {
    
    if (userID == 0) return nil;
    return [self getUserWithID:userID
                     forceLoad:NO];
}

- (BFTask *)getUserWithID:(NSUInteger)userID forceLoad:(BOOL)forceLoad {
    
    return [[self getUsersWithIDs:@[@(userID)]
                             page:[self pageForCount:1]
                        forceLoad:forceLoad]
            continueWithBlock:^id(BFTask *task)
            {
                return [BFTask taskWithResult:[task.result firstObject]];
            }];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs {
    
    return [self getUsersWithIDs:usersIDs
                            page:[self pageForCount:usersIDs.count]
                       forceLoad:NO];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithIDs:usersIDs
                            page:[self pageForCount:usersIDs.count]
                       forceLoad:forceLoad];
}

- (BFTask *)getUsersWithIDs:(NSArray *)usersIDs
                       page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithIDs:usersIDs
                            page:page
                       forceLoad:NO];
}

-  (BFTask *)getUsersWithIDs:(NSArray *)usersIDs
                        page:(QBGeneralResponsePage *)page
                   forceLoad:(BOOL)forceLoad {
    NSParameterAssert(usersIDs);
    NSParameterAssert(page);
    
    NSDictionary *searchInfo =
    [self.usersMemoryStorage usersByExcludingUsersIDs:usersIDs];
    NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
    NSArray *notFoundIDs = searchInfo[QMUsersSearchKey.notFoundSearchValues];
    
    if (!forceLoad && notFoundIDs.count == 0) {
        
        return [BFTask taskWithResult:foundUsers];
    }
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        NSArray *searchableUsers = forceLoad ? usersIDs : notFoundIDs;
        
        [QBRequest usersWithIDs:searchableUsers
                           page:page
                   successBlock:^(QBResponse *response,
                                  QBGeneralResponsePage *page,
                                  NSArray *users)
         {
             NSArray<QBUUser *> *result =
             [self performUpdateWithLoadedUsers:users
                                     foundUsers:foundUsers
                                  wasLoadForced:forceLoad];
             [source setResult:result];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

//MARK: - Get user by External IDs

- (BFTask *)getUserWithExternalID:(NSUInteger)externalUserID {
    
    return [self getUserWithExternalID:externalUserID
                             forceLoad:NO];
}

- (BFTask *)getUserWithExternalID:(NSUInteger)externalUserID
                        forceLoad:(BOOL)forceLoad {
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        QBUUser *user =
        [self.usersMemoryStorage userWithExternalID:externalUserID];
        
        if (user != nil && !forceLoad) {
            [source setResult:user];
        }
        else {
            
            [QBRequest userWithExternalID:externalUserID
                             successBlock:^(QBResponse *response, QBUUser *user)
             {
                 [source setResult:user];
                 
             } errorBlock:^(QBResponse *response) {
                 
                 [source setError:response.error.error];
             }];
        }
    });
}

//MARK: - Get users by emails

- (BFTask *)getUsersWithEmails:(NSArray *)emails {
    
    return [self getUsersWithEmails:emails
                               page:[self pageForCount:emails.count]
                          forceLoad:NO];
}

- (BFTask *)getUsersWithEmails:(NSArray *)emails
                     forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithEmails:emails
                               page:[self pageForCount:emails.count]
                          forceLoad:forceLoad];
}

- (BFTask *)getUsersWithEmails:(NSArray *)emails
                          page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithEmails:emails
                               page:page
                          forceLoad:NO];
}

- (BFTask *)getUsersWithEmails:(NSArray *)emails
                          page:(QBGeneralResponsePage *)page
                     forceLoad:(BOOL)forceLoad {
    
    NSParameterAssert(emails);
    NSParameterAssert(page);
    
    NSDictionary *searchInfo =
    [self.usersMemoryStorage usersByExcludingEmails:emails];
    NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
    NSArray *notFoundEmails = searchInfo[QMUsersSearchKey.notFoundSearchValues];
    
    if (!forceLoad && notFoundEmails.count == 0) {
        
        return [BFTask taskWithResult:foundUsers];
    }
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        NSArray *searchableUsers = forceLoad ? emails : notFoundEmails;
        
        [QBRequest usersWithEmails:searchableUsers
                              page:page
                      successBlock:^(QBResponse *response,
                                     QBGeneralResponsePage *page,
                                     NSArray<QBUUser *> *users)
         {
             NSArray<QBUUser *> *result =
             [self performUpdateWithLoadedUsers:users
                                     foundUsers:foundUsers
                                  wasLoadForced:forceLoad];
             
             [source setResult:result];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
        
    });
}

//MARK: - Get users by Facebook IDs

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs {
    
    return [self getUsersWithFacebookIDs:facebookIDs
                                    page:[self pageForCount:facebookIDs.count]
                               forceLoad:NO];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs
                          forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithFacebookIDs:facebookIDs
                                    page:[self pageForCount:facebookIDs.count]
                               forceLoad:forceLoad];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs
                               page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithFacebookIDs:facebookIDs
                                    page:page
                               forceLoad:NO];
}

- (BFTask *)getUsersWithFacebookIDs:(NSArray *)facebookIDs
                               page:(QBGeneralResponsePage *)page
                          forceLoad:(BOOL)forceLoad {
    
    NSParameterAssert(facebookIDs);
    NSParameterAssert(page);
    
    NSDictionary *searchInfo =
    [self.usersMemoryStorage usersByExcludingFacebookIDs:facebookIDs];
    NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
    NSArray *notFoundFacebookIDs =
    searchInfo[QMUsersSearchKey.notFoundSearchValues];
    
    if (!forceLoad && notFoundFacebookIDs.count == 0) {
        
        return [BFTask taskWithResult:foundUsers];
    }
    
    NSArray *searchableUsers = forceLoad ? facebookIDs : notFoundFacebookIDs;
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithFacebookIDs:searchableUsers
                                   page:page
                           successBlock:^(QBResponse *response,
                                          QBGeneralResponsePage *page,
                                          NSArray *users)
         {
             NSArray<QBUUser *> *result =
             [self performUpdateWithLoadedUsers:users
                                     foundUsers:foundUsers
                                  wasLoadForced:forceLoad];
             
             [source setResult:result];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

//MARK: - Get users by Twitter IDs

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs {
    
    return [self getUsersWithTwitterIDs:twitterIDs
                                   page:[self pageForCount:twitterIDs.count]
                              forceLoad:NO];
}

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs
                         forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithTwitterIDs:twitterIDs
                                   page:[self pageForCount:twitterIDs.count]
                              forceLoad:forceLoad];
}

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs
                              page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithTwitterIDs:twitterIDs
                                   page:page
                              forceLoad:NO];
}

- (BFTask *)getUsersWithTwitterIDs:(NSArray *)twitterIDs
                              page:(QBGeneralResponsePage *)page
                         forceLoad:(BOOL)forceLoad {
    
    NSParameterAssert(twitterIDs);
    NSParameterAssert(page);
    
    NSDictionary *searchInfo =
    [self.usersMemoryStorage usersByExcludingTwitterIDs:twitterIDs];
    NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
    NSArray *notFoundTwitterIDs = searchInfo[QMUsersSearchKey.notFoundSearchValues];
    
    if (!forceLoad && notFoundTwitterIDs.count == 0) {
        
        return [BFTask taskWithResult:foundUsers];
    }
    
    NSArray *searchableUsers = forceLoad ? twitterIDs : notFoundTwitterIDs;
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithTwitterIDs:searchableUsers
                                  page:page
                          successBlock:^(QBResponse *response,
                                         QBGeneralResponsePage *page,
                                         NSArray *users)
         {
             NSArray<QBUUser *> *result =
             [self performUpdateWithLoadedUsers:users
                                     foundUsers:foundUsers
                                  wasLoadForced:forceLoad];
             
             [source setResult:result];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

//MARK: - Get users by Logins

- (BFTask *)getUsersWithLogins:(NSArray *)logins {
    
    return [self getUsersWithLogins:logins
                               page:[self pageForCount:logins.count]
                          forceLoad:NO];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins
                     forceLoad:(BOOL)forceLoad {
    
    return [self getUsersWithLogins:logins
                               page:[self pageForCount:logins.count]
                          forceLoad:forceLoad];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins
                          page:(QBGeneralResponsePage *)page {
    
    return [self getUsersWithLogins:logins
                               page:page
                          forceLoad:NO];
}

- (BFTask *)getUsersWithLogins:(NSArray *)logins
                          page:(QBGeneralResponsePage *)page
                     forceLoad:(BOOL)forceLoad {
    
    NSParameterAssert(logins);
    NSParameterAssert(page);
    
    NSDictionary *searchInfo = [self.usersMemoryStorage usersByExcludingLogins:logins];
    NSArray *foundUsers = searchInfo[QMUsersSearchKey.foundObjects];
    NSArray *notFoundLogins = searchInfo[QMUsersSearchKey.notFoundSearchValues];
    
    if (!forceLoad && notFoundLogins.count == 0) {
        return [BFTask taskWithResult:foundUsers];
    }
    
    NSArray *searchableUsers = forceLoad ? logins : notFoundLogins;
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithLogins:searchableUsers
                              page:page
                      successBlock:^(QBResponse *response,
                                     QBGeneralResponsePage *page,
                                     NSArray *users)
         {
             NSArray *result =
             [self performUpdateWithLoadedUsers:users
                                     foundUsers:foundUsers
                                  wasLoadForced:forceLoad];
             [source setResult:result];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

//MARK: - Search

- (BFTask *)searchUsersWithFullName:(NSString *)searchText {
    
    return [self searchUsersWithFullName:searchText
                                    page:[QBGeneralResponsePage responsePageWithCurrentPage:1
                                                                                    perPage:100]];
}

- (BFTask *)searchUsersWithFullName:(NSString *)searchText
                               page:(QBGeneralResponsePage *)page {
    
    NSParameterAssert(searchText);
    NSParameterAssert(page);
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithFullName:searchText
                                page:page
                        successBlock:^(QBResponse *response,
                                       QBGeneralResponsePage *page,
                                       NSArray *users)
         {
             [self.usersMemoryStorage addUsers:users];
             
             if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                 [self.multicastDelegate usersService:self didAddUsers:users];
             }
             
             [self notifyListenersAboutUsersUpdate:users];
             
             [source setResult:users];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)searchUsersWithTags:(NSArray *)tags {
    
    return [self searchUsersWithTags:tags
                                page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithTags:(NSArray *)tags page:(QBGeneralResponsePage *)page {
    
    NSParameterAssert(tags);
    NSParameterAssert(page);
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithTags:tags
                            page:page
                    successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users)
         {
             
             [self.usersMemoryStorage addUsers:users];
             
             if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                 [self.multicastDelegate usersService:self didAddUsers:users];
             }
             
             [self notifyListenersAboutUsersUpdate:users];
             
             [source setResult:users];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)searchUsersWithPhoneNumbers:(NSArray *)phoneNumbers {
    
    return [self searchUsersWithPhoneNumbers:phoneNumbers
                                        page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithPhoneNumbers:(NSArray *)phoneNumbers
                                   page:(QBGeneralResponsePage *)page {
    
    NSParameterAssert(phoneNumbers);
    NSParameterAssert(page);
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithPhoneNumbers:phoneNumbers
                                    page:page
                            successBlock:^(QBResponse *response,
                                           QBGeneralResponsePage *page,
                                           NSArray *users)
         {
             
             [self.usersMemoryStorage addUsers:users];
             
             if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                 [self.multicastDelegate usersService:self didAddUsers:users];
             }
             
             [self notifyListenersAboutUsersUpdate:users];
             
             [source setResult:users];
             
         } errorBlock:^(QBResponse *response) {
             
             [source setError:response.error.error];
         }];
    });
}

- (BFTask *)searchUsersWithExtendedRequest:(NSDictionary *)extendedRequest {
    return [self searchUsersWithExtendedRequest:extendedRequest
                                           page:[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:100]];
}

- (BFTask *)searchUsersWithExtendedRequest:(NSDictionary *)extendedRequest page:(QBGeneralResponsePage *)page {
    
    NSParameterAssert(extendedRequest);
    NSParameterAssert(page);
    
    return make_task(^(BFTaskCompletionSource * _Nonnull source) {
        
        [QBRequest usersWithExtendedRequest:extendedRequest
                                       page:page
                               successBlock:^(QBResponse * _Nonnull response, QBGeneralResponsePage * _Nullable page, NSArray<QBUUser *> * _Nullable users)
         {
             
             if (users.count > 0) {
                 [self.usersMemoryStorage addUsers:users];
                 
                 if ([self.multicastDelegate respondsToSelector:@selector(usersService:didAddUsers:)]) {
                     [self.multicastDelegate usersService:self didAddUsers:users];
                 }
                 
                 [self notifyListenersAboutUsersUpdate:users];
             }
             
             [source setResult:users];
             
         } errorBlock:^(QBResponse * _Nonnull response)
         {
             [source setError:response.error.error];
         }];
    });
}

// MARK: Public users management

- (void)updateUsers:(NSArray *)users {
    [self.usersMemoryStorage addUsers:users];
    [self notifyListenersAboutUsersUpdate:users];
    if ([self.multicastDelegate respondsToSelector:@selector(usersService:didUpdateUsers:)]) {
        [self.multicastDelegate usersService:self didUpdateUsers:users];
    }
}

//MARK: - Helpers

- (NSArray<QBUUser *> *)performUpdateWithLoadedUsers:(NSArray<QBUUser *> *)loadedUsers
                                          foundUsers:(NSArray<QBUUser *> *)foundUsers
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
            [self.multicastDelegate usersService:self didAddUsers:[mutableNewUsers copy]];
        }
        
        if (mutableUpdatedUsers.count > 0) {
            [self notifyListenersAboutUsersUpdate:mutableUpdatedUsers];
            if ([self.multicastDelegate respondsToSelector:@selector(usersService:didUpdateUsers:)]) {
                [self.multicastDelegate usersService:self didUpdateUsers:[mutableUpdatedUsers copy]];
            }
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

- (void)notifyListenersAboutUsersUpdate:(NSArray <QBUUser *> *)users {
    NSEnumerator *keyEnumerator = self.listeners.keyEnumerator;
    for (QBUUser *user in keyEnumerator) {
        if ([users containsObject:user]) {
            QBMulticastDelegate<QMUsersServiceListenerProtocol> *multicastDelegate = self.listeners[user];
            [multicastDelegate usersService:self didUpdateUser:[self.usersMemoryStorage userWithID:user.ID]];
        }
    }
}

- (QBGeneralResponsePage *)pageForCount:(NSUInteger)count {
    
    return [QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:count < 100 ? count : 100];
}

@end
