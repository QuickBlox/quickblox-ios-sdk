//
//  QMPlaceHolderTextView.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 13.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Input field with placeholder.
 */
@interface QMPlaceHolderTextView : UITextView

/**
 *  The text to be displayed when the text view is empty. The default value is `nil`.
 */
@property (copy, nonatomic) IBInspectable NSString *placeHolder;

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

@end
