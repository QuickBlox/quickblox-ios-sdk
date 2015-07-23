//
//  STKStickerPanelDelegate.h
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class STKStickerObject;

@interface STKStickerDelegateManager : NSObject <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

//Callbacks
@property (nonatomic, copy) void(^didChangeDisplayedSection)(NSInteger displayedSection);
@property (nonatomic, copy) void(^didSelectSticker)(STKStickerObject* sticker);
@property (nonatomic, weak) UICollectionView *collectionView;

@property (assign, nonatomic) NSInteger currentDisplayedSection;

@property (strong, nonatomic) UIColor *placeholderColor;

- (void) setStickerPacksArray:(NSArray*)stickerPacks;

- (void) setStickerPlaceholder:(UIImage*)stickerPlaceholder;

@end
