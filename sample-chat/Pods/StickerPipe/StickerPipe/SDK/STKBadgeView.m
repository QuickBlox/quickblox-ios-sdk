//
//  STKBadgeVIew.m
//  StickerPipe
//
//  Created by Vadim Degterev on 13.08.15.
//  Copyright (c) 2015 908 Inc. All rights reserved.
//

#import "STKBadgeView.h"

@interface STKBadgeView()

@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, strong) UIColor *borderColor;

@end


@implementation STKBadgeView

- (instancetype)initWithFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth dotSize:(CGSize)dotSize andBorderColor:(UIColor *)borderColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.lineWidth = lineWidth;
        self.dotSize = dotSize;
        self.borderColor = borderColor;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSException exceptionWithName:@"Init exeption" reason:@"Use initWithFrame:lineWidth:" userInfo:nil] raise];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGFloat lineWidth = self.lineWidth;
    CGRect rectInsets = CGRectInset(rect,lineWidth,lineWidth);
    UIBezierPath *path =  [UIBezierPath bezierPathWithRoundedRect:rectInsets cornerRadius:CGRectGetHeight(rectInsets) / 2.0];
    [[UIColor redColor] setFill];
    [path fill];
    path.lineWidth = lineWidth;
    [self.borderColor setStroke];
    [path stroke];
    
    CGFloat whiteDotWight = self.dotSize.width;
    CGFloat whiteDotHeight = self.dotSize.height;
    CGFloat whiteDotY = CGRectGetMidY(rectInsets) - (whiteDotHeight / 2.0);
    CGFloat whiteDotX = CGRectGetMidX(rectInsets) - (whiteDotWight / 2.0);
    
    UIBezierPath *whiteDot = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(whiteDotX, whiteDotY, whiteDotWight, whiteDotHeight) cornerRadius:whiteDotHeight / 2.0];
    [[UIColor whiteColor] setFill];
    [whiteDot fill];
    [path appendPath:whiteDot];
    
}



@end
