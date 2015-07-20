//
//  STKStickerPackProtocol.h
//  StickerFactory
//
//  Created by Vadim Degterev on 15.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STKStickerPackProtocol <NSObject>

@property (nonatomic, strong) NSString *artist;

@property (nonatomic, strong) NSString *packName;

@property (nonatomic, strong) NSString *packTitle;

@property (nonatomic, strong) NSNumber *packID;

@property (nonatomic, assign) NSNumber *price;

@property (nonatomic, strong) NSArray *stickers;

@end
