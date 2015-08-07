//
//  STKStickerPanelDelegate.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerDelegateManager.h"
#import <UIKit/UIKit.h>
#import "STKStickerCell.h"
#import "STKStickersSeparator.h"
#import "STKStickersCache.h"
#import "STKStickersApiService.h"
#import "STKStickerPackObject.h"
#import "STKStickerObject.h"
#import "STKStickersManager.h"

typedef enum {
    
    STKStickerPanelScrollDirectionTop,
    STKStickerPanelScrollDirectionBottom
    
} STKStickerPanelScrollDirection;



@interface STKStickerDelegateManager()

@property (assign, nonatomic) CGFloat lastContentOffset;
@property (assign, nonatomic) STKStickerPanelScrollDirection scrollDirection;

//Common
@property (strong, nonatomic) NSArray *stickerPacks;


@property (strong, nonatomic) UIImage *stickerPlaceholderImage;

@end

@implementation STKStickerDelegateManager

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        STKStickersSeparator *separator = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"STKStickerPanelSeparator" forIndexPath:indexPath];
        //if last section
        if (indexPath.section == self.stickerPacks.count - 1) {
            separator.backgroundColor = [UIColor clearColor];
        } else {
            separator.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1];
        }
        return separator;
    }
    return nil;
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return self.stickerPacks.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    
    STKStickerPackObject *stickerPack = self.stickerPacks[section];
    return stickerPack.stickers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    STKStickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerPanelCell" forIndexPath:indexPath];
    
    STKStickerPackObject *stickerPack = self.self.stickerPacks[indexPath.section];
    
    STKStickerObject *sticker = stickerPack.stickers[indexPath.item];
    
    [cell configureWithStickerMessage:sticker.stickerMessage placeholder:self.stickerPlaceholderImage placeholderColor:self.placeholderColor];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentDisplayedSection == indexPath.section) {
        NSInteger itemsCount = [collectionView numberOfItemsInSection:indexPath.section];
        if (indexPath.item == itemsCount - 1 && self.scrollDirection == STKStickerPanelScrollDirectionBottom) {
            self.didChangeDisplayedSection(indexPath.section + 1);

            self.currentDisplayedSection = indexPath.section + 1;
        }
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    STKStickerPackObject *stickerPack = self.stickerPacks[indexPath.section];
    STKStickerObject *sticker = stickerPack.stickers[indexPath.item];
    
    self.didSelectSticker(sticker);
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
            self.scrollDirection = STKStickerPanelScrollDirectionTop;
            NSInteger minSection = [[[self.collectionView indexPathsForVisibleItems] valueForKeyPath:@"@min.section"] integerValue];
            if (self.currentDisplayedSection > minSection) {
                self.currentDisplayedSection = minSection;
                self.didChangeDisplayedSection(minSection);
            }
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y && self.lastContentOffset != 0)
    {
        self.scrollDirection = STKStickerPanelScrollDirectionBottom;
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
}

#pragma mark - Properties

- (void)setStickerPlaceholder:(UIImage *)stickerPlaceholder {
    self.stickerPlaceholderImage = stickerPlaceholder;
}


- (void)setStickerPacksArray:(NSArray *)stickerPacks {
    self.stickerPacks = stickerPacks;
}


@end
