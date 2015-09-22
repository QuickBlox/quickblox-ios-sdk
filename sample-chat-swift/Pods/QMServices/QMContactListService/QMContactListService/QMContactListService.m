//
//  QMContactsService.m
//  QMServices
//
//  Created by Andrey Ivanov on 14/02/2014.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "QMContactListService.h"

@interface QMContactListService()

<QBChatDelegate, QMUsersMemoryStorageDelegate>

@property (strong, nonatomic) QBMulticastDelegate <QMContactListServiceDelegate> *multicastDelegate;
@property (weak, nonatomic) id<QMContactListServiceCacheDataSource> cacheDataSource;
@property (strong, nonatomic) QMContactListMemoryStorage *contactListMemoryStorage;
@property (strong, nonatomic) QMUsersMemoryStorage *usersMemoryStorage;

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
    self.usersMemoryStorage = [[QMUsersMemoryStorage alloc] init];
    self.usersMemoryStorage.delegate = self;
    
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
    //Step 2. Load users for conatc list
    dispatch_async(queue, ^{
        
        if ([self.cacheDataSource respondsToSelector:@selector(cachedUsers:)]) {
            
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            
            [self.cacheDataSource cachedUsers:^(NSArray *collection) {
                
                [weakSelf.usersMemoryStorage addUsers:collection];
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
    
    __weak __typeof(self)weakSelf = self;
    
    [self retrieveUsersWithIDs:[self.contactListMemoryStorage userIDsFromContactList]
				 forceDownload:NO completion:^(QBResponse *responce, QBGeneralResponsePage *page, NSArray *users)
     {
         if (responce.success) {
             
             if ([weakSelf.multicastDelegate respondsToSelector:@selector(contactListService:contactListDidChange:)]) {
                 [weakSelf.multicastDelegate contactListService:self contactListDidChange:contactList];
             }
         }
     }];
}

#pragma mark - Retrive users

- (void)retrieveUsersWithIDs:(NSArray *)ids forceDownload:(BOOL)forceDownload completion:(void(^)(QBResponse *response, QBGeneralResponsePage *page, NSArray * users))completion {
	
	if (ids.count == 0) {
		if (completion) {
			completion(nil, nil, @[]);
		}
		return;
	}

	if (!forceDownload) {
		// if all users with given ids in cache, return them
		if ([[self.usersMemoryStorage usersWithIDs:ids] count] == [ids count]) {
			if (completion) {
				completion(nil, nil, [self.usersMemoryStorage usersWithIDs:ids]);
			}
			return;
		}
	}
	
	NSSet *usersIDs = [NSSet setWithArray:ids];
	
	QBGeneralResponsePage *pageResponse =
	[QBGeneralResponsePage responsePageWithCurrentPage:1 perPage:usersIDs.count < 100 ? usersIDs.count : 100];
	
	__weak __typeof(self)weakSelf = self;
	[QBRequest usersWithIDs:usersIDs.allObjects  page:pageResponse successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray * users) {
		
		// remove already downloaded users from adding to memory storage
		NSMutableArray *mutableUsers = [users mutableCopy];
		for (int i = 0; i < mutableUsers.count; i++ ) {
			QBUUser *user = mutableUsers[i];
			if ([weakSelf.usersMemoryStorage userWithID:user.ID] != nil ) {
				[mutableUsers removeObjectAtIndex:i];
			}
		}
		
		[weakSelf.usersMemoryStorage addUsers:[mutableUsers copy]];
		
		if ([weakSelf.multicastDelegate respondsToSelector:@selector(contactListService:didAddUsers:)]) {
			[weakSelf.multicastDelegate contactListService:weakSelf didAddUsers:users];
		}
		
		if (completion) {
			completion(response, page, users);
		}
		
	} errorBlock:^(QBResponse *response) {
		
		completion(response, nil, nil);
	}];
	
}

#pragma mark - ContactList Request

- (void)addUserToContactListRequest:(QBUUser *)user completion:(void(^)(BOOL success))completion {
    
    __weak __typeof(self)weakSelf = self;
    [[QBChat instance] addUserToContactListRequest:user.ID sentBlock:^(NSError *error) {
        
        if (!error) {
            
            [weakSelf.usersMemoryStorage addUser:user];
            
            if ([weakSelf.multicastDelegate respondsToSelector:@selector(contactListService:didAddUser:)]) {
                [weakSelf.multicastDelegate contactListService:weakSelf didAddUser:user];
            }
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(YES);
            }
        }
    }];
}

- (void)removeUserFromContactListWithUserID:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] removeUserFromContactList:userID sentBlock:^(NSError *error) {
        
        if (!error) {
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(YES);
            }
        }
    }];
}

- (void)acceptContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] confirmAddContactRequest:userID sentBlock:^(NSError *error) {
        
        if (!error) {
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(YES);
            }
        }
    }];
}

- (void)rejectContactRequest:(NSUInteger)userID completion:(void(^)(BOOL success))completion {
    
    [[QBChat instance] rejectAddContactRequest:userID sentBlock:^(NSError *error) {
        
        if (!error) {
            
            if (completion) {
                completion(YES);
            }
            
        } else {
            
            if (completion) {
                completion(YES);
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
    [self.usersMemoryStorage free];
}

@end
