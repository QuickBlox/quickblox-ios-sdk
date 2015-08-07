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
#import "STKStickerObject.h"
#import "STKIntroService.h"
#import "STKStickersEntityService.h"

//SIZES
//static const CGFloat stickerHeaderItemHeight = 44.0;
//static const CGFloat stickerHeaderItemWidth = 44.0;

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

@property (strong, nonatomic) UIView *introView;

@property (strong, nonatomic) STKIntroService *introService;

@property (strong, nonatomic) STKStickersEntityService *stickersService;

//Constraints
@property (strong, nonatomic) NSLayoutConstraint *introCenterYConstraint;


@end

@implementation STKStickerController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.stickersView = [[UIView alloc] init];
        self.stickersView.backgroundColor = [UIColor whiteColor];
        
        self.stickersService = [STKStickersEntityService new];
        
        self.stickersView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.stickersView.clipsToBounds = YES;
        
        //iOS 7 FIX
        if (CGRectEqualToRect(self.stickersView.frame, CGRectZero) && [UIDevice currentDevice].systemVersion.floatValue < 8.0) {
            self.stickersView.frame = CGRectMake(1, 1, 1, 1);
        }
        
        [self initStickerHeader];
        [self initStickersCollectionView];
        
        [self configureStickersViewsConstraints];
        
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
        [weakSelf.stickersService incrementStickerUsedCountWithID:sticker.stickerID];
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


- (void) configureStickersViewsConstraints {
    
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

#pragma mark - Gestures

- (void)introDidTapWithGesture:(UITapGestureRecognizer*)gesture {
    
    [self hideIntroView];
    
}

- (void)introDidPanWithGesture:(UIPanGestureRecognizer*)gesture {
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint touchPoint = [gesture translationInView:self.stickersView];
        self.introCenterYConstraint.constant = touchPoint.y;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.introCenterYConstraint.constant < CGRectGetHeight(self.introView.frame) / 2) {
            self.introCenterYConstraint.constant = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self.introView layoutIfNeeded];
            }];
        } else {
            [self hideIntroView];
        }
    }

    
}

#pragma mark - Intro View

- (void)hideIntroView {
    
    self.introCenterYConstraint.constant = CGRectGetHeight(self.introView.frame);
    [UIView animateWithDuration:0.3 animations:^{
        [self.stickersView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.introView removeFromSuperview];
    }];

    
}


#pragma mark - Reload

- (void)reloadStickers {
    __weak typeof(self) weakSelf = self;
    [self.stickersService getStickerPacksWithType:nil completion:^(NSArray *stickerPacks) {
        [weakSelf.stickersDelegateManager setStickerPacksArray:stickerPacks];
        [weakSelf.stickersHeaderDelegateManager setStickerPacks:stickerPacks];
        [weakSelf.stickersCollectionView reloadData];
        [weakSelf.stickersHeaderCollectionView reloadData];
        weakSelf.stickersCollectionView.contentOffset = CGPointZero;
        weakSelf.stickersDelegateManager.currentDisplayedSection = 0;
        
        [weakSelf setPackSelectedAtIndex:0];
    } failure:^(NSError *error) {
        
    }];
}

- (void)setPackSelectedAtIndex:(NSInteger)index {
    if ([self.stickersHeaderCollectionView numberOfItemsInSection:0] >= index) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        
        [self.stickersHeaderCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }

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
    //TODO:Refactoring
    [self reloadStickers];

    return isShowed;
}

-(UIView *)stickersView {
    
    return _stickersView;
}


@end
