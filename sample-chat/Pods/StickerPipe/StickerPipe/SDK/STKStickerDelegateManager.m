//
//  STKStickerPanelDelegate.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerDelegateManager.h"
#import "STKStickerViewCell.h"
#import "STKStickersSeparator.h"
#import "STKStickerPackObject.h"
#import "STKStickerObject.h"

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
    if (stickerPack.stickers.count == 0 && [stickerPack.packName isEqualToString:@"Recent"]) {
        //Empty cell
        return 1;
    }
    return stickerPack.stickers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id cell = nil;
    
    STKStickerPackObject *stickerPack = self.stickerPacks[indexPath.section];
    if (stickerPack.stickers.count == 0 && [stickerPack.packName isEqualToString:@"Recent"]) {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKEmptyRecentCell" forIndexPath:indexPath];
        
    } else {
       cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerViewCell" forIndexPath:indexPath];
        
        STKStickerObject *sticker = stickerPack.stickers[indexPath.item];
        [cell configureWithStickerMessage:sticker.stickerMessage placeholder:self.stickerPlaceholderImage placeholderColor:self.placeholderColor];
    }
    

    
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
    if (stickerPack.stickers.count > 0) {
        STKStickerObject *sticker = stickerPack.stickers[indexPath.item];
        if (sticker) {
            [self addRecentSticker:sticker forSection:indexPath.section];
            self.didSelectSticker(sticker);
        }
    }

}

- (void)addRecentSticker:(STKStickerObject*)sticker forSection:(NSInteger)section {
    if (section > 0) {
    sticker.usedCount = @(sticker.usedCount.integerValue + 1);
    STKStickerPackObject *recentPack = self.stickerPacks[0];
    BOOL hasSticker = NO;
    NSInteger stickerIndex = 0;
    for (int i = 0; i < recentPack.stickers.count; i++) {
        STKStickerObject *st = recentPack.stickers[i];
        if (st.stickerID == sticker.stickerID) {
            hasSticker = YES;
            stickerIndex = i;
        }
    }
    if (hasSticker) {
        [recentPack.stickers removeObjectAtIndex:stickerIndex];
    }

    [recentPack.stickers insertObject:sticker atIndex:0];

    [recentPack.stickers sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"usedCount" ascending:NO]]];
    
    if (recentPack.stickers.count > 12) {
        [recentPack.stickers removeObjectAtIndex:12];
    }
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    STKStickerPackObject *pack = self.stickerPacks[indexPath.section];
    if ([pack.packName isEqualToString:@"Recent"] && pack.stickers.count == 0) {
        
        UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)collectionViewLayout;
        
        return CGSizeMake(self.collectionView.frame.size.width - (layout.sectionInset.left + layout.sectionInset.right), 100.0);
        
    } else {
        return CGSizeMake(80.0, 80.0);
    }
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
