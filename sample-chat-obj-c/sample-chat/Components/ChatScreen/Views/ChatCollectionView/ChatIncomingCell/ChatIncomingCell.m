//
//  ChatIncomingCell.m
//  samplechat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatIncomingCell.h"
#import "UIView+Chat.h"
#import "CALayer+Chat.h"

@implementation ChatIncomingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.previewContainer.backgroundColor = UIColor.whiteColor;
    UIColor *shadowColor = [UIColor colorWithRed:0.85f green:0.9f blue:1.0f alpha:1.0f];
    [self.layer applyShadowWithColor:shadowColor
                               alpha:1.0f
                                forX:0.0f
                                forY:3.0f
                                blur:48.0f
                              spread:0.0f
                                path:nil];
}

+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(0, 24, 12, 16);
    defaultLayoutModel.avatarSize = CGSizeMake(40, 40);
    return defaultLayoutModel;
}

- (void)layoutSubviews {
    CGFloat cornerRadius = 20.0f;
    CAShapeLayer *layer = CAShapeLayer.new;
    layer.frame = self.previewContainer.layer.bounds;
    UIRectCorner roundingCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight;
    UIBezierPath *bPath = [UIBezierPath bezierPathWithRoundedRect:self.previewContainer.bounds
                                                byRoundingCorners:roundingCorners
                                                      cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    layer.path = bPath.CGPath;
    self.previewContainer.layer.mask = layer;
}

@end
