//
//  PlaceHolderTextView.h
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>


@class PlaceHolderTextView;

NS_ASSUME_NONNULL_BEGIN

extern NSString * const PlaceholderDidChangeHeight;

@protocol PlaceHolderTextViewPasteDelegate;

/**
 *  A delegate object used to notify the receiver of paste events from a `PlaceHolderTextView`.
 */
@protocol PlaceHolderTextViewPasteDelegate <NSObject>

/**
 *  Asks the delegate whether or not the `textView` should use the original implementation of `-[UITextView paste]`.
 *
 *  @discussion Use this delegate method to implement custom pasting behavior.
 *  You should return `NO` when you want to handle pasting.
 *  Return `YES` to defer functionality to the `textView`.
 */
- (BOOL)placeHolderTextView:(PlaceHolderTextView *)textView shouldPasteWithSender:(id)sender;

@end

/**
 *  Input field with placeholder.
 */
@interface PlaceHolderTextView : UITextView

/**
 *  The object that acts as the paste delegate of the text view.
 */
@property (weak, nonatomic, nullable) id<PlaceHolderTextViewPasteDelegate> placeholderTextViewPasteDelegate;

/**
 *  The text to be displayed when the text view is empty. The default value is `nil`.
 */
@property (copy, nonatomic, nullable) IBInspectable NSString *placeHolder;

/**
 *  The color of the place holder text. The default value is `[UIColor lightGrayColor]`.
 */
@property (strong, nonatomic) IBInspectable UIColor *placeHolderColor;

/**
 *  Determines whether or not the text view contains text after trimming white space
 *  from the front and back of its string.
 *
 *  @return `YES` if the text view contains text, `NO` otherwise.
 */
- (BOOL)hasText;

/**
 *  Determines whether or not the text view contains image as NSTextAttachment
 *
 *
 *  @return `YES` if the text view contains attachment, `NO` otherwise.
 */
- (BOOL)hasTextAttachment;


- (void)setDefaultSettings;

@end

NS_ASSUME_NONNULL_END

