//
//  UICollectionView+Chat.h
//  sample-chat
//
//  Created by Injoit on 10.08.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (Chat)

- (NSArray<NSIndexPath *> *)indexPathsForElementsInRect:(CGRect)rect;
- (void)compareHandlerWithRect:(CGRect)oldRect andRect:(CGRect)newRect removedHandler:(void (^)(CGRect removedRect))removedHandler addedHandler:(void (^)(CGRect addedRect))addedHandler;

@end

NS_ASSUME_NONNULL_END
