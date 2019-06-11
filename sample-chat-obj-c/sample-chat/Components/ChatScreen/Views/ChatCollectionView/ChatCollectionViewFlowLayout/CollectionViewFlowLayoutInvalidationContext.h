//
//  CollectionViewFlowLayoutInvalidationContext.h
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CollectionViewFlowLayoutInvalidationContext : UICollectionViewFlowLayoutInvalidationContext

/**
 *  A boolean indicating whether to empty the messages layout information cache for items and views in the layout.
 *  The default value is `NO`.
 */
@property (nonatomic, assign) BOOL invalidateFlowLayoutMessagesCache;

/**
 *  Creates and returns a new `CollectionViewFlowLayoutInvalidationContext` object.
 *
 *  @discussion When you need to invalidate the `ChatCollectionViewFlowLayout` object for your
 *  `ChatViewController` subclass, you should use this method to instantiate a new invalidation
 *  context and pass this object to `invalidateLayoutWithContext:`.
 *
 *  @return An initialized invalidation context object if successful, otherwise `nil`.
 */
+ (instancetype)context;

@end

NS_ASSUME_NONNULL_END
