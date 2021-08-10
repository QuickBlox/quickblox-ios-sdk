//
//  ChatCallIncomingCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 25.03.2021.
//  Copyright © 2021 Quickblox. All rights reserved.
//

#import "ChatCallIncomingCell.h"
#import "UIView+Chat.h"
#import "CALayer+Chat.h"

@implementation ChatCallIncomingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.joinButton setRoundViewWithCornerRadius:15.0f];
    self.bubbleImageView.backgroundColor = UIColor.whiteColor;
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
    layer.frame = self.bubbleImageView.layer.bounds;
    UIRectCorner roundingCorners = UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomRight;
    UIBezierPath *bPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleImageView.bounds
                                                byRoundingCorners:roundingCorners
                                                      cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    layer.path = bPath.CGPath;
    self.bubbleImageView.layer.mask = layer;
}

- (IBAction)didTapJoinButton:(UIButton *)sender {
    if (self.didPressJoinButton) {
        self.didPressJoinButton();
    }
}

@end
