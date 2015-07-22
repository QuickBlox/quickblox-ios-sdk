//
//  STKStickersDataModel.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersDataModel.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+STKAdditions.h"
#import "NSManagedObject+STKAdditions.h"
#import "STKStickerPack.h"
#import "STKStickerObject.h"
#import "STKStickerPackObject.h"
#import "STKSticker.h"
#import "STKAnalyticService.h"
#import "STKUtility.h"

@interface STKStickersDataModel()

@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;
@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation STKStickersDataModel

- (void) getStickerPacks:(void(^)(NSArray *stickerPacks))response {
    
    if (self.queue.operationCount > 0) {
        [self.queue cancelAllOperations];
    }
    
    [self.queue addOperationWithBlock:^{
        STKStickerPackObject *recentPack = [self recentStickerPack];
        NSArray *stickerPacks = [STKStickerPack stk_findAllInContext:[NSManagedObjectContext stk_backgroundContext]];
        
        NSMutableArray *result = [NSMutableArray array];
        
        for (STKStickerPack *pack in stickerPacks) {
            STKStickerPackObject *stickerPackObject = [[STKStickerPackObject alloc] initWithStickerPack:pack];
            [result addObject:stickerPackObject];
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

- (STKStickerPackObject*) recentStickerPack {
    
    __block STKStickerPackObject *object = nil;
    
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K > 0", STKStickerAttributes.usedCount];
        
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedCount
                                                                         ascending:YES];
        
        NSArray *stickers = [STKSticker stk_findWithPredicate:predicate
                                              sortDescriptors:@[sortDescriptor]
                                                   fetchLimit:12
                                                      context:self.backgroundContext];
        
        if (stickers.count > 0) {
            NSArray *sortedRecentStickers = [stickers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:STKStickerAttributes.usedCount ascending:NO]]];
            STKStickerPackObject *recentPack = [STKStickerPackObject new];
            recentPack.packName = @"Recent";
            recentPack.packTitle = @"Recent";
            recentPack.stickers = sortedRecentStickers;
            
            object = recentPack;
        }
    
    return object;
}

- (void)incrementStickerUsedCount:(STKStickerObject *)sticker {
    
    NSArray *trimmedPackNameAndStickerName = [STKUtility trimmedPackNameAndStickerNameWithMessage:sticker.stickerMessage];
    
    
    [[STKAnalyticService sharedService] sendEventWithCategory:STKAnalyticStickerCategory action:trimmedPackNameAndStickerName.firstObject label:sticker.stickerName value:nil];
    
    __weak typeof(self) weakSelf = self;
    
    [self.backgroundContext performBlockAndWait:^{
        STKSticker *stickerModel = [STKSticker modelForObject:sticker];
        NSInteger usedCount = [stickerModel.usedCount integerValue];
        usedCount++;
        stickerModel.usedCount = @(usedCount);
        
        [weakSelf.backgroundContext save:nil];
    }];
    
}

#pragma mark - Properties

- (NSOperationQueue*)queue {
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

- (NSManagedObjectContext *)backgroundContext {
    if (!_backgroundContext) {
        _backgroundContext = [NSManagedObjectContext stk_backgroundContext];
    }
    return _backgroundContext;
}

@end
