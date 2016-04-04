//
//  STKStickersDataModel.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersCache.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "NSManagedObject+STKAdditions.h"
#import "STKStickerPack.h"
#import "STKStickerObject.h"
#import "STKStickerPackObject.h"
#import "STKSticker.h"
#import "STKAnalyticService.h"
#import "STKUtility.h"
#import "STKStickersConstants.h"

static NSString *const recentName = @"Recent";

@implementation STKStickersCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdateStorage:) name:NSManagedObjectContextDidSaveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didUpdateStorage:(NSNotification*) notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:STKStickersCacheDidUpdateStickersNotification object:nil];
    });

}

#pragma mark - Saving

- (NSError *)saveStickerPacks:(NSArray *)stickerPacks  {
    __weak typeof(self) weakSelf = self;
    __block NSError *error;
    [self.backgroundContext performBlockAndWait:^{
        NSArray *packIDs = [stickerPacks valueForKeyPath:@"@unionOfObjects.packID"];
        
        NSFetchRequest *requestForDelete = [NSFetchRequest fetchRequestWithEntityName:[STKStickerPack entityName]];
        requestForDelete.predicate = [NSPredicate predicateWithFormat:@"NOT (%K in %@)", STKStickerPackAttributes.packID, packIDs];
        
        NSArray *objectsForDelete = [weakSelf.backgroundContext executeFetchRequest:requestForDelete error:nil];
        
        for (STKStickerPack *pack in objectsForDelete) {
            [weakSelf.backgroundContext deleteObject:pack];
        }
        for (STKStickerPackObject *object in stickerPacks) {
            STKStickerPack *stickerPack = [weakSelf stickerPackModelWithID:object.packID context:weakSelf.backgroundContext];
            [weakSelf fillStickerPack:stickerPack withObject:object];
            
        }
        [weakSelf.backgroundContext save:&error];
    }];
    return error;
}

- (void)saveStickerPack:(STKStickerPackObject *)stickerPack {
    
    STKStickerPack *stickerModel = [self stickerModelFormStickerObject:stickerPack context:self.backgroundContext];
    stickerModel.isNew = @YES;
    for (STKStickerObject *stickerObject in stickerPack.stickers) {
        STKSticker *sticker = [self stickerModelWithID:stickerObject.stickerID context:self.backgroundContext];
        sticker.stickerName = stickerObject.stickerName;
        sticker.stickerID = stickerObject.stickerID;
        sticker.stickerMessage = stickerObject.stickerMessage;
        sticker.usedCount = stickerObject.usedCount;
        sticker.usedDate = stickerObject.usedDate;
        if (sticker) {
            [stickerModel addStickersObject:sticker];
        }
    }
    
    [self.backgroundContext save:nil];
    
}

- (void)saveDisabledStickerPack:(STKStickerPackObject *)stickerPack {

    STKStickerPack *stickerModel = [self stickerModelFormStickerObject:stickerPack context:self.backgroundContext];
    stickerModel.disabled = @(YES);

    for (STKStickerObject *stickerObject in stickerPack.stickers) {
        STKSticker *sticker = [self stickerModelWithID:stickerObject.stickerID context:self.backgroundContext];
        sticker.stickerName = stickerObject.stickerName;
        sticker.stickerID = stickerObject.stickerID;
        sticker.stickerMessage = stickerObject.stickerMessage;
        sticker.usedCount = stickerObject.usedCount;
        sticker.usedDate = stickerObject.usedDate;
        sticker.packName = stickerObject.packName;
        if (sticker) {
            [stickerModel addStickersObject:sticker];
        }
    }

    [self.backgroundContext save:nil];
}

#pragma mark - Update

- (void)updateStickerPack:(STKStickerPackObject *)stickerPackObject {
    
    __weak typeof(self) weakSelf = self;
    
    [self.backgroundContext performBlock:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",STKStickerPackAttributes.packID, stickerPackObject.packID];
        NSArray *packs = [STKStickerPack stk_findWithPredicate:predicate sortDescriptors:nil fetchLimit:1 context:weakSelf.backgroundContext];
        STKStickerPack *stickerPack = packs.firstObject;
        if (stickerPack) {
            [weakSelf fillStickerPack:stickerPack withObject:stickerPackObject];
            
            NSError *error = nil;
            [weakSelf.backgroundContext save:&error];
            if (error) {
                STKLog(@"Saving context error: %@", error.localizedDescription);
            }
        }
    }];
}

#pragma mark - Delete

//- (void)deleteStickerPacks:(NSArray *)stickerPacks {
//    
//    __weak typeof(self) weakSelf = self;
//    
//    [self.mainContext performBlockAndWait:^{
//        NSArray *packIDs = [stickerPacks valueForKeyPath:@"@unionOfObjects.packID"];
//        
//        NSFetchRequest *requestForDelete = [NSFetchRequest fetchRequestWithEntityName:[STKStickerPack entityName]];
//        requestForDelete.predicate = [NSPredicate predicateWithFormat:@"%K in %@", STKStickerPackAttributes.packID, packIDs];
//        
//        NSArray *objectsForDelete = [weakSelf.mainContext executeFetchRequest:requestForDelete error:nil];
//        
//        for (STKStickerPack *pack in objectsForDelete) {
//            [weakSelf.mainContext deleteObject:pack];
//        }
//        [weakSelf.mainContext save:nil];
//    }];
//    
//}


#pragma mark - FillItems

- (STKStickerPack*)fillStickerPack:(STKStickerPack *)stickerPack withObject:(STKStickerPackObject*)stickerPackObject {
    stickerPack.artist = stickerPackObject.artist;
    stickerPack.packName = stickerPackObject.packName;
    stickerPack.packID = stickerPackObject.packID;
    stickerPack.price = stickerPackObject.price;
    stickerPack.pricePoint = stickerPackObject.pricePoint;
    stickerPack.packTitle = stickerPackObject.packTitle;
    stickerPack.packDescription = stickerPackObject.packDescription;
    stickerPack.bannerUrl = stickerPackObject.bannerUrl;
    stickerPack.productID = stickerPackObject.productID;
    stickerPack.disabled = stickerPackObject.disabled;

    if (stickerPack.isNew.boolValue == YES) {
        if (stickerPackObject.isNew) {
            stickerPack.isNew = stickerPackObject.isNew;
        }
    } else if (!stickerPack.isNew) {
        stickerPack.isNew = @YES;
    }


    if (stickerPackObject.order) {
        stickerPack.order = stickerPackObject.order;
    }

    for (STKStickerObject *stickerObject in stickerPackObject.stickers) {
        STKSticker *sticker = [self stickerModelWithID:stickerObject.stickerID context:self.backgroundContext];
        sticker.stickerName = stickerObject.stickerName;
        sticker.stickerID = stickerObject.stickerID;
        sticker.stickerMessage = stickerObject.stickerMessage;
        sticker.usedCount = stickerObject.usedCount;
        sticker.usedDate = stickerObject.usedDate;
        sticker.packName = stickerObject.packName;
        if (sticker) {
            [stickerPack addStickersObject:sticker];
        }
    }
    return stickerPack;
}

#pragma mark - NewItems

- (STKStickerPack*)stickerModelFormStickerObject:(STKStickerPackObject*)stickerPackObject
                                         context:(NSManagedObjectContext*)context {
    
    STKStickerPack *stickerPack = [self stickerPackModelWithID:stickerPackObject.packID context:context];
    stickerPack.artist = stickerPackObject.artist;
    stickerPack.packName = stickerPackObject.packName;
    stickerPack.packID = stickerPackObject.packID;
    stickerPack.price = stickerPackObject.price;
    stickerPack.pricePoint = stickerPackObject.pricePoint;
    stickerPack.packTitle = stickerPackObject.packTitle;
    stickerPack.packDescription = stickerPackObject.packDescription;
    stickerPack.disabled = stickerPackObject.disabled;
    stickerPack.isNew = stickerPackObject.isNew;
    stickerPack.bannerUrl = stickerPackObject.bannerUrl;
    stickerPack.productID = stickerPackObject.productID;
    stickerPack.order = stickerPackObject.order;
    return stickerPack;
}


- (STKSticker*)stickerModelWithID:(NSNumber*)stickerID context:(NSManagedObjectContext*)context
{
    STKSticker *sticker = [STKSticker stk_objectWithUniqueAttribute:STKStickerAttributes.stickerID value:stickerID context:context];
    return sticker;
}

- (STKStickerPack*)stickerPackModelWithID:(NSNumber*)packID context:(NSManagedObjectContext*)context
{
    STKStickerPack *stickerPack = [STKStickerPack stk_objectWithUniqueAttribute:STKStickerPackAttributes.packID value:packID context:context];
    return stickerPack;
}

#pragma mark - Getters

- (void)getStickerPacksIgnoringRecentForContext:(NSManagedObjectContext *)context
                                       response:(void (^)(NSArray *))response {
    
    if (context) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ OR %K == nil", STKStickerPackAttributes.disabled, @NO, STKStickerPackAttributes.disabled];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:STKStickerPackAttributes.order ascending:YES];
        NSArray *stickerPacks = [STKStickerPack stk_findWithPredicate:predicate sortDescriptors:@[sortDescriptor] context:context];
        
        NSMutableArray *result = [NSMutableArray array];
        
        for (STKStickerPack *pack in stickerPacks) {
            STKStickerPackObject *stickerPackObject = [[STKStickerPackObject alloc] initWithStickerPack:pack];
            if (stickerPackObject) {
                [result addObject:stickerPackObject];
            }
        }
        if (response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                response(result);
            });
            
        }

    }
}

- (void)getAllPacksIgnoringRecent:(void (^)(NSArray *))response {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K != nil", STKStickerPackAttributes.disabled];
    
    NSArray *stickerPacks = [STKStickerPack stk_findWithPredicate:predicate sortDescriptors:nil context:self.mainContext];
    NSMutableArray *result = [NSMutableArray array];
    
    for (STKStickerPack *pack in stickerPacks) {
        STKStickerPackObject *stickerPackObject = [[STKStickerPackObject alloc] initWithStickerPack:pack];
        if (stickerPackObject) {
            [result addObject:stickerPackObject];
        }
    }
    if (response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            response(result);
        });
    }
    
}

- (void)getStickerPacks:(void(^)(NSArray *stickerPacks))response {
    
    __weak typeof(self) weakSelf = self;
    
    STKStickerPackObject *recentPack = [weakSelf recentStickerPack];
    
    NSMutableArray *result = [NSMutableArray array];
#warning Check recent stickers
    [weakSelf getStickerPacksIgnoringRecentForContext:self.mainContext response:^(NSArray *stickerPacks) {
        
        if (recentPack) {
            [result insertObject:recentPack atIndex:0];
            [result addObjectsFromArray:stickerPacks];
        }
        if (response) {
            response(result);
        }
        
    }];

}

- (STKStickerPackObject *)getStickerPackWithPackName:(NSString *)packName {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", STKStickerPackAttributes.packName, packName];

    STKStickerPack *stickerPack = [[STKStickerPack stk_findWithPredicate:predicate sortDescriptors:nil fetchLimit:1 context:self.mainContext] firstObject];
    if (stickerPack) {
        STKStickerPackObject *object = [[STKStickerPackObject alloc] initWithStickerPack:stickerPack];
        return object;
    } else {
        return nil;
    }
}


- (STKStickerPackObject*)recentStickerPack {
    
//     __block STKStickerPackObject *object = nil;
//    [self.mainContext performBlock:^{
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > 0 AND (%K.%K == NO OR %K.%K == nil)", STKStickerAttributes.usedCount, STKStickerRelationships.stickerPack, STKStickerPackAttributes.disabled,STKStickerRelationships.stickerPack, STKStickerPackAttributes.disabled];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedDate
                                                                         ascending:NO];
        
        NSArray *stickers = [STKSticker stk_findWithPredicate:predicate
                                              sortDescriptors:@[sortDescriptor]
                                                   fetchLimit:12
                                                      context:self.mainContext];
        
            STKStickerPackObject *recentPack = [STKStickerPackObject new];
            recentPack.packName = recentName;
            recentPack.packTitle = recentName;
            recentPack.isNew = @NO;
            NSMutableArray *stickerObjects = [NSMutableArray new];
            for (STKSticker *sticker in stickers) {
                STKStickerObject *stickerObject = [[STKStickerObject alloc] initWithSticker:sticker];
                if (stickerObject) {
                    [stickerObjects addObject:stickerObject];

                }
            }
//            NSArray *sortedRecentStickers = [stickerObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedCount ascending:NO]]];
    NSArray *sortedRecentStickers = [stickerObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedDate ascending:NO]]];

    recentPack.stickers = [NSMutableArray arrayWithArray:sortedRecentStickers];
            
//            object = recentPack;
//    }];

    
    return recentPack;
}

- (NSString *)packNameForStickerId:(NSString *)stickerId {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", STKStickerAttributes.stickerID, stickerId];
    STKSticker *sticker = [[STKSticker stk_findWithPredicate:predicate sortDescriptors:nil fetchLimit:1 context:self.mainContext] firstObject];

    return sticker.packName;
}

#pragma mark - Change


- (void)markStickerPack:(STKStickerPackObject *)pack disabled:(BOOL)disabled {

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", STKStickerPackAttributes.packID, pack.packID];
    STKStickerPack *stickerPack = [STKStickerPack stk_findWithPredicate:predicate sortDescriptors:nil fetchLimit:1 context:self.mainContext].firstObject;

    stickerPack.disabled = @(disabled);

    [self.mainContext save:nil];
}

- (void)incrementUsedCountWithStickerID:(NSNumber *)stickerID {
    
        __weak typeof(self) weakSelf = self;
    [self.backgroundContext performBlock:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",STKStickerAttributes.stickerID , stickerID];
        NSArray *stickers = [STKSticker stk_findWithPredicate:predicate sortDescriptors:nil fetchLimit:1 context:self.backgroundContext];
        STKSticker *sticker = stickers.firstObject;
//        NSArray *trimmedPackNameAndStickerName = [STKUtility trimmedPackNameAndStickerNameWithMessage:sticker.stickerMessage];

        NSInteger usedCount = [sticker.usedCount integerValue];
        usedCount++;
        sticker.usedCount = @(usedCount);
        sticker.usedDate = [NSDate date];
        
        [[STKAnalyticService sharedService] sendEventWithCategory:STKAnalyticStickerCategory action:sticker.packName label:sticker.stickerName value:nil];
        
        [weakSelf.backgroundContext save:nil];
        
    }];
}

#pragma mark - Check

- (BOOL)hasNewStickerPacks {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[STKStickerPack entityName]];
    NSUInteger allRecordsCount = [[NSManagedObjectContext stk_defaultContext] countForFetchRequest:request error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", STKStickerPackAttributes.isNew, @YES];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:STKStickerPackAttributes.order ascending:NO];
    request.predicate = predicate;
    request.sortDescriptors = @[sortDescriptor];
    request.fetchOffset = allRecordsCount - 3;
    request.fetchLimit = 3;
    NSUInteger count = [[NSManagedObjectContext stk_defaultContext] countForFetchRequest:request error:nil];
    NSUInteger recentCount = [self recentStickerPack].stickers.count;
    return count > 0 || recentCount == 0;
}

- (BOOL)isStickerPackDownloaded:(NSString*)packName {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND (%K == NO OR %K == nil)", STKStickerPackAttributes.packName, packName, STKStickerPackAttributes.disabled, STKStickerPackAttributes.disabled];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[STKStickerPack entityName]];
    request.predicate = predicate;
    request.fetchLimit = 1;
    NSInteger count = [self.mainContext countForFetchRequest:request error:nil];
    BOOL downloaded = count > 0;
    return downloaded;
}

- (BOOL)hasPackWithName:(NSString *)packName {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[STKStickerPack entityName]];
        NSUInteger allRecordsCount = [[NSManagedObjectContext stk_defaultContext] countForFetchRequest:request error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", STKStickerPackAttributes.packName, packName];

    request.predicate = predicate;
//    request.fetchLimit = 1;
    NSUInteger count = [self.mainContext countForFetchRequest:request error:nil];
    return count > 0;
}

#pragma mark - Properties

- (NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        _mainContext = [NSManagedObjectContext stk_defaultContext];
    }
    return _mainContext;
}

- (NSManagedObjectContext *)backgroundContext {
    if (!_backgroundContext) {
        _backgroundContext = [NSManagedObjectContext stk_backgroundContext];
    }
    return _backgroundContext;
}

@end
