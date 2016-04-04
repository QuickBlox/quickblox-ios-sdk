//
//  STKStickerSettingsCell.m
//  StickerPipe
//
//  Created by Vadim Degterev on 05.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerSettingsCell.h"
#import "STKStickerPackObject.h"
#import "DFImageManagerKit.h"
#import "STKUtility.h"

@implementation STKStickerSettingsCell

- (void) prepareForReuse {
    [self.packIconImageView df_prepareForReuse];
}

- (void)configureWithStickerPack:(STKStickerPackObject*)stickerPack {
    
    NSURL *iconUrl = [STKUtility mainImageUrlForPackName:stickerPack.packName];
    
    
    [self.packIconImageView df_setImageWithResource:iconUrl];
    self.packTitleLabel.text = stickerPack.packTitle;
    self.packDescriptionLabel.text = stickerPack.artist;
    
}

@end
