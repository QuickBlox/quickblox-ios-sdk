//
//  STKStickersMapper.h
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STKStickerPackObject;

@interface STKStickersSerializer : NSObject

- (NSArray*) serializeStickerPacks:(NSArray*)stickerPacks;

- (STKStickerPackObject*) serializeStickerPack:(NSDictionary*)stickerPackResponse;

@end
