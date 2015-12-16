//
//  IAButton.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QBButton : UIButton

@property (strong, nonatomic) UIImageView *iconView;

@property (nonatomic, assign, getter=isPushed) BOOL pushed;
@property (nonatomic, assign) BOOL pressed;

@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, strong) UIColor *textColor;

@end
