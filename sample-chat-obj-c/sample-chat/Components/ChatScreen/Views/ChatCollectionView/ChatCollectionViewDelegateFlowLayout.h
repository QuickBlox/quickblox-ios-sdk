//
//  ChatCollectionViewDelegateFlowLayout.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatCollectionView;
@class ChatCollectionViewFlowLayout;
@class ChatCellLayoutAttributes;

typedef struct ChatLayoutModel ChatCellLayoutModel;

/**
 *  The `ChatCollectionViewDelegateFlowLayout` protocol defines methods that allow you to
 *  manage additional layout information for the collection view and respond to additional actions on its items.
 *  The methods of this protocol are all optional.
 */
@protocol ChatCollectionViewDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional

- (ChatCellLayoutModel)collectionView:(ChatCollectionView *)collectionView layoutModelAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(ChatCollectionView *)collectionView dynamicSizeAtIndexPath:(NSIndexPath *)indexPath maxWidth:(CGFloat)maxWidth;
- (CGFloat)collectionView:(ChatCollectionView *)collectionView minWidthAtIndexPath:(NSIndexPath *)indexPath;

@end
