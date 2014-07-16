//
//  CustomTableViewCellCell.m
//  SimpleSample-users-ios
//
//  Created by Alexey Voitenko on 07.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "CustomTableViewCellCell.h"

@implementation CustomTableViewCellCell

@synthesize userTag, userLogin;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
