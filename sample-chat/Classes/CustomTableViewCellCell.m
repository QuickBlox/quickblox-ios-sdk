//
//  CustomTableViewCellCell.m
//  SimpleSample-chat_users-ios
//
//  Created by Alexey on 07.03.12.
//  Copyright (c) 2012 QuickBlox. All rights reserved.
//

#import "CustomTableViewCellCell.h"

@implementation CustomTableViewCellCell

@synthesize lat, lon, user, status;

- (void) dealloc
{
    [lat release];
    [lon release];
    [user release];
    [status release];
    [super dealloc];
}

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
