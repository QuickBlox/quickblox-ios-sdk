//
// Created by Vadim Degterev on 12.08.15.
// Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKShowStickerButton.h"

static const CGFloat kBadgeViewPadding = 4.0;

@interface STKShowStickerButton()

@end

@implementation STKShowStickerButton

- (void)awakeFromNib {
    [self initBadgeView];
}

- (instancetype)initWithFrame:(CGRect)frame {
   self = [super initWithFrame:frame];
    if (self) {
        [self initBadgeView];
    }

    return self;
}

- (void)initBadgeView {

    self.imageView.contentMode = UIViewContentModeCenter;
    
    UIColor *color = (self.badgeBorderColor) ? self.badgeBorderColor : [UIColor whiteColor];
    
    self.badgeView = [[STKBadgeView alloc] initWithFrame:CGRectMake(0, 0, 16.0, 16.0) lineWidth:2.0 dotSize:CGSizeZero andBorderColor:color];
    self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - kBadgeViewPadding, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);
    [self addSubview:self.badgeView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.badgeView.center = CGPointMake(CGRectGetMaxX(self.imageView.frame) - 2.0, CGRectGetMinY(self.imageView.frame) + kBadgeViewPadding);
}


@end