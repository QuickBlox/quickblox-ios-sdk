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
                                didTouchesEnd:(dispatch_block_t)action;
/**
 *  Default back button
 */
- (void)setDefaultBackBarButtonItem:(dispatch_block_t)didTouchesEndAction;

@end
