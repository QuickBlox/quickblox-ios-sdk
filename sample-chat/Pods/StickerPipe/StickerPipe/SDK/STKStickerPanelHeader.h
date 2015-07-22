//
//  STKStickerPanelHeader.h
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STKStickerPackObject, STKStickerPanelHeader;

@protocol STKStickerPanelHeaderDelegate <NSObject>

- (void) stickerPanelHeader:(STKStickerPanelHeader*)header didSelectPack:(STKStickerPackObject*)pack atIndex:(NSInteger)index;

@end

@interface STKStickerPanelHeader : UIView

@property (weak, nonatomic) id<STKStickerPanelHeaderDelegate> delegate;

@property (strong, nonatomic) UIImage *placeholderImage;

- (void) setStickerPacks:(NSArray*)stickerPacks;

- (void) setPackSelected:(STKStickerPackObject*)object;
- (void) setPackSelectedAtIndex:(NSInteger)index;

@end
