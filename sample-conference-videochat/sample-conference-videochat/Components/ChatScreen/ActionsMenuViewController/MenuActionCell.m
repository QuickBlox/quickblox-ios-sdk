//
//  MenuActionCell.m
//  sample-conference-videochat
//
//  Created by Injoit on 2/6/20.
//  Copyright © 2020 Quickblox. All rights reserved.
//

#import "MenuActionCell.h"

@implementation MenuActionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.separatorView.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
