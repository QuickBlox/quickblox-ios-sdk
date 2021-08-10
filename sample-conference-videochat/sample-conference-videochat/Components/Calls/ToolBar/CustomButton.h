//
//  IAButton.h
//  sample-conference-videochat
//
//  Created by Injoit on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomButton : UIButton

@property (strong, nonatomic) UIImageView *iconView;

@property (nonatomic, assign, getter=isPushed) BOOL pushed;
@property (nonatomic, assign) BOOL pressed;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *unSelectedColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) NSString *selectedTitle;
@property (nonatomic, strong) NSString *unSelectedTitle;

@end
