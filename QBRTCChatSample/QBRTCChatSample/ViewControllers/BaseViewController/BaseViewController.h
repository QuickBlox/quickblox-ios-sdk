//
//  BaseViewController.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

@import UIKit;

@class IAButton;

@interface BaseViewController : UIViewController

@property (strong, nonatomic) NSArray *users;

/**
 *  Create custom UIBarButtonItem instance
 */
- (UIBarButtonItem *)cornerBarButtonWithColor:(UIColor *)color
                                         title:(NSString *)title
                                didTouchesEnd:(void(^)(void))action;
/**
 *  Default back button
 */
- (void)setDefaultBackBarButtonItem:(void(^)(void))didTouchesEndAction;

/**
 *  Default header view
 */
- (UIView *)headerViewWithFrame:(CGRect)headerRect text:(NSString *)text;

/**
 *  Configure IAButton
 */
- (void)configureAIButton:(IAButton *)button
            withImageName:(NSString *)name
                  bgColor:(UIColor *)bgColor
            selectedColor:(UIColor *)selectedColor;
@end
