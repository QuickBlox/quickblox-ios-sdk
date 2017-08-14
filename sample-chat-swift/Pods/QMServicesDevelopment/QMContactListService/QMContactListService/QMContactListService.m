//
//  QMContactsService.m
//  QMServices
//
//  Created by Andrey Ivanov on 14/02/2014.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMContactListService.h"

#import "QMSLog.h"

static inline BOOL isContactListEmpty(QBContactList *contactList) {
    
    return (contactList == nil || (contactList.contacts.count == 0 && contactList.pendingApproval.count == 0));
}

@interface QMContactListService()

<QBChatDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QMContactListServiceDelegate> *multicastDelegate;
@property (weak, nonatomic) id<QMContactListServiceCacheDataSource> cacheDataSource;
@property (strong, nonatomic) QMContactListMemoryStorage *contactListMemoryStorage;

@end

@implementation QMContactListService

- (void)dealloc {
    
    QMSLog(@"%@ - %@",  NSStringFromSelector(_cmd), self);
    [[QBChat instance] removeDelegate:self];
    self.contactListMemoryStorage = nil;
}

- (instancetype)initWithServiceManager:(id<QMServiceManagerProtocol>)serviceManager
                       cacheDataSource:(id<QMContactListServiceCacheDataSource>)cacheDataSource {
    
    self = [super initWithServiceManager:serviceManager];
    if (self) {
        
        _cacheDataSource = cacheDataSource;
        [self loadCachedData];
    }
    
    return self;
}

//MARK: - Service will start

- (void)serviceWillStart {
    
    self.multicastDelegate = (id<QMContactListServiceDelegate>)[[QBMulticastDelegate alloc] init];
    self.contactListMemoryStorage = [[QMContactListMemoryStorage alloc] init];
    
    [[QBChat instance] addDelegate:self];
}

- (void)loadCachedData {
    
    __weak __typeof(self)weakSelf = self;
    
    if ([self.cacheDataSource respondsToSelector:@selector(cachedContactListItems:)]) {
        
        
        [self.cacheDataSource cachedContactListItems:^(NSArray *collection) {
            
            [weakSelf.contactListMemoryStorage updateWithContactListItems:collection];
        }];
    }
    
    
    if ([self.multicastDelegate respondsToSelector:@selector(contactListServiceDidLoadCache)]) {
        [self.multicastDelegate contactListServiceDidLoadCache];
    }
}

//MARK: - Add Remove multicaste delegate

- (void)addDelegate:(id <QMContactListServiceDelegate>)delegate {
    
    [self.multicastDelegate addDelegate:delegate];
}

- (void)removeDelegate:(id <QMContactListServiceDelegate>)delegate {
    
    [self.multicastDelegate removeDelegate:delegate];
}

//MARK: - QBChatDelegate

- (void)chatContactListDidChange:(QBContactList *)contactList {
    
    if (isContactListEmpty(contactList)
        && ![QBChat instance].isConnected) {
        // no need to erase contact list cache due to chat
        // disconnect triggers nil contact list change
        return;
    }
    
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

//MARK: - ContactList Request

- (void)addUserToContactListRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [[QBChat instance] addUserToContactListRequest:user.ID completion:^(NSError *error) {
        __typeof(self) strongSelf = weakSelf;
        
        if (error == nil) {
            
            if ([strongSelf.cacheDataSource respondsToSelector:@selector(contactListDidAddUser:)]) {
                [strongSelf.cacheDataSource contactListDidAddUser:user];
            }
            
            if (completion) {
                
                completion(YES);
            }
        }
        else {
            
            if (completion) {
                
                completion(NO);
            }
        }
    }];
}

- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] removeUserFromContactList:userID completion:^(NSError *error) {
        
        if (completion) {
            completion(error == nil);
        }
    }];
}

- (void)acceptContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] confirmAddContactRequest:userID completion:^(NSError *error) {
        
        if (completion) {
            completion(error == nil);
        }
    }];
}

- (void)rejectContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] rejectAddContactRequest:userID completion:^(NSError *error) {
        
        if (completion) {
            completion(error == nil);
        }
    }];
}

//MARK: - QMUsersMemoryStorageDelegate

- (NSArray *)contactsIDS {
    
    return [self.contactListMemoryStorage userIDsFromContactList];
}

#pragma QMMemoryStorageProtocol

- (void)free {
    
    [self.contactListMemoryStorage free];
}

@end
