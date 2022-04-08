//
//  ChatCell.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatContainerView.h"
#import "ChatCellLayoutAttributes.h"

NS_ASSUME_NONNULL_BEGIN

struct ChatLayoutModel {
    
    CGSize avatarSize;
    CGSize containerSize;
    UIEdgeInsets containerInsets;
    CGFloat topLabelHeight;
    CGFloat timeLabelHeight;
    CGSize staticContainerSize;
    CGFloat spaceBetweenTopLabelAndTextView;
    CGFloat spaceBetweenTextViewAndBottomLabel;
    CGFloat maxWidthMarginSpace;
    CGFloat maxWidth;
};

typedef struct ChatLayoutModel ChatCellLayoutModel;

@class ChatCell;
@class ImageView;

/**
 *  The `ChatCellDelegate` protocol defines methods that allow you to manage
 *  additional interactions within the collection view cell.
 */
@protocol ChatCellDelegate <NSObject>

/**
 *  Protocol methods down below are required to be implemented
 */
@required

/**
 *  Tells the delegate that the message container of the cell has been tapped.
 *
 *  @param cell The cell that received the tap touch event.
 */
- (void)chatCellDidTapContainer:(ChatCell *)cell;

/**
 *  Protocol methods down below are optional and can be ignored
 */
@optional

/**
 *  Tells the delegate that the cell has been tapped at the point specified by position.
 *
 *  @param cell The cell that received the tap touch event.
 *  @param position The location of the received touch in the cell's coordinate system.
 */
- (void)chatCell:(ChatCell *)cell didTapAtPosition:(CGPoint)position;

/**
 *  Tells the delegate that an actions has been selected from the menu of this cell.
 *  This method is automatically called for any registered actions.
 *
 *  @param cell The cell that displayed the menu.
 *  @param action The action that has been performed.
 *  @param sender The object that initiated the action.
 *
 *  @see `ChatCell`
 */
- (void)chatCell:(ChatCell *)cell didPerformAction:(SEL)action withSender:(id)sender;

/**
 *  Tells the delegate that cell receive a tap action on text with a specific checking result.
 *
 *  @param cell               cell that received action
 *  @param textCheckingResult text checking result
 */
- (void)chatCell:(ChatCell *)cell didTapOnTextCheckingResult:(NSTextCheckingResult *)textCheckingResult;

@end

/**
 *  Base chat cell class.
 */
@interface ChatCell : UICollectionViewCell <UIGestureRecognizerDelegate>

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
@property (weak, nonatomic, readonly) ChatContainerView *containerView;
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
@property (weak, nonatomic, readonly) UIImageView *avatarView;
@property (weak, nonatomic, readonly) UILabel *avatarLabel;
@property (weak, nonatomic, readonly) UILabel *timeLabel;

/**
 *  Returns bubbleContainer view
 */
@property (weak, nonatomic, readonly) UIView *previewContainer;

/**
 *  Returns chat message attributed label.
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) UILabel *textView;

/**
 *  Returns top chat message attributed label.
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) UILabel *topLabel;

/**
 *  Returns bottom chat message attributed label.
 *
 *  @warning You should not try to manipulate any properties of this view, for example adjusting
 *  its frame, nor should you remove this view from the cell or remove any of its subviews.
 *  Doing so could result in unexpected behavior.
 */
@property (weak, nonatomic, readonly) UILabel *bottomLabel;

/**
 *  Returns the underlying gesture recognizer for tap gestures in the avatarContainerView of the cell.
 *  This gesture handles the tap event for the avatarContainerView and notifies the cell's delegate.
 */
@property (weak, nonatomic, readonly) UITapGestureRecognizer *tapGestureRecognizer;

/**
 *  The object that acts as the delegate for the cell.
 */
@property (weak, nonatomic) id <ChatCellDelegate> delegate;

//MARK: - Class methods

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
 *  @return ChatCellLayoutModel struct
 */
+ (ChatCellLayoutModel)layoutModel;

/**
 Registers cell for data view
 
 @param dataView data view. UITableView or UICollectionView
 */
+ (void)registerForReuseInView:(id)dataView;

@end


NS_ASSUME_NONNULL_END
