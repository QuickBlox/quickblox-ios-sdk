//
//  STKStickersMapper.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersMapper.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+STKAdditions.h"
#import "NSManagedObject+STKAdditions.h"
#import "STKStickerPack.h"
#import "STKSticker.h"
#import "STKAnalyticService.h"

@interface STKStickersMapper()

@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;

@end

@implementation STKStickersMapper

- (void)mappingStickerPacks:(NSArray *)stickerPacks async:(BOOL)async {
    
    __weak typeof(self) weakSelf = self;
    
    if (async) {
        [self.backgroundContext performBlock:^{
            [weakSelf createModelsAndSaveFromStickerPacks:stickerPacks];
        }];
    } else {
        [self.backgroundContext performBlockAndWait:^{
           [weakSelf createModelsAndSaveFromStickerPacks:stickerPacks];
        }];
    }
}

- (void) createModelsAndSaveFromStickerPacks:(NSArray*) stickerPacks {
    
    NSArray *packIDs = [stickerPacks valueForKeyPath:@"@unionOfObjects.pack_id"];
    
    NSFetchRequest *requestForDelete = [NSFetchRequest fetchRequestWithEntityName:[STKStickerPack entityName]];
    requestForDelete.predicate = [NSPredicate predicateWithFormat:@"NOT (%K in %@)", STKStickerPackAttributes.packID, packIDs];
    
    NSArray *objectsForDelete = [self.backgroundContext executeFetchRequest:requestForDelete error:nil];
    
    for (STKStickerPack *pack in objectsForDelete) {
        [self.backgroundContext deleteObject:pack];
    }
    
    for (NSDictionary *pack in stickerPacks) {
        NSNumber *packID = pack[@"pack_id"];
        NSString *packName = pack[@"pack_name"];
        
        STKStickerPack *packModel = [STKStickerPack stk_objectWithUniqueAttribute:STKStickerPackAttributes.packID value:packID context:self.backgroundContext];
        if (packModel.packTitle.length == 0) {
            [[STKAnalyticService sharedService] sendEventWithCategory:STKAnalyticPackCategory action:STKAnalyticActionInstall label:packName value:nil];
        }
        NSArray *stickersArray = pack[@"stickers"];
        
        if (stickersArray && !packModel.packName) {
            
            for (NSDictionary *sticker in stickersArray) {
                NSString *stickerName = sticker[@"name"];
//                STKSticker *stickerModel = [NSEntityDescription insertNewObjectForEntityForName:[STKSticker entityName] inManagedObjectContext:self.backgroundContext];
                STKSticker *stickerModel = [STKSticker stk_objectWithUniqueAttribute:STKStickerAttributes.stickerID value:sticker[@"id"] context:self.backgroundContext];
                
                stickerModel.stickerName = stickerName;
                stickerModel.stickerID = sticker[@"id"];
                stickerModel.stickerMessage = [NSString stringWithFormat:@"[[%@_%@]]",packName, stickerName];
                
                [packModel addStickersObject:stickerModel];
                
            }
        }
        
        packModel.packID = packID;
        packModel.packName = packName;
        packModel.packTitle = pack[@"title"];
        packModel.artist = pack[@"artist"];
        packModel.price = pack[@"price"];
        
    }
    
    [self.backgroundContext save:nil];
}

- (NSManagedObjectContext *)backgroundContext {
    if (!_backgroundContext) {
        _backgroundContext = [NSManagedObjectContext stk_backgroundContext];
    }
    return _backgroundContext;
}



@end
