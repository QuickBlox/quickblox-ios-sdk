//
//  MenuTableViewCell.m
//  sample-users
//
//  Created by Injoit on 9/7/15.
//  Copyright (c) 2015 Quickblox. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (void)setItemInactive:(BOOL)itemInactive
{
    _itemInactive = itemInactive;
    
    if (itemInactive) {
        self.menuTitleLabel.textColor = [UIColor colorWithRed:10.0f/255.0f green:95.0f/255.0f blue:255.0f/255.0f alpha:0.3f];
    } else {
        self.menuTitleLabel.textColor = [UIColor colorWithRed:10.0f/255.0f green:95.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
    }
    
    self.selectionStyle = itemInactive ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
}

@end
