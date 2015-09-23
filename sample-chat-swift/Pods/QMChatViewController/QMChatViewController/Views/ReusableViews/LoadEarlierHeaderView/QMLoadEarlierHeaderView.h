//
//  QMLoadEarlierHeaderView.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 21.04.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMLoadEarlierHeaderView;

/**
 *  A constant defining the default height of a `kQMLoadEarlierHeaderViewHeight`.
 */
FOUNDATION_EXPORT const CGFloat kQMLoadEarlierHeaderViewHeight;

/**
 *  The `QMLoadEarlierHeaderViewDelegate` defines methods that allow you to
 *  respond to interactions within the header view.
 */
@protocol QMLoadEarlierHeaderViewDelegate <NSObject>

@required

/**
 *  Tells the delegate that the loadButton has received a touch event.
 *
 *  @param headerView The header view that contains the sender.
 *  @param sender     The button that received the touch.
 */
- (void)headerView:(QMLoadEarlierHeaderView *)headerView didPressLoadButton:(UIButton *)sender;

@end

/**
 *  The `QMLoadEarlierHeaderView` class implements a reusable view that can be placed
 *  at the top of a `QMChatCollectionView`. This view contains a "load earlier messages" button
 *  and can be used as a way for the user to load previously sent messages.
 */
@interface QMLoadEarlierHeaderView : UICollectionReusableView

/**
 *  The object that acts as the delegate of the header view.
 */
@property (weak, nonatomic) id<QMLoadEarlierHeaderViewDelegate> delegate;

/**
 *  Returns the load button of the header view.
 */
@property (weak, nonatomic, readonly) UIButton *loadButton;

#pragma mark - Class methods

/**
 *  Returns the `UINib` object initialized for the collection reusable view.
 *
 *  @return The initialized `UINib` object or `nil` if there were errors during
 *  initialization or the nib file could not be located.
 */
+ (UINib *)nib;

/**
 *  Returns the default string used to identify the reusable header view.
 *
 *  @return The string used to identify the reusable header view.
 */
+ (NSString *)headerReuseIdentifier;

@end
