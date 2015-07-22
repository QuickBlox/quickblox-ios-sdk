//
//  STKStickerPanelHeader.m
//  StickerFactory
//
//  Created by Vadim Degterev on 07.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerPanelHeader.h"
#import "STKStickerPanelHeaderCell.h"
#import "STKStickerPackObject.h"
#import "STKStickersManager.h"

@interface STKStickerPanelHeader() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSArray *stickerPacksArray;

@end

@implementation STKStickerPanelHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.itemSize = CGSizeMake(44.0, 44.0);
        self.flowLayout.minimumInteritemSpacing = 0;
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.flowLayout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.delaysContentTouches = NO;
        self.collectionView.allowsMultipleSelection = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView registerClass:[STKStickerPanelHeaderCell class] forCellWithReuseIdentifier:@"STKStickerPanelHeaderCell"];
        
        [self addSubview:self.collectionView];
        
        
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.collectionView.frame = self.frame;
}

- (void) configureConstraints {
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
    
    NSLayoutConstraint *equalW = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1 constant:0];
    
    NSLayoutConstraint *equalH = [NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1 constant:0];
    
    [self.collectionView addConstraints:@[centerX, centerY, equalH, equalW]];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.stickerPacksArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STKStickerPanelHeaderCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerPanelHeaderCell" forIndexPath:indexPath];
    
    STKStickerPackObject *stickerPack = self.stickerPacksArray[indexPath.item];
    
    [cell configWithStickerPackName:stickerPack.packName placeholder:self.placeholderImage placeholderTintColor:[STKStickersManager panelHeaderPlaceholderColor]];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(stickerPanelHeader:didSelectPack:atIndex:)]) {
        STKStickerPackObject *object = self.stickerPacksArray[indexPath.item];
        [self.delegate stickerPanelHeader:self didSelectPack:object atIndex:indexPath.item];
    }
}

- (void)setPackSelectedAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];

    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

- (void)setPackSelected:(STKStickerPackObject *)object {
    NSUInteger index = [self.stickerPacksArray indexOfObject:object];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
}

- (void)setStickerPacks:(NSArray *)stickerPacks {
    self.stickerPacksArray = stickerPacks;
    [self.collectionView reloadData];

}


@end
