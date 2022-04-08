//
//  ChatOutgoingCell.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "ChatOutgoingCell.h"
#import "UIView+Chat.h"
#import "CALayer+Chat.h"

@implementation ChatOutgoingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIColor *bubbleColor = [UIColor colorWithRed:0.22f green:0.47f blue:0.99 alpha:1.0f];
    self.previewContainer.backgroundColor = bubbleColor;
    [self.layer applyShadowWithColor:bubbleColor alpha:0.4f forX:0.0f forY:12.0f blur:12.0f spread:0.0f path:nil];
}

+ (ChatCellLayoutModel)layoutModel {
    
    ChatCellLayoutModel defaultLayoutModel = [super layoutModel];
    defaultLayoutModel.avatarSize = CGSizeMake(0, 0);
    defaultLayoutModel.containerInsets = UIEdgeInsetsMake(0, 16, 12, 14);
    defaultLayoutModel.spaceBetweenTopLabelAndTextView = 12.0f;
    defaultLayoutModel.timeLabelHeight = 15.0f;
    
    return defaultLayoutModel;
}

- (void)layoutSubviews {
    CGFloat cornerRadius = 20.0f;
    CAShapeLayer *layer = CAShapeLayer.new;
    layer.frame = self.previewContainer.layer.bounds;
    UIRectCorner roundingCorners = UIRectCornerBottomLeft | UIRectCornerTopLeft | UIRectCornerTopRight;
    UIBezierPath *bPath = [UIBezierPath bezierPathWithRoundedRect:self.previewContainer.bounds
                                                byRoundingCorners:roundingCorners
                                                      cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    layer.path = bPath.CGPath;
    self.previewContainer.layer.mask = layer;
}

@end
