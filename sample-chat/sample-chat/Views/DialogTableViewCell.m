//
//  DialogTableViewCell.m
//  sample-chat
//
//  Created by Anton Sokolchenko on 6/8/15.
//  Copyright (c) 2015 Igor Khomenko. All rights reserved.
//

#import "DialogTableViewCell.h"

@implementation DialogTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.unreadContainerView.layer.cornerRadius = 10.0f;
}

@end
