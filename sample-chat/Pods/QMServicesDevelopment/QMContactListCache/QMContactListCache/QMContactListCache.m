//
//  QMContactListCache.m
//  QMServices
//
//  Created by Andrey on 06.11.14.
//  Copyright (c) 2015 Quickblox Team. All rights reserved.
//

#import "QMContactListCache.h"
#import "QMContactListModelIncludes.h"
#import "CDContactListItem.h"
#import "CDUser.h"

#import "QMSLog.h"

@implementation QMContactListCache

static QMContactListCache *_contactListcCacheInstance = nil;

//MARK: - Singleton

+ (QMContactListCache *)instance {
    
    NSAssert(_contactListcCacheInstance, @"You must first perform @selector(setupDBWithStoreNamed:)");
    return _contactListcCacheInstance;
}

//MARK: - Configure store

+ (void)setupDBWithStoreNamed:(NSString *)storeName {
    
    [self setupDBWithStoreNamed:storeName
     applicationGroupIdentifier:nil];
}

+ (void)setupDBWithStoreNamed:(NSString *)storeName
   applicationGroupIdentifier:(NSString *)appGroupIdentifier {
    
    NSManagedObjectModel *model =
    [NSManagedObjectModel QM_newModelNamed:@"QMContactListModel.momd"
                             inBundleNamed:@"QMContactListCacheModel.bundle"
                                 fromClass:[self class]];
    
    _contactListcCacheInstance =
    [[QMContactListCache alloc] initWithStoreNamed:storeName
                                             model:model
                        applicationGroupIdentifier:appGroupIdentifier];
}

+ (void)cleanDBWithStoreName:(NSString *)name {
    
    if (_contactListcCacheInstance) {
        _contactListcCacheInstance = nil;
    }
    
    [super cleanDBWithStoreName:name];
}

//MARK: Dialogs
//MARK: Insert / Update / Delete contact items

- (void)insertOrUpdateContactListItem:(QBContactListItem *)contactListItem
                           completion:(dispatch_block_t)completion {
    
    [self save:^(NSManagedObjectContext *ctx) {
        
        CDContactListItem *item =
        [CDContactListItem QM_findFirstOrCreateByAttribute:@"userID"
                                                 withValue:@(contactListItem.userID)
                                                 inContext:ctx];
        [item updateWithQBContactListItem:contactListItem];
        
    } finish:completion];
}

- (void)insertOrUpdateContactListWithItems:(NSArray<QBContactListItem *> *)contactListItems
                                completion:(dispatch_block_t)completion {

    [self insertOrUpdateContactListWithItems:contactListItems completion:completion force:NO];
}

- (void)insertOrUpdateContactListWithItems:(NSArray<QBContactListItem *> *)contactListItems
                                completion:(dispatch_block_t)completion
                                     force:(BOOL)force {
    
    [self save:^(NSManagedObjectContext *ctx) {
        
        if (force) {
            [CDContactListItem QM_truncateAllInContext:ctx];
        }
        
        for (QBContactListItem *contactListItem in contactListItems) {
            
            CDContactListItem *item =
            [CDContactListItem QM_findFirstOrCreateByAttribute:@"userID"
                                                     withValue:@(contactListItem.userID)
                                                     inContext:ctx];
            [item updateWithQBContactListItem:contactListItem];
        }
        
    } finish:completion];
}

- (void)insertOrUpdateContactListItemsWithContactList:(QBContactList *)contactList
                                           completion:(dispatch_block_t)completion {
    
    NSMutableArray *items =
    [NSMutableArray arrayWithCapacity:contactList.contacts.count + contactList.pendingApproval.count];
    
    [items addObjectsFromArray:contactList.contacts];
    [items addObjectsFromArray:contactList.pendingApproval];
    
    [self insertOrUpdateContactListWithItems:[items copy]
                                  completion:completion
                                       force:YES];
}

- (void)deleteContactListItem:(QBContactListItem *)contactListItem
                   completion:(dispatch_block_t)completion {
    
    [self save:^(NSManagedObjectContext *ctx) {
        [CDContactListItem QM_deleteAllMatchingPredicate:IS(@"userID", @(contactListItem.userID))
                                               inContext:ctx];
    } finish:completion];
}

- (void)deleteContactList:(dispatch_block_t)completion {
    
    [self save:^(NSManagedObjectContext *ctx) {
        [CDContactListItem QM_truncateAllInContext:ctx];
    } finish:completion];
}

- (void)truncateAll {
    [self performMainQueue:^(NSManagedObjectContext *ctx) {
        [CDContactListItem QM_truncateAllInContext:ctx];
        [ctx QM_saveToPersistentStoreAndWait];
    }];
}

- (NSArray<QBContactListItem *> *)allContactListItems {
    
    __block NSArray<QBContactListItem *> *result = nil;
    [self performMainQueue:^(NSManagedObjectContext *ctx) {
        result = [[CDContactListItem QM_findAllInContext:ctx] toQBContactListItems];
    }];
    
    return result;
}

- (void)contactListItems:(void(^)(NSArray<QBContactListItem *> *contactListItems))completion {
    
    [self performBackgroundQueue:^(NSManagedObjectContext *ctx) {

        NSArray<QBContactListItem *> *result =
        [[CDContactListItem QM_findAllInContext:ctx] toQBContactListItems];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    }];
}

- (void)contactListItemWithUserID:(NSUInteger)userID completion:(void(^)(QBContactListItem *))completion {
    
    [self performBackgroundQueue:^(NSManagedObjectContext *ctx) {
        
        QBContactListItem *result =
        [[CDContactListItem QM_findFirstWithPredicate:IS(@"userID", @(userID))
                                           inContext:ctx] toQBContactListItem];
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result);
            });
        }
    }];
}

@end
