//
//  QMChatCollectionView.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QMChatCollectionViewFlowLayout.h"
#import "QMChatCollectionViewDataSource.h"
#import "QMChatCollectionViewDelegateFlowLayout.h"
#import "QMChatCell.h"

/**
 *  Collection View with chat cells.
 */
@interface QMChatCollectionView : UICollectionView
/**
 *  The object that provides the data for the collection view.
 *  The data source must adopt the `QMChatCollectionViewDataSource` protocol.
 */
@property (weak, nonatomic) id<QMChatCollectionViewDataSource> dataSource;

/**
 *  The object that acts as the delegate of the collection view.
 *  The delegate must adpot the `QMChatCollectionViewDelegateFlowLayout` protocol.
 */
@property (weak, nonatomic) id<QMChatCollectionViewDelegateFlowLayout> delegate;

/**
 *  The layout used to organize the collection view’s items.
 */
@property (strong, nonatomic) QMChatCollectionViewFlowLayout *collectionViewLayout;

@end
