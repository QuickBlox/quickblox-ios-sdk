//
//  STKStickerHeaderDelegateManager.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerHeaderDelegateManager.h"
#import "STKStickerHeaderCell.h"
#import "STKStickerPackObject.h"

@interface STKStickerHeaderDelegateManager()

@property (strong, nonatomic) NSArray *stickerPacksArray;

@end

@implementation STKStickerHeaderDelegateManager

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return (self.stickerPacksArray.count > 0) ? 2 : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0 && self.stickerPacksArray.count > 0) {
        return self.stickerPacksArray.count;
    } else {
        return 1;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STKStickerHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerPanelHeaderCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0 && self.stickerPacksArray.count > 0) {
        STKStickerPackObject *stickerPack = self.stickerPacksArray[indexPath.item];
        
        [cell configWithStickerPack:stickerPack placeholder:self.placeholderImage placeholderTintColor:self.placeholderHeadercolor];
    } else {
        [cell configureSettingsCell];
    }
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.stickerPacksArray.count > 0) {
        STKStickerPackObject *stickerPackObject = self.stickerPacksArray[indexPath.item];
        self.didSelectRow(indexPath, stickerPackObject);
    } else {
        self.didSelectSettingsRow();
    }
}


- (void)setStickerPacks:(NSArray *)stickerPacks {
    self.stickerPacksArray = stickerPacks;
}


#pragma mark - Common

- (STKStickerPackObject *)itemAtIndexPath:(NSIndexPath *)indexPath {
    return self.stickerPacksArray[indexPath.item];
}


@end
