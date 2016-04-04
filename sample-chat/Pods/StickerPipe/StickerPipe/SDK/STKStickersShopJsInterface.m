//
//  IosJsInterface.m
//  StickerPipe
//
//  Created by Olya Lutsyk on 1/29/16.
//  Copyright © 2016 908 Inc. All rights reserved.
//

#import "STKStickersShopJsInterface.h"
#import "STKStickersConstants.h"

@implementation STKStickersShopJsInterface

- (void)showCollections {
    if ([self.delegate respondsToSelector:@selector(showCollectionsView)]) {
        [self.delegate showCollectionsView];
    }
}

- (void)purchasePack:(NSString *)packTitle :(NSString *)packName :(NSString *)packPrice {
    if ([self.delegate respondsToSelector:@selector(purchasePack: withName: andPrice:)]) {
        [self.delegate purchasePack:packTitle withName:packName andPrice:packPrice];
    }
}

- (void)setInProgress:(BOOL)show {
    if ([self.delegate respondsToSelector:@selector(setInProgress:)]) {
        [self.delegate setInProgress:show];
    }
}

- (void)removePack:(NSString *)packName {
    if ([self.delegate respondsToSelector:@selector(removePack:)]) {
        [self.delegate removePack:packName];
    }
}

- (void)showPack:(NSString *)packName {
    if ([self.delegate respondsToSelector:@selector(showPack:)]) {
        [self.delegate showPack:packName];
    }
}

@end