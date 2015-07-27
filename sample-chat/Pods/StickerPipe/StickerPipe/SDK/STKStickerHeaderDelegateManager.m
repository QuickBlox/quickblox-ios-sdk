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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.stickerPacksArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STKStickerHeaderCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerPanelHeaderCell" forIndexPath:indexPath];
    
    STKStickerPackObject *stickerPack = self.stickerPacksArray[indexPath.item];
    
    [cell configWithStickerPackName:stickerPack.packName placeholder:self.placeholderImage placeholderTintColor:self.placeholderHeadercolor];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.didSelectRow(indexPath);
}


- (void)setStickerPacks:(NSArray *)stickerPacks {
    self.stickerPacksArray = stickerPacks;    
}


@end
