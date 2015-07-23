//
//  STKStickerController.m
//  StickerPipe
//
//  Created by Vadim Degterev on 21.07.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKStickerController.h"
#import "STKStickerDelegateManager.h"
#import "STKStickerHeaderDelegateManager.h"
#import "STKStickerCell.h"
#import "STKStickersSeparator.h"
#import "STKStickerHeaderCell.h"
#import "STKStickersDataModel.h"
#import "STKStickersApiService.h"
#import "STKStickerObject.h"

static const CGFloat stickerSeparatorHeight = 1.0;
static const CGFloat stickersSectionPaddingTopBottom = 12.0;
static const CGFloat stickersSectionPaddingRightLeft = 16.0;

@interface STKStickerController()

@property (strong, nonatomic) UIView *stickersView;

@property (strong, nonatomic) UICollectionView *stickersCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *stickersFlowLayout;
@property (strong, nonatomic) STKStickerDelegateManager *stickersDelegateManager;

@property (strong, nonatomic) UICollectionView *stickersHeaderCollectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *stickersHeaderFlowLayout;
@property (strong, nonatomic) STKStickerHeaderDelegateManager *stickersHeaderDelegateManager;

@property (strong, nonatomic) STKStickersDataModel *dataModel;
//Api
@property (strong, nonatomic) STKStickersApiService *apiClient;




@end

@implementation STKStickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.stickersView = [[UIView alloc] init];
        self.stickersView.backgroundColor = [UIColor whiteColor];
        
        self.dataModel = [STKStickersDataModel new];
        
        self.apiClient = [STKStickersApiService new];
        
        __weak typeof(self) weakSelf = self;
        [self.apiClient getStickersPackWithType:nil success:^(id response) {
            [weakSelf reloadStickers];
        } failure:^(NSError *error) {
            
        }];
        
        self.stickersView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.stickersView.clipsToBounds = YES;
        
        //iOS 7 FIX
        if (CGRectEqualToRect(self.stickersView.frame, CGRectZero) && [UIDevice currentDevice].systemVersion.floatValue < 8.0) {
            self.stickersView.frame = CGRectMake(1, 1, 1, 1);
        }
        
        [self initStickerHeader];
        [self initStickersCollectionView];
        
        [self configureConstraints];
        
        [self reloadStickers];
    }
    return self;
}

- (void) initStickersCollectionView {
    
    self.stickersFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.stickersFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.stickersFlowLayout.itemSize = CGSizeMake(80.0, 80.0);
    self.stickersFlowLayout.sectionInset = UIEdgeInsetsMake(stickersSectionPaddingTopBottom, stickersSectionPaddingRightLeft, stickersSectionPaddingTopBottom, stickersSectionPaddingRightLeft);
    self.stickersFlowLayout.footerReferenceSize = CGSizeMake(0, stickerSeparatorHeight);
    
    self.stickersDelegateManager = [STKStickerDelegateManager new];
    
    __weak typeof(self) weakSelf = self;
    [self.stickersDelegateManager setDidChangeDisplayedSection:^(NSInteger displayedSection) {
        [weakSelf setPackSelectedAtIndex:displayedSection];
    }];
    
    [self.stickersDelegateManager setDidSelectSticker:^(STKStickerObject *sticker) {
        [weakSelf.dataModel incrementStickerUsedCount:sticker];
        if ([weakSelf.delegate respondsToSelector:@selector(stickerController:didSelectStickerWithMessage:)]) {
            [weakSelf.delegate stickerController:weakSelf didSelectStickerWithMessage:sticker.stickerMessage];
        }
    }];
    
    self.stickersCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.stickersFlowLayout];
    self.stickersCollectionView.dataSource = self.stickersDelegateManager;
    self.stickersCollectionView.delegate = self.stickersDelegateManager;
    self.stickersCollectionView.delaysContentTouches = NO;
    self.stickersCollectionView.showsHorizontalScrollIndicator = NO;
    self.stickersCollectionView.showsVerticalScrollIndicator = NO;
    self.stickersCollectionView.backgroundColor = [UIColor clearColor];
    [self.stickersCollectionView registerClass:[STKStickerCell class] forCellWithReuseIdentifier:@"STKStickerPanelCell"];
    [self.stickersCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];
    [self.stickersView addSubview:self.stickersCollectionView];
    [self.stickersCollectionView registerClass:[STKStickersSeparator class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"STKStickerPanelSeparator"];
    
    self.stickersDelegateManager.collectionView = self.stickersCollectionView;
    
    [self.stickersView addSubview:self.stickersCollectionView];
}

- (void) initStickerHeader {
    
    self.stickersHeaderFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.stickersHeaderFlowLayout.itemSize = CGSizeMake(44.0, 44.0);
    self.stickersHeaderFlowLayout.minimumInteritemSpacing = 0;
    self.stickersHeaderFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.stickersHeaderDelegateManager = [STKStickerHeaderDelegateManager new];
    __weak typeof(self) weakSelf = self;
    [self.stickersHeaderDelegateManager setDidSelectRow:^(NSIndexPath *indexPath) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:0 inSection:indexPath.item];
        [weakSelf.stickersCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
        weakSelf.stickersDelegateManager.currentDisplayedSection = indexPath.item;
    }];
    
    self.stickersHeaderCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.stickersHeaderFlowLayout];
    self.stickersHeaderCollectionView.dataSource = self.stickersHeaderDelegateManager;
    self.stickersHeaderCollectionView.delegate = self.stickersHeaderDelegateManager;
    self.stickersHeaderCollectionView.delaysContentTouches = NO;
    self.stickersHeaderCollectionView.allowsMultipleSelection = NO;
    self.stickersHeaderCollectionView.showsHorizontalScrollIndicator = NO;
    self.stickersHeaderCollectionView.showsVerticalScrollIndicator = NO;
    self.stickersHeaderCollectionView.backgroundColor = [UIColor clearColor];
    [self.stickersHeaderCollectionView registerClass:[STKStickerHeaderCell class] forCellWithReuseIdentifier:@"STKStickerPanelHeaderCell"];
    
    self.stickersHeaderCollectionView.backgroundColor = self.headerBackgroundColor ? self.headerBackgroundColor : [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1];
    
    [self.stickersView addSubview:self.stickersHeaderCollectionView];
    
    
}


- (void) configureConstraints {
    
    self.stickersHeaderCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.stickersCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewsDictionary = @{@"stickersHeaderCollectionView" : self.stickersHeaderCollectionView,
                                      @"stickersView" : self.stickersView,
                                      @"stickersCollectionView" : self.stickersCollectionView};
    
    NSArray *horizontalHeaderConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stickersHeaderCollectionView]|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDictionary];
    NSArray *verticalHeaderConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stickersHeaderCollectionView]-0-[stickersCollectionView]"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:viewsDictionary];
    NSArray *horizontalStickersConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stickersCollectionView]|" options:0 metrics:nil views:viewsDictionary];
    NSArray *verticalStickersConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[stickersHeaderCollectionView]-0-[stickersCollectionView]|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:viewsDictionary];
    [self.stickersHeaderCollectionView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[stickersHeaderCollectionView(44.0)]" options:0 metrics:nil views:viewsDictionary]];
    [self.stickersView addConstraints:verticalHeaderConstraints];
    [self.stickersView addConstraints:verticalStickersConstraints];
    [self.stickersView addConstraints:horizontalHeaderConstraints];
    [self.stickersView addConstraints:horizontalStickersConstraints];
    
}



#pragma mark - Reload

- (void) reloadStickers {
    __weak typeof(self) weakSelf = self;
    [self.dataModel getStickerPacks:^(NSArray *stickerPacks) {
        [weakSelf.stickersDelegateManager setStickerPacksArray:stickerPacks];
        [weakSelf.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
        [weakSelf.stickersCollectionView reloadData];
        [weakSelf.stickersHeaderCollectionView reloadData];
        weakSelf.stickersCollectionView.contentOffset = CGPointZero;
        weakSelf.stickersDelegateManager.currentDisplayedSection = 0;
        
        [weakSelf setPackSelectedAtIndex:0];
    }];

}

- (void)setPackSelectedAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    
    [self.stickersHeaderCollectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Colors

-(void)setColorForStickersHeaderPlaceholderColor:(UIColor *)color {
    self.stickersHeaderDelegateManager.placeholderHeadercolor = color;
}

-(void)setColorForStickersPlaceholder:(UIColor *)color {
    self.stickersDelegateManager.placeholderColor = color;
}

#pragma mark - Property

- (BOOL)isStickerViewShowed {
    
    BOOL isShowed = self.stickersView.superview ? YES : NO;
    
    return isShowed;
}

-(UIView *)stickersView {
    
    [self reloadStickers];
    
    return _stickersView;
}


@end
