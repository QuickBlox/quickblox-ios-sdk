//
//  DialogTableViewCell.m
//  sample-chat
//
//  Created by Injoit on 2/25/19.
//  Copyright © 2019 Quickblox. All rights reserved.
//

#import "DialogTableViewCell.h"

@implementation DialogTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.unreadContainerView.layer.cornerRadius = 10.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIColor *color = self.unreadContainerView.backgroundColor;
    [super setSelected:selected animated:animated];
    
    if (selected) {
        self.unreadContainerView.backgroundColor = color;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIColor *color = self.unreadContainerView.backgroundColor;
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        self.unreadContainerView.backgroundColor = color;
    }
}

@end
