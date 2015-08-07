//
//  STKStickersDataModel.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersCache.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+STKAdditions.h"
#import "NSManagedObject+STKAdditions.h"
#import "STKStickerPack.h"
#import "STKStickerObject.h"
#import "STKStickerPackObject.h"
#import "STKSticker.h"
#import "STKAnalyticService.h"
#import "STKUtility.h"

@interface STKStickersCache()

@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;

@end

@implementation STKStickersCache

- (void) saveStickerPacks:(NSArray *)stickerPacks {
    
    __weak typeof(self) weakSelf = self;
    
    [self.backgroundContext performBlock:^{
        NSArray *packIDs = [stickerPacks valueForKeyPath:@"@unionOfObjects.packID"];
        
        NSFetchRequest *requestForDelete = [NSFetchRequest fetchRequestWithEntityName:[STKStickerPack entityName]];
        requestForDelete.predicate = [NSPredicate predicateWithFormat:@"NOT (%K in %@)", STKStickerPackAttributes.packID, packIDs];
        
        NSArray *objectsForDelete = [weakSelf.backgroundContext executeFetchRequest:requestForDelete error:nil];
        
        for (STKStickerPack *pack in objectsForDelete) {
            [self.backgroundContext deleteObject:pack];
        }
        for (STKStickerPackObject *object in stickerPacks) {
            STKStickerPack *stickerPack = [weakSelf stickerPackModelWithID:object.packID];
            stickerPack.artist = object.artist;
            stickerPack.packName = object.packName;
            stickerPack.packID = object.packID;
            stickerPack.price = object.price;
            
            for (STKStickerObject *stickerObject in object.stickers) {
                STKSticker *sticker = [self stickerModelWithID:stickerObject.stickerID];
                sticker.stickerName = stickerObject.stickerName;
                sticker.stickerID = stickerObject.stickerID;
                sticker.stickerMessage = stickerObject.stickerMessage;
                sticker.usedCount = stickerObject.usedCount;
                if (sticker) {
                    [stickerPack addStickersObject:sticker];
                }
            }
            
        }
        [weakSelf.backgroundContext save:nil];
    }];
}

#pragma mark Serialization


#pragma mark - NewItems

- (STKSticker*)stickerModelWithID:(NSNumber*) stickerID {
    STKSticker *sticker = [STKSticker stk_objectWithUniqueAttribute:STKStickerAttributes.stickerID value:stickerID context:self.backgroundContext];
    return sticker;
}

- (STKStickerPack*)stickerPackModelWithID:(NSNumber*)packID {
    STKStickerPack *stickerPack = [STKStickerPack stk_objectWithUniqueAttribute:STKStickerPackAttributes.packID value:packID context:self.backgroundContext];
    return stickerPack;
}


- (void) getStickerPacks:(void(^)(NSArray *stickerPacks))response {
    
    __weak typeof(self) weakSelf = self;
    [self.backgroundContext performBlock:^{
        STKStickerPackObject *recentPack = [weakSelf recentStickerPack];
        NSArray *stickerPacks = [STKStickerPack stk_findAllInContext:[NSManagedObjectContext stk_backgroundContext]];
        
        NSMutableArray *result = [NSMutableArray array];
        
        for (STKStickerPack *pack in stickerPacks) {
            STKStickerPackObject *stickerPackObject = [[STKStickerPackObject alloc] initWithStickerPack:pack];
            if (stickerPackObject) {
                [result addObject:stickerPackObject];
            }
        }
        [result sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:STKStickerPackAttributes.packName ascending:YES]]];
        if (recentPack) {
            [result insertObject:recentPack atIndex:0];
        }
        if (response) {
            dispatch_async(dispatch_get_main_queue(), ^{
                response(result);
            });
        }
    }];    

}

- (STKStickerPackObject*)recentStickerPack {
    
     __block STKStickerPackObject *object = nil;
    [self.backgroundContext performBlockAndWait:^{
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > 0", STKStickerAttributes.usedCount];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedCount
                                                                         ascending:YES];
        
        NSArray *stickers = [STKSticker stk_findWithPredicate:predicate
                                              sortDescriptors:@[sortDescriptor]
                                                   fetchLimit:12
                                                      context:self.backgroundContext];
        
        if (stickers.count > 0) {
            
            STKStickerPackObject *recentPack = [STKStickerPackObject new];
            recentPack.packName = @"Recent";
            recentPack.packTitle = @"Recent";
            NSMutableArray *stickerObjects = [NSMutableArray new];
            for (STKSticker *sticker in stickers) {
                STKStickerObject *stickerObject = [[STKStickerObject alloc] initWithSticker:sticker];
                if (stickerObject) {
                    [stickerObjects addObject:stickerObject];

                }
            }
            NSArray *sortedRecentStickers = [stickerObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedCount ascending:NO]]];
            recentPack.stickers = sortedRecentStickers;
            
            object = recentPack;
        }
    }];

    
    return object;
}

- (void)incrementUsedCountWithStickerID:(NSNumber *)stickerID {
    
        __weak typeof(self) weakSelf = self;
    [self.backgroundContext performBlock:^{
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",STKStickerAttributes.stickerID , stickerID];
        NSArray *stickers = [STKSticker stk_findWithPredicate:predicate sortDescriptors:nil fetchLimit:1 context:self.backgroundContext];
        STKSticker *sticker = stickers.firstObject;
        NSArray *trimmedPackNameAndStickerName = [STKUtility trimmedPackNameAndStickerNameWithMessage:sticker.stickerMessage];

        NSInteger usedCount = [sticker.usedCount integerValue];
        usedCount++;
        sticker.usedCount = @(usedCount);
        
        [[STKAnalyticService sharedService] sendEventWithCategory:STKAnalyticStickerCategory action:trimmedPackNameAndStickerName.firstObject label:sticker.stickerName value:nil];
        
        [weakSelf.backgroundContext save:nil];
        
    }];
}

#pragma mark - Properties


- (NSManagedObjectContext *)backgroundContext {
    if (!_backgroundContext) {
        _backgroundContext = [NSManagedObjectContext stk_backgroundContext];
    }
    return _backgroundContext;
}

@end
