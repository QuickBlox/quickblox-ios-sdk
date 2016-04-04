//
// Created by Vadim Degterev on 12.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "STKBadgeView.h"

@interface STKShowStickerButton : UIButton

@property (nonatomic, strong) STKBadgeView *badgeView;
@property (nonatomic, strong) IBInspectable UIColor *badgeBorderColor;
@end