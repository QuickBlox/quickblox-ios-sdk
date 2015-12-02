//
//  QMContactsService.m
//  QMServices
//
//  Created by Andrey Ivanov on 14/02/2014.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMContactListService.h"

@interface QMContactListService()

<QBChatDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QMContactListServiceDelegate> *multicastDelegate;
@property (weak, nonatomic) id<QMContactListServiceCacheDataSource> cacheDataSource;
@property (strong, nonatomic) QMContactListMemoryStorage *contactListMemoryStorage;

@end

@implementation QMContactListService

- (void)dealloc {
    
    NSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QBChat instance] removeDelegate:self];
    self.contactListMemoryStorage = nil;
}

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                         cacheDataSource:(id<QMContactListServiceCacheDataSource>)cacheDataSource {
    
    self = [super initWithServiceManager:serviceManager];
    if (self) {
        
        self.cacheDataSource = cacheDataSource;
        [self loadCachedData];
    }
    
    return self;
}

#pragma mark - Service will start

- (void)serviceWillStart {
    
    self.multicastDelegate = (id<QMContactListServiceDelegate>)[[QBMulticastDelegate alloc] init];
    self.contactListMemoryStorage = [[QMContactListMemoryStorage alloc] init];
    
    [[QBChat instance] addDelegate:self];
}

- (void)loadCachedData {
    
    __weak __typeof(self)weakSelf = self;
    
    dispatch_queue_t queue = dispatch_queue_create("com.qm.loadCacheQueue", DISPATCH_QUEUE_SERIAL);
    //Step 1. Load contact list (Roster)
    dispatch_async(queue, ^{
        
        if ([self.cacheDataSource respondsToSelector:@selector(cachedContactListItems:)]) {
            
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            
            [self.cacheDataSource cachedContactListItems:^(NSArray *collection) {
                
                [weakSelf.contactListMemoryStorage updateWithContactListItems:collection];
                dispatch_semaphore_signal(sem);
            }];
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
    });
    //Step 3. Notify about load cache
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([self.multicastDelegate respondsToSelector:@selector(contactListServiceDidLoadCache)]) {
                [self.multicastDelegate contactListServiceDidLoadCache];
            }
        });
    });
}

#pragma mark - Add Remove multicaste delegate

- (void)addDelegate:(id <QMContactListServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMContactListServiceDelegate>)delegate {
    
    [self.multicastDelegate removeDelegate:delegate];
}

#pragma mark - QBChatDelegate

- (void)chatContactListDidChange:(QBContactList *)contactList {
    
    [self.contactListMemoryStorage updateWithContactList:contactList];
    
    if ([self.multicastDelegate respondsToSelector:@selector(contactListService:contactListDidChange:)]) {
        [self.multicastDelegate contactListService:self contactListDidChange:contactList];
    }
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status {
    if ([self.multicastDelegate respondsToSelector:@selector(contactListService:didReceiveContactItemActivity:isOnline:status:)]) {
        [self.multicastDelegate contactListService:self didReceiveContactItemActivity:userID isOnline:isOnline status:status];
    }
}

#pragma mark - ContactList Request

- (void)addUserToContactListRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [[QBChat instance] addUserToContactListRequest:user.ID completion:^(NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        //
        if (!error) {
            if ([strongSelf.cacheDataSource respondsToSelector:@selector(contactListDidAddUser:)]) {
                [strongSelf.cacheDataSource contactListDidAddUser:user];
            }
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(NO);
            }
        }

    }];
}

- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] removeUserFromContactList:userID completion:^(NSError *error) {
        //
        if (!error) {
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(NO);
            }
        }
    }];
}

- (void)acceptContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {

    [[QBChat instance] confirmAddContactRequest:userID completion:^(NSError *error) {
        //
        if (!error) {
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(NO);
            }
        }
    }];
}

- (void)rejectContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] rejectAddContactRequest:userID completion:^(NSError *error) {
        //
        if (!error) {
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(NO);
            }
        }
    }];
}

#pragma mark - QMUsersMemoryStorageDelegate

- (NSArray *)contactsIDS {
    
    return [self.contactListMemoryStorage userIDsFromContactList];
}

#pragma QMMemoryStorageProtocol

- (void)free {
    
    [self.contactListMemoryStorage free];
}

@end
