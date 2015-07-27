//
//  STKStickerPanelHeaderCell.h
//  StickerFactory
//
//  Created by Vadim Degterev on 08.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STKStickerHeaderCell : UICollectionViewCell

@property (strong, nonatomic) UIColor *selectionColor;

- (void) configWithStickerPackName:(NSString*)name placeholder:(UIImage*)placeholder placeholderTintColor:(UIColor*)placeholderTintColor;

@end
