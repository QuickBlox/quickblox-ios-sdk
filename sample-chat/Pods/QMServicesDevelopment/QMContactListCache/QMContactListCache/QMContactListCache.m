//
//  QMContactListCache.m
//  QMServices
//
//  Created by Andrey on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMContactListCache.h"
#import "QMCLModelIncludes.h"
#import "CDContactListItem.h"
#import "CDUser.h"

@implementation QMContactListCache

static QMContactListCache *_chatCacheInstance = nil;

#pragma mark - Singleton

+ (QMContactListCache *)instance {
    
    NSAssert(_chatCacheInstance, @"You must first perform @selector(setupDBWithStoreNamed:)");
    return _chatCacheInstance;
}

#pragma mark - Configure store

+ (void)setupDBWithStoreNamed:(NSString *)storeName {
    
    NSManagedObjectModel *model =
    [NSManagedObjectModel QM_newModelNamed:@"QMContactListModel.momd"
                             inBundleNamed:@"QMContactListCacheModel.bundle"];
    
    _chatCacheInstance =
    [[QMContactListCache alloc] initWithStoreNamed:storeName
                                             model:model
                                        queueLabel:"com.qmunicate.QMContactListCacheBackgroundQueue"];
}

+ (void)cleanDBWithStoreName:(NSString *)name {
    
    if (_chatCacheInstance) {
        _chatCacheInstance = nil;
    }
    
    [super cleanDBWithStoreName:name];
}

#pragma mark -
#pragma mark Dialogs
#pragma mark -
#pragma mark Insert / Update / Delete contact items

- (void)insertOrUpdateContactListItem:(QBContactListItem *)contactListItem completion:(dispatch_block_t)completion {
    
    [self insertOrUpdateContactListWithItems:@[contactListItem] completion:completion];
}

- (void)insertOrUpdateContactListWithItems:(NSArray *)contactListItems completion:(dispatch_block_t)completion {
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        NSMutableArray *toInsert = [NSMutableArray array];
        NSMutableArray *toUpdate = [NSMutableArray array];
        
        //To Insert / Update
        for (QBContactListItem *contactListItem in contactListItems) {
            
            CDContactListItem *cachedContactListItem =
            [CDContactListItem QM_findFirstWithPredicate:IS(@"userID", @(contactListItem.userID)) inContext:context];
            if (cachedContactListItem) {
                
                if (![cachedContactListItem isEqualQBContactListItem:contactListItem]) {
                    [toUpdate addObject:contactListItem];
                }
            }
            else {
                
                [toInsert addObject:contactListItem];
            }
        }
        
        if (toUpdate.count > 0) {
            
            [weakSelf updateContactListItems:toUpdate inContext:context];
        }
        
        if (toInsert.count > 0) {
            
            [weakSelf insertContactListItems:toInsert inContext:context];
        }
        
        if (toInsert.count + toUpdate.count > 0) {
            [weakSelf save:completion];
        }
        
        NSLog(@"ContactListItems to insert %lu", (unsigned long)toInsert.count);
        NSLog(@"ContactListItems to update %lu", (unsigned long)toUpdate.count);
    }];
}

- (void)insertOrUpdateContactListItemsWithContactList:(QBContactList *)contactList completion:(dispatch_block_t)completion {
    NSMutableArray *items =
    [NSMutableArray arrayWithCapacity:contactList.contacts.count + contactList.pendingApproval.count];
    
    [items addObjectsFromArray:contactList.contacts];
    [items addObjectsFromArray:contactList.pendingApproval];
    
    [self insertOrUpdateContactListWithItems:items completion:completion];
}

- (void)insertContactListItems:(NSArray *)contactListItems inContext:(NSManagedObjectContext *)context {
    
    for (QBContactListItem *contactListItem in contactListItems) {
        
        CDContactListItem *cdContactListItem = [CDContactListItem QM_createEntityInContext:context];
        [cdContactListItem updateWithQBContactListItem:contactListItem];
    }
}

- (void)updateContactListItems:(NSArray *)contactListItems inContext:(NSManagedObjectContext *)context {
    
    for (QBContactListItem *contactListItem in contactListItems) {
        
        CDContactListItem *cachedContactListItem =
        [CDContactListItem QM_findFirstWithPredicate:IS(@"userID", @(contactListItem.userID)) inContext:context];
        [cachedContactListItem updateWithQBContactListItem:contactListItem];
    }
}

- (void)deleteContactListItem:(QBContactListItem *)contactListItem completion:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    
    [self async:^(NSManagedObjectContext *context) {
        
        CDContactListItem *cdContactListItem =
        [CDContactListItem QM_findFirstWithPredicate:IS(@"userID", @(contactListItem.userID)) inContext:context];
        
        [cdContactListItem QM_deleteEntityInContext:context];
        
        [weakSelf save:completion];
    }];
}

- (void)deleteContactList:(dispatch_block_t)completion {
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        [CDContactListItem QM_truncateAllInContext:context];
        [weakSelf save:completion];
    }];
}

#pragma mark Fetch ContactList operations

- (NSArray *)convertCDContactListItemsToQBContactListItems:(NSArray *)cdContactListItems {
    
    NSMutableArray *contactListItems = [NSMutableArray arrayWithCapacity:cdContactListItems.count];
    
    for (CDContactListItem *cachedContactListItem in cdContactListItems) {
        
        QBContactListItem *contactListItem = [cachedContactListItem toQBContactListItem];
        [contactListItems addObject:contactListItem];
    }
    
    return contactListItems;
}

- (void)contactListItems:(void(^)(NSArray *contactListItems))completion{
    
    __weak __typeof(self)weakSelf = self;
    [self async:^(NSManagedObjectContext *context) {
        
        NSArray *cachedContactListItems =
        [CDContactListItem QM_findAllInContext:context];
        
        NSArray *contactListItems =
        [weakSelf convertCDContactListItemsToQBContactListItems:cachedContactListItems];
        
        DO_AT_MAIN(completion(contactListItems));
    }];
}

- (void)contactListItemWithUserID:(NSUInteger)userID completion:(void(^)(QBContactListItem *))completion {
    
    [self async:^(NSManagedObjectContext *context) {
        
        CDContactListItem *cachedContactListItem =
        [CDContactListItem QM_findFirstWithPredicate:IS(@"userID", @(userID)) inContext:context];
        
        QBContactListItem *item = [cachedContactListItem toQBContactListItem];
        
        completion(item);
    }];
}

@end