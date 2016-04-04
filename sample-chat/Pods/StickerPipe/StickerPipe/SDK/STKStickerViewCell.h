//
//  STKStickerPanelCell.h
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface STKStickerViewCell : UICollectionViewCell

- (void) configureWithStickerMessage:(NSString*)stickerMessage
                         placeholder:(UIImage*)placeholder
                    placeholderColor:(UIColor*)placeholderColor;

@end
