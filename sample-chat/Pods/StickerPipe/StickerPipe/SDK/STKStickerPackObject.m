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

- (instancetype)initWithServerResponse:(NSDictionary *)serverResponse
{
    self = [super init];
    if (self) {
        self.artist = serverResponse[@"artist"];
        NSString *packName = serverResponse[@"pack_name"];
        self.packName = packName;
        self.packTitle = serverResponse[@"title"];
        self.packID = serverResponse[@"pack_id"];
        self.price = serverResponse[@"price"];
        NSMutableArray *stickersArray = [NSMutableArray array];
        NSArray *stickers = serverResponse[@"stickers"];
//        @autoreleasepool {
            for (NSDictionary *sticker in stickers) {
                STKStickerObject *stickerObject = [[STKStickerObject alloc] init];
                stickerObject.stickerID = sticker[@"id"];
                NSString *stickerName = sticker[@"name"];
                stickerObject.stickerName = stickerName;
                stickerObject.stickerMessage = [NSString stringWithFormat:@"[[%@_%@]]", packName, stickerName];
                [stickersArray addObject:stickerObject];
            }
//        }

        self.stickers = [NSArray arrayWithArray:stickersArray];
    }
    return self;
}

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


#pragma mark - Description

- (NSString*) stringForDescription {
    return [NSString stringWithFormat:@"%@/n Artist: %@/n packName: %@/n Pack title: %@/n packID: %@/n price: %@", [super description], self.artist, self.packName, self.packTitle, self.packID, self.price];
}

- (NSString *)description {
    
    return [self stringForDescription];
}

- (NSString *)debugDescription {
    return [self stringForDescription];
}

@end
