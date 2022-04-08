//
//  ChatCollectionViewFlowLayout.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ChatCollectionView;

/**
 *  The `ChatCollectionViewFlowLayout` is a concrete layout object that inherits
 *  from `UICollectionViewFlowLayout` and organizes message items in a vertical list.
 *  Each `ChatCollectionViewCell` in the layout can display messages of arbitrary sizes and avatar images,
 *  as well as metadata such as a timestamp and sender.
 *  You can easily customize the layout via its properties or its delegate methods
 *  defined in `ChatCollectionViewDelegateFlowLayout`.
 *
 *  @see ChatCollectionViewDelegateFlowLayout.
 *  @see ChatCollectionViewCell.
 */
@interface ChatCollectionViewFlowLayout : UICollectionViewFlowLayout

/**
 *  The collection view object currently using this layout object.
 */
@property (weak, nonatomic) ChatCollectionView *chatCollectionView;

/**
 *  Returns the width of items in the layout.
 */
@property (readonly, nonatomic) CGFloat itemWidth;

- (CGSize)containerViewSizeForItemAtIndexPath:(NSIndexPath *)indexPath;

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


NS_ASSUME_NONNULL_END
