//
//  STKStickerObject.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STKStickerProtocol.h"

@class STKSticker, STKStickerPackObject;

@interface STKStickerObject : NSObject <STKStickerProtocol>

@property (strong, nonatomic) NSString *stickerName;
@property (strong, nonatomic) NSNumber *stickerID;
@property (strong, nonatomic) NSString *stickerMessage;
@property (assign, nonatomic) NSNumber *usedCount;

- (instancetype) initWithSticker:(STKSticker*) sticker;

@end
