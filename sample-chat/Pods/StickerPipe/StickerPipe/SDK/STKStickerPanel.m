//
//  STKStickerPanel.m
//  StickerFactory
//
//  Created by Vadim Degterev on 06.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerPanel.h"
#import "STKStickerPanelLayout.h"
#import "STKStickerPanelCell.h"
#import "STKStickerPanelHeader.h"
#import <CoreData/CoreData.h>
#import "STKStickerPackObject.h"
#import "STKStickerObject.h"
#import "NSManagedObject+STKAdditions.h"
#import "NSManagedObjectContext+STKAdditions.h"
#import "STKStickersApiClient.h"
#import "STKStickersDataModel.h"
#import "STKStickersManager.h"

typedef enum {
    
    STKStickerPanelScrollDirectionTop,
    STKStickerPanelScrollDirectionBottom
    
} STKStickerPanelScrollDirection;


@interface STKStickerPanel() <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate,STKStickerPanelHeaderDelegate>

//UI
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) STKStickerPanelLayout *flowLayout;
@property (strong, nonatomic) STKStickerPanelHeader *headerView;

@property (assign, nonatomic) NSInteger currentDisplayedSection;
@property (assign, nonatomic) CGFloat lastContentOffset;
@property (assign, nonatomic) STKStickerPanelScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL needUpdateHeader;

//Common
@property (strong, nonatomic) STKStickersDataModel *dataModel;
@property (strong, nonatomic) NSArray *stickerPacks;
//CoreData
@property (strong, nonatomic) NSManagedObjectContext *context;
//Api
@property (strong, nonatomic) STKStickersApiClient *apiClient;

@end

@implementation STKStickerPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        //Flexible height for system
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        
        
        self.flowLayout = [[STKStickerPanelLayout alloc] init];
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.flowLayout.itemSize = CGSizeMake(80.0, 80.0);
        
        self.headerView = [[STKStickerPanelHeader alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44.0)];
        self.headerView.backgroundColor = self.headerBackgroundColor ? self.headerBackgroundColor : [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1];
        self.headerView.delegate = self;
        
        [self addSubview:self.headerView];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.headerView.frame)) collectionViewLayout:self.flowLayout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.delaysContentTouches = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self.collectionView registerClass:[STKStickerPanelCell class] forCellWithReuseIdentifier:@"STKStickerPanelCell"];
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];
        [self addSubview:self.collectionView];
        
        self.currentDisplayedSection = 0;
        self.needUpdateHeader = YES;
        
        self.apiClient = [[STKStickersApiClient alloc] init];
        
        __weak typeof(self) weakSelf = self;
        
        self.dataModel = [STKStickersDataModel new];
        
        [self.apiClient getStickersPackWithType:nil success:^(id response) {
            
            [weakSelf reloadStickers];
            
        } failure:nil];
        
        //iOS 7 FIX
        if (CGRectEqualToRect(frame, CGRectZero) && [UIDevice currentDevice].systemVersion.floatValue < 8.0) {
            self.frame = CGRectMake(1, 1, 1, 1);
        }
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    self.scrollDirection = STKStickerPanelScrollDirectionTop;
    [self.collectionView setContentOffset:CGPointZero];
}

- (void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    self.currentDisplayedSection = 0;
    if (!newSuperview) {

        [self reloadStickers];
    }
}

- (void)layoutSubviews {
    self.collectionView.frame = CGRectMake(0, CGRectGetHeight(self.headerView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(self.headerView.frame));
    self.headerView.frame = CGRectMake(0, 0, self.frame.size.width, 44.0);
}


#pragma mark - Work with base


- (void) reloadStickers {
    
    
    __weak typeof(self) weakSelf = self;
    
    [self.dataModel getStickerPacks:^(NSArray *stickerPacks) {
        
        [weakSelf.headerView setStickerPacks:stickerPacks];
        [weakSelf.headerView setPackSelectedAtIndex:weakSelf.currentDisplayedSection];
        weakSelf.stickerPacks = stickerPacks;
        [weakSelf.collectionView reloadData];
        
    }];


}

#pragma mark - UICollectionViewDataSource


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
    STKStickerPanelCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"STKStickerPanelCell" forIndexPath:indexPath];

    STKStickerPackObject *stickerPack = self.self.stickerPacks[indexPath.section];
        
    STKStickerObject *sticker = stickerPack.stickers[indexPath.item];

    [cell configureWithStickerMessage:sticker.stickerMessage placeholder:self.stickerPlaceholder placeholderColor:[STKStickersManager panelPlaceholderColor]];
    
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.needUpdateHeader = YES;

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
        if (self.needUpdateHeader) {
            self.scrollDirection = STKStickerPanelScrollDirectionTop;
            NSInteger minSection = [[[self.collectionView indexPathsForVisibleItems] valueForKeyPath:@"@min.section"] integerValue];
            if (self.currentDisplayedSection > minSection) {
                self.currentDisplayedSection = minSection;
                [self.headerView setPackSelectedAtIndex:minSection];
            }
        }
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y && self.lastContentOffset != 0)
    {
        self.scrollDirection = STKStickerPanelScrollDirectionBottom;
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
}


#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentDisplayedSection == indexPath.section && self.needUpdateHeader) {
        NSInteger itemsCount = [self.collectionView numberOfItemsInSection:indexPath.section];
        if (indexPath.item == itemsCount - 1 && self.scrollDirection == STKStickerPanelScrollDirectionBottom) {
            [self.headerView setPackSelectedAtIndex:indexPath.section + 1];
            self.currentDisplayedSection = indexPath.section + 1;
        }
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    STKStickerPackObject *stickerPack = self.stickerPacks[indexPath.section];
    STKStickerObject *sticker = stickerPack.stickers[indexPath.item];
    
    [self.dataModel incrementStickerUsedCount:sticker];
        
    if ([self.delegate respondsToSelector:@selector(stickerPanel:didSelectStickerWithMessage:)]) {
        [self.delegate stickerPanel:self didSelectStickerWithMessage:sticker.stickerMessage];
    }
    
}

#pragma mark - STKStickerPanelHeaderDelegate

- (void)stickerPanelHeader:(STKStickerPanelHeader *)header didSelectPack:(STKStickerPackObject *)pack atIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:index];
    //See scrollViewDidEndScrollingAnimation
    self.needUpdateHeader = NO;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    self.currentDisplayedSection = index;
}

#pragma mark - Support methods

- (BOOL)isShowed {
    
    BOOL isShowed = self.superview ? YES : NO;
    
    return isShowed;
}


#pragma mark - Context

- (NSManagedObjectContext *)context {
    if (!_context) {
        _context = [NSManagedObjectContext stk_defaultContext];
    }
    return _context;
}

@end
