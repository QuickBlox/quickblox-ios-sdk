//
//  PaddingLabel.m
//  sample-videochat-webrtc
//
//  Created by Injoit on 04.08.2021.
//  Copyright © 2021 QuickBlox Team. All rights reserved.
//

#import "PaddingLabel.h"

@interface PaddingLabel()
//MARK: - Properties
@property (assign, nonatomic) UIEdgeInsets textPaddingInsets;

@end

@implementation PaddingLabel
//MARK: - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _textPaddingInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    UIEdgeInsets invertedInsets = UIEdgeInsetsMake(-self.textPaddingInsets.top,
                                                   -self.textPaddingInsets.left,
                                                   -self.textPaddingInsets.bottom,
                                                   -self.textPaddingInsets.right);
    return UIEdgeInsetsInsetRect(textRect, invertedInsets);
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.textPaddingInsets)];
}

//MARK: - Public Methods
- (void)setupTextPaddingInsets:(UIEdgeInsets)textPaddingInsets {
    _textPaddingInsets = textPaddingInsets;
    [self invalidateIntrinsicContentSize];
}

@end
