//
//  QMChatCollectionView.m
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import "QMChatCollectionView.h"

#import "QMChatContactRequestCell.h"

#import "UIColor+QM.h"

@interface QMChatCollectionView()
@end

@implementation QMChatCollectionView

@dynamic dataSource;
@dynamic delegate;
@dynamic collectionViewLayout;

#pragma mark - Initialization

- (void)configureCollectionView {
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.backgroundColor = [UIColor clearColor];
    self.keyboardDismissMode = UIScrollViewKeyboardDismissModeNone;
    self.alwaysBounceVertical = YES;
    self.bounces = YES;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self configureCollectionView];
    }
    
    return self;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self configureCollectionView];
}

#pragma mark - Messages collection view cell delegate

- (void)chatCellDidTapAvatar:(QMChatCell *)cell {
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
//    [self.delegate collectionView:self didTapAvatarImageView:cell.avatarImageView atIndexPath:indexPath];
}

- (void)chatCellDidTapMessageBubble:(QMChatCell *)cell {
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
//    [self.delegate collectionView:self didTapMessageBubbleAtIndexPath:indexPath];
}

- (void)chatCellDidTapCell:(QMChatCell *)cell atPosition:(CGPoint)position {
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    if (indexPath == nil) {
        return;
    }
    
//    [self.delegate collectionView:self didTapCellAtIndexPath:indexPath touchLocation:position];
}

@end
