//
//  QMChatCollectionView.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 20.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMTypingIndicatorFooterView;
@class QMLoadEarlierHeaderView;

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

/**
 *  Specifies whether the typing indicator displays on the left or right side of the collection view
 *  when shown. That is, whether it displays for an "incoming" or "outgoing" message.
 *  The default value is `YES`, meaning that the typing indicator will display on the left side of the
 *  collection view for incoming messages.
 *
 *  @discussion If your `QMChatViewController` subclass displays messages for right-to-left
 *  languages, such as Arabic, set this property to `NO`.
 *
 */
@property (assign, nonatomic) BOOL typingIndicatorDisplaysOnLeft;

/**
 *  The color of the typing indicator message bubble. The default value is a light gray color.
 */
@property (strong, nonatomic) UIColor *typingIndicatorMessageBubbleColor;

/**
 *  The color of the typing indicator ellipsis. The default value is a dark gray color.
 */
@property (strong, nonatomic) UIColor *typingIndicatorEllipsisColor;

/**
 *  The color of the text in the load earlier messages header. The default value is a bright blue color.
 */
@property (strong, nonatomic) UIColor *loadEarlierMessagesHeaderTextColor;

/**
 *  Returns a `QMTypingIndicatorFooterView` object for the specified index path
 *  that is configured using the collection view's properties:
 *  typingIndicatorDisplaysOnLeft, typingIndicatorMessageBubbleColor, typingIndicatorEllipsisColor.
 *
 *  @param indexPath The index path specifying the location of the supplementary view in the collection view. This value must not be `nil`.
 *
 *  @return A valid `QMTypingIndicatorFooterView` object.
 */
- (QMTypingIndicatorFooterView *)dequeueTypingIndicatorFooterViewForIndexPath:(NSIndexPath *)indexPath;

/**
 *  Returns a `QMLoadEarlierHeaderView` object for the specified index path
 *  that is configured using the collection view's loadEarlierMessagesHeaderTextColor property.
 *
 *  @param indexPath The index path specifying the location of the supplementary view in the collection view. This value must not be `nil`.
 *
 *  @return A valid `QMLoadEarlierHeaderView` object.
 */
- (QMLoadEarlierHeaderView *)dequeueLoadEarlierMessagesViewHeaderForIndexPath:(NSIndexPath *)indexPath;

@end
