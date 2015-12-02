//
//  QMChatCollectionViewDelegateFlowLayout.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class QMChatCollectionView;
@class QMChatCollectionViewFlowLayout;
@class QMChatCollectionViewCell;
@class QMChatCellLayoutAttributes;

typedef struct QMChatLayoutModel QMChatCellLayoutModel;

/**
 *  The `QMChatCollectionViewDelegateFlowLayout` protocol defines methods that allow you to
 *  manage additional layout information for the collection view and respond to additional actions on its items.
 *  The methods of this protocol are all optional.
 */
@protocol QMChatCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

- (QMChatCellLayoutModel)collectionView:(QMChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(QMChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth;
- (CGFloat)collectionView:(QMChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath;

@end
