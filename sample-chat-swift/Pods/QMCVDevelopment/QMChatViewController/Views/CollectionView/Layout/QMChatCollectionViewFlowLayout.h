//
//  QMChatCollectionViewFlowLayout.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>


@class QMChatCollectionView;

/**
 *  The `QMChatCollectionViewFlowLayout` is a concrete layout object that inherits
 *  from `UICollectionViewFlowLayout` and organizes message items in a vertical list.
 *  Each `QMChatCollectionViewCell` in the layout can display messages of arbitrary sizes and avatar images,
 *  as well as metadata such as a timestamp and sender.
 *  You can easily customize the layout via its properties or its delegate methods
 *  defined in `QMChatCollectionViewDelegateFlowLayout`.
 *
 *  @see QMChatCollectionViewDelegateFlowLayout.
 *  @see QMChatCollectionViewCell.
 */
@interface QMChatCollectionViewFlowLayout : UICollectionViewFlowLayout

/**
 *  The collection view object currently using this layout object.
 */
@property (weak, nonatomic) QMChatCollectionView *chatCollectionView;

/**
 *  The maximum number of items that the layout should keep in its cache of layout information.
 *
 *  @discussion The default value is `300`. A limit of `0` means no limit. This is not a strict limit.
 */
@property (assign, nonatomic) NSUInteger cacheLimit;

/**
 *  Returns the width of items in the layout.
 */
@property (readonly, nonatomic) CGFloat itemWidth;

/**
 *  Size for item and index path.
 *
 *  @discussion Returns cached size of item. If size is not in cache, then counts it first.
 *
 *  @return Size of item at index path
 */
- (CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Removing size for itemID from cache.
 *
 *  @discussion Use this method before any of collection view reload methods, that will update missed cached sizes.
 */
- (void)removeSizeFromCacheForItemID:(NSString *)itemID;

@end
