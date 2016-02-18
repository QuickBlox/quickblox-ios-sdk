//
//  QMChatCell.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatContainerView.h"
#import "TTTAttributedLabel.h"
#import "QMChatCellLayoutAttributes.h"
#import "QMImageView.h"

struct QMChatLayoutModel {
    
    CGSize avatarSize;
    CGSize containerSize;
    UIEdgeInsets containerInsets;
    CGFloat topLabelHeight;
    CGFloat bottomLabelHeight;
    CGSize staticContainerSize;
    CGFloat spaceBetweenTopLabelAndTextView;
    CGFloat spaceBetweenTextViewAndBottomLabel;
    CGFloat maxWidthMarginSpace;
};

typedef struct QMChatLayoutModel QMChatCellLayoutModel;

@class QMChatCell;
@class QMImageView;

/**
 *  The `QMChatCellDelegate` protocol defines methods that allow you to manage
 *  additional interactions within the collection view cell.
 */
@protocol QMChatCellDelegate <NSObject>

@required

/**
 *  Tells the delegate that the avatarImageView of the cell has been tapped.
 *
 *  @param cell The cell that received the tap touch event.
 */
- (void)chatCellDidTapAvatar:(QMChatCell *)cell;

/**
 *  Tells the delegate that the message container of the cell has been tapped.
 *
 *  @param cell The cell that received the tap touch event.
 */
- (void)chatCellDidTapContainer:(QMChatCell *)cell;

/**
 *  Tells the delegate that the cell has been tapped at the point specified by position.
 *
 *  @param cell The cell that received the tap touch event.
 *  @param position The location of the received touch in the cell's coordinate system.
 */
- (void)chatCell:(QMChatCell *)cell didTapAtPosition:(CGPoint)position;

/**
 *  Tells the delegate that an actions has been selected from the menu of this cell.
 *  This method is automatically called for any registered actions.
 *
 *  @param cell The cell that displayed the menu.
 *  @param action The action that has been performed.
 *  @param sender The object that initiated the action.
 *
 *  @see `QMChatCell`
 */
- (void)chatCell:(QMChatCell *)cell didPerformAction:(SEL)action withSender:(id)sender;

@end

/**
 *  Base chat cell class.
 */
@interface QMChatCell : UICollectionViewCell <UIGestureRecognizerDelegate>

/**
 *  Returns the message container view of the cell. This view is the superview of
 *  the cell's textView, image view or other
 *
 *  @discussion You may customize the cell by adding custom views to this container view.
 *  To do so, override `collectionView:cellForItemAtIndexPath:`
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) QMChatContainerView *containerView;
@property (weak, nonatomic, readonly) UIView *messageContainer;

/**
 *  Returns the avatar container view of the cell. This view is the superview of the cell's avatarImageView.
 *
 *  @discussion You may customize the cell by adding custom views to this container view.
 *  To do so, override `collectionView:cellForItemAtIndexPath:`
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) UIView *avatarContainerView;
@property (weak, nonatomic, readonly) UIImage *avatarImageView;

/**
 *  Property to set avatar view
 */
@property (unsafe_unretained, nonatomic) IBOutlet QMImageView *avatarView;

/**
 *  Returns chat message attributed label.
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) TTTAttributedLabel *textView;

/**
 *  Returns top chat message attributed label.
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) TTTAttributedLabel *topLabel;

/**
 *  Returns bottom chat message attributed label.
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) TTTAttributedLabel *bottomLabel;

/**
 *  Returns the underlying gesture recognizer for tap gestures in the avatarContainerView of the cell.
 *  This gesture handles the tap event for the avatarContainerView and notifies the cell's delegate.
 */
@property (weak, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

/**
 *  The object that acts as the delegate for the cell.
 */
@property (weak, nonatomic) id <QMChatCellDelegate> delegate;

#pragma mark - Class methods

/**
 *  Returns the `UINib` object initialized for the cell.
 *
 *  @return The initialized `UINib` object or `nil` if there were errors during
 *  initialization or the nib file could not be located.
 */
+ (UINib *)nib;

/**
 *  Returns the default string used to identify a reusable cell for text message items.
 *
 *  @return The string used to identify a reusable cell.
 */
+ (NSString *)cellReuseIdentifier;

/**
 *  Registers an action to be available in the cell's menu.
 *
 *  @param action The selector to register with the cell.
 *
 *  @discussion Non-standard or non-system actions must be added to the `UIMenuController` manually.
 *  You can do this by creating a new `UIMenuItem` and adding it via the controller's `menuItems` property.
 *
 *  @warning Note that all message cells share the all actions registered here.
 */
+ (void)registerMenuAction:(SEL)action;

/**
 *  Model that allows modifying layout without changing constraints directly.
 *
 *  @return QMChatCellLayoutModel struct
 */
+ (QMChatCellLayoutModel)layoutModel;

@end
