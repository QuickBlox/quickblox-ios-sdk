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

@end
