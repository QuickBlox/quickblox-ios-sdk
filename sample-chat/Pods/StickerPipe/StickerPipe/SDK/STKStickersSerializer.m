//
//  STKStickersMapper.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickersSerializer.h"
#import <CoreData/CoreData.h>
#import "NSManagedObjectContext+STKAdditions.h"
#import "NSManagedObject+STKAdditions.h"
#import "STKStickerPack.h"
#import "STKSticker.h"
#import "STKAnalyticService.h"
#import "STKStickerPackObject.h"

@interface STKStickersSerializer()


@end

@implementation STKStickersSerializer

- (NSArray*)serializeStickerPacks:(NSArray *)stickerPacks {
    NSMutableArray *packObjects = [NSMutableArray new];
    for (NSDictionary *dictionary in stickerPacks) {
        STKStickerPackObject *object = [[STKStickerPackObject alloc] initWithServerResponse:dictionary];
        [packObjects addObject:object];
    }
    return [NSArray arrayWithArray:packObjects];
}

@end
