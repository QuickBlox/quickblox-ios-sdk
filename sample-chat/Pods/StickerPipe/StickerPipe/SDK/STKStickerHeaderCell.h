//
//  STKStickerPanelHeaderCell.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKStickerPackObject;

@interface STKStickerHeaderCell : UICollectionViewCell

@property (strong, nonatomic) UIColor *selectionColor;

- (void)configWithStickerPack:(STKStickerPackObject *)stickerPack placeholder:(UIImage *)placeholder placeholderTintColor:(UIColor*)placeholderTintColor;

- (void)configureSettingsCell;

@end
