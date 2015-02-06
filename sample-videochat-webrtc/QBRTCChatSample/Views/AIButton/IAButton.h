//
//  IAButton.h
//  QBRTCChatSemple
//
//  Created by Andrey Ivanov on 16.12.14.
//  Copyright (c) 2014 QuickBlox Team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAButton : UIButton

@property (strong, nonatomic) UIView *iconView;
@property (assign, nonatomic) BOOL isPushed;
@property (strong, nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *selectedColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *hightlightedTextColor UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIColor *textColor  UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *mainLabelFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *subLabelFont UI_APPEARANCE_SELECTOR;

@end
