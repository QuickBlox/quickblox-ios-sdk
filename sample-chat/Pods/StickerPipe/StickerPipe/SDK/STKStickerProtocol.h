//
//  STKStickerPackProtocol.h
//  StickerFactory
//
//  Created by Vadim Degterev on 15.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STKStickerProtocol <NSObject>

@required
@property (strong, nonatomic) NSString *stickerName;
@property (strong, nonatomic) NSNumber *stickerID;
@property (strong, nonatomic) NSString *stickerMessage;
@property (assign, nonatomic) NSNumber *usedCount;

@end
