//
//  UICollectionView+Chat.m
//  sample-chat
//
//  Created by Injoit on 10.08.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "UICollectionView+Chat.h"

@implementation UICollectionView (Chat)

- (NSArray<NSIndexPath *> *)indexPathsForElementsInRect:(CGRect)rect {
    UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
    NSArray<UICollectionViewLayoutAttributes *> *allLayoutAttributes = [layout layoutAttributesForElementsInRect:rect];
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        [indexPaths addObject:layoutAttributes.indexPath];
    }
    return indexPaths;
}

- (void)compareHandlerWithRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

@end
