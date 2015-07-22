//
//  STKStickerPackObject.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerPackObject.h"
#import "STKSticker.h"
#import "STKStickerPack.h"
#import "STKStickerObject.h"

@implementation STKStickerPackObject

- (instancetype)initWithStickerPack:(STKStickerPack*) stickerPack
{
    self = [super init];
    if (self) {
        self.artist = stickerPack.artist;
        self.packName = stickerPack.packName;
        self.packTitle = stickerPack.packTitle;
        self.packID = stickerPack.packID;
        self.price = stickerPack.price;
        NSMutableArray *stickersArray = [NSMutableArray array];
        for (STKSticker *sticker in stickerPack.stickers) {
            
            STKStickerObject *stickerObject = [[STKStickerObject alloc] initWithSticker:sticker];
            [stickersArray addObject:stickerObject];
        }
        self.stickers = [NSArray arrayWithArray:stickersArray];
    }
    return self;
}

@end
