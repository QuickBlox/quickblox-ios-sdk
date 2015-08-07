//
//  STKStickersDataModel.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKStickerObject, STKStickerPackObject;

@interface STKStickersCache : NSObject

- (void) saveStickerPacks:(NSArray*) stickerPacks;

- (void) getStickerPacks:(void(^)(NSArray *stickerPacks))response;

- (STKStickerPackObject*)recentStickerPack;

- (void) incrementUsedCountWithStickerID:(NSNumber*)stickerID;


@end
