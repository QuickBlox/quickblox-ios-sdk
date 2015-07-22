//
//  STKStickerObject.m
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerObject.h"
#import "STKSticker.h"
#import "STKStickerPackObject.h"
#import "STKStickerPack.h"

@implementation STKStickerObject

- (instancetype) initWithSticker:(STKSticker*) sticker
{
    self = [super init];
    if (self) {
        self.stickerName = sticker.stickerName;
        self.stickerID = sticker.stickerID;
        self.stickerMessage = sticker.stickerMessage;
        self.usedCount = sticker.usedCount;
    }
    return self;
}

@end
