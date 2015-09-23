//
//  QMChatContainerView.h
//  QMChatViewController
//
//  Created by Andrey Ivanov on 14.05.15.
//  Copyright (c) 2015 QuickBlox Team. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
/**
 *  Customisable chat container view.
 */
@interface QMChatContainerView : UIView

@property (strong, nonatomic) IBInspectable UIColor *bgColor;
@property (strong, nonatomic) IBInspectable UIColor *highlightColor;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;
@property (assign, nonatomic) IBInspectable BOOL arrow;
@property (assign, nonatomic) IBInspectable BOOL leftArrow;
@property (assign, nonatomic) IBInspectable CGSize arrowSize;

@property (assign, nonatomic) BOOL highlighted;

@end
