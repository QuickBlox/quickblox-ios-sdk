//
//  ChatCollectionView.h
//  sample-conference-videochat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCollectionViewFlowLayout.h"
#import "ChatCollectionViewDataSource.h"
#import "ChatCollectionViewDelegateFlowLayout.h"
#import "ChatCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Collection View with chat cells.
 */
@interface ChatCollectionView : UICollectionView
/**
 *  The object that provides the data for the collection view.
 *  The data source must adopt the `ChatCollectionViewDataSource` protocol.
 */
@property (weak, nonatomic) id<ChatCollectionViewDataSource> dataSource;

/**
 *  The object that acts as the delegate of the collection view.
 *  The delegate must adpot the `ChatCollectionViewDelegateFlowLayout` protocol.
 */
@property (weak, nonatomic) id<ChatCollectionViewDelegateFlowLayout> delegate;

/**
 *  The layout used to organize the collection view’s items.
 */
@property (strong, nonatomic) ChatCollectionViewFlowLayout *collectionViewLayout;

@end

NS_ASSUME_NONNULL_END
