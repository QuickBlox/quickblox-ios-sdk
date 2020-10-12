//
//  DialogCell.m
//  samplechat
//
//  Created by Injoit on 1/30/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "DialogCell.h"
#import "UILabel+Chat.h"

@implementation DialogCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkBoxImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.unreadMessageCounterHolder.layer.cornerRadius = 12.0;
    [self.dialogAvatarLabel setRoundedLabelWithCornerRadius:20.0f];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.checkBoxView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *markerColor = self.unreadMessageCounterHolder.backgroundColor;
    [super setSelected:selected animated:animated];
    self.unreadMessageCounterHolder.backgroundColor = markerColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *markerColor = self.unreadMessageCounterHolder.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    self.unreadMessageCounterHolder.backgroundColor = markerColor;
}

@end
